FROM node:24

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-09-12" \
    org.opencontainers.image.version="v1"

ENV COREPACK_NPM_REGISTRY="https://registry.npmmirror.com"

RUN sed -i \
        -e 's|https\?://deb.debian.org/debian-security|https://mirrors.tuna.tsinghua.edu.cn/debian-security|g' \
        -e 's|https\?://deb.debian.org/debian|https://mirrors.tuna.tsinghua.edu.cn/debian|g' \
        /etc/apt/sources.list.d/debian.sources

COPY .npmrc /usr/local/etc/npmrc
