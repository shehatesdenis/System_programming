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
