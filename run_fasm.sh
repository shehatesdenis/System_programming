#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="system-programming-fasm"
CONTAINER_NAME="system-programming-fasm"
CONTAINER_WORKDIR="/system_programming"

OS_NAME="$(uname -s)"
case "$OS_NAME" in
    Darwin*|Linux*|MINGW*|MSYS*|CYGWIN*) ;;
    *)
        echo "Ошибка: эта система не поддерживается: $OS_NAME" >&2
        exit 1
        ;;
esac

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker не найден. Пожалуйста, установите Docker Desktop." >&2
    exit 1
fi

DOCKER=(docker)
SSH=()

run_docker() {
    if [[ -n "${SSH[0]:-}" ]]; then
        local remote_command
        printf -v remote_command '%q ' docker "$@"
        if [[ "$1" == run && -t 0 && -t 1 ]]; then
            "${SSH[@]}" -t "lima-colima-$PROFILE" "$remote_command"
        else
            "${SSH[@]}" "lima-colima-$PROFILE" "$remote_command"
        fi
    else
        "${DOCKER[@]}" "$@"
    fi
}

use_colima_ssh() {
    local profile="$1"
    local config="${COLIMA_HOME:-$HOME/.colima}/_lima/colima-$profile/ssh.config"
    [[ -r "$config" ]] || return 1

    SSH=(ssh -F "$config" -o BatchMode=yes -o ControlMaster=no
        -o ControlPath=none -o ConnectTimeout=5)
    if ! "${SSH[@]}" "lima-colima-$profile" 'docker info >/dev/null' </dev/null >/dev/null 2>&1; then
        SSH=()
        return 1
    fi
}

if [[ "$OS_NAME" == Darwin* && "$(uname -m)" == arm64 ]]; then
    if ! command -v colima >/dev/null 2>&1 || ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        echo "Установите зависимости для GDB: brew install colima qemu lima-additional-guestagents" >&2
        exit 1
    fi

    PROFILE="fasm-x86"
    DOCKER=(docker --context "colima-$PROFILE")
    if ! run_docker info >/dev/null 2>&1 && ! use_colima_ssh "$PROFILE"; then
        if guest_agent="$(limactl info --yq '.guestAgents.x86_64.location // ""' 2>/dev/null)" &&
           [[ -z "$guest_agent" ]]; then
            echo "Lima не нашла гостевой агент x86-64. Установка: brew install lima-additional-guestagents" >&2
            exit 1
        fi
        colima start "$PROFILE" \
            --arch x86_64 \
            --vm-type qemu \
            --runtime docker \
            --activate=false \
            --disk 12 \
            --mount "$SCRIPT_DIR:w" || {
            use_colima_ssh "$PROFILE" || exit 1
        }
        if ! run_docker info >/dev/null 2>&1; then
            use_colima_ssh "$PROFILE"
        fi
    fi

    case "$(run_docker info --format '{{.Architecture}}')" in
        x86_64|amd64) ;;
        *)
            echo "Ошибка: для отладки Docker должен работать внутри Linux x86-64." >&2
            exit 1
            ;;
    esac
elif ! "${DOCKER[@]}" info >/dev/null 2>&1; then
    echo "Запуск Docker..."
    if [[ "$OS_NAME" == Darwin* ]]; then
        open -a Docker
    fi
    for _ in {1..60}; do
        if "${DOCKER[@]}" info >/dev/null 2>&1; then break; fi
        sleep 2
    done
fi

if ! run_docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Собираю образ..."
    run_docker build \
        --platform linux/amd64 \
        --tag "$IMAGE_NAME" \
        - <<'DOCKERFILE'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    fasm \
    gdb \
    gcc \
    gcc-multilib \
    libc6-dev \
    make \
    binutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /system_programming
CMD ["/bin/bash"]
DOCKERFILE
fi

if run_docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    run_docker rm -f "$CONTAINER_NAME"
fi

run_docker run -it \
    --cap-add SYS_PTRACE \
    --security-opt seccomp=unconfined \
    --name "$CONTAINER_NAME" \
    --platform linux/amd64 \
    --volume "$SCRIPT_DIR:$CONTAINER_WORKDIR" \
    --workdir "$CONTAINER_WORKDIR" \
    "$IMAGE_NAME" \
    /bin/bash
