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

if ! docker info >/dev/null 2>&1; then
    echo "Запуск Docker..."
    if [[ "$OS_NAME" == Darwin* ]]; then
        open -a Docker
    fi
    for _ in {1..60}; do
        if docker info >/dev/null 2>&1; then break; fi
        sleep 2
    done
fi

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Собираю образ..."
    docker build \
        --platform linux/amd64 \
        --tag "$IMAGE_NAME" \
        --file - \
        "$SCRIPT_DIR" <<'DOCKERFILE'
FROM --platform=linux/amd64 ubuntu:22.04

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

# Use a more permissive security profile for mmap/syscalls if possible, 
# but we can't easily change Docker daemon config here.
# Instead, we ensure we run with a clean volume mapping.

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    docker rm -f "$CONTAINER_NAME"
fi

docker run -it \
    --name "$CONTAINER_NAME" \
    --platform linux/amd64 \
    --volume "$SCRIPT_DIR:$CONTAINER_WORKDIR" \
    --workdir "$CONTAINER_WORKDIR" \
    "$IMAGE_NAME" \
    /bin/bash
