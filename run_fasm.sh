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
    if [[ "$OS_NAME" == Darwin* ]]; then
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew не найден. Устанавливаю Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [[ -x /opt/homebrew/bin/brew ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -x /usr/local/bin/brew ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        echo "Docker не найден. Устанавливаю Docker Desktop..."
        brew install --cask docker
    elif [[ "$OS_NAME" == MINGW* || "$OS_NAME" == MSYS* || "$OS_NAME" == CYGWIN* ]]; then
        if ! command -v winget >/dev/null 2>&1; then
            echo "Ошибка: winget не найден. Установите Docker Desktop вручную." >&2
            exit 1
        fi
        echo "Docker не найден. Устанавливаю Docker Desktop через winget..."
        winget install --id Docker.DockerDesktop --exact \
            --accept-source-agreements --accept-package-agreements
    else
        echo "Docker не найден. Установите Docker вручную для Linux." >&2
        exit 1
    fi
fi

if ! docker info >/dev/null 2>&1; then
    echo "Запускаю Docker Desktop..."
    if [[ "$OS_NAME" == Darwin* ]]; then
        open -a Docker
    elif [[ "$OS_NAME" == MINGW* || "$OS_NAME" == MSYS* || "$OS_NAME" == CYGWIN* ]]; then
        powershell.exe -NoProfile -Command 'Start-Process "Docker Desktop"'
    fi

    for _ in {1..60}; do
        if docker info >/dev/null 2>&1; then
            break
        fi
        sleep 2
    done
fi

if ! docker info >/dev/null 2>&1; then
    echo "Не удалось дождаться запуска Docker Desktop." >&2
    exit 1
fi

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Образ не найден. Собираю его..."
    docker build \
        --platform linux/amd64 \
        --tag "$IMAGE_NAME" \
        --file - \
        "$SCRIPT_DIR" <<'DOCKERFILE'
FROM --platform=linux/amd64 ubuntu:22.04

RUN apt-get update && apt-get install -y \
    fasm \
    gdb \
    gcc \
    gcc-multilib \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /asm

CMD ["/bin/bash"]
DOCKERFILE
fi

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    if [[ "$(docker inspect --format '{{.State.Running}}' "$CONTAINER_NAME")" == "true" ]]; then
        docker exec --interactive --tty "$CONTAINER_NAME" /bin/bash
    else
        docker start --attach --interactive "$CONTAINER_NAME"
    fi
else
    docker run --interactive --tty \
        --name "$CONTAINER_NAME" \
        --platform linux/amd64 \
        --volume "$SCRIPT_DIR:$CONTAINER_WORKDIR" \
        --workdir "$CONTAINER_WORKDIR" \
        "$IMAGE_NAME" \
        /bin/bash
fi