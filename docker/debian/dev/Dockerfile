FROM debian:12.15

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-09-12"

WORKDIR /data
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl --fail --location --output mihomo-linux-amd64-v3-v1.19.30.deb \
        https://github.com/MetaCubeX/mihomo/releases/download/v1.19.30/mihomo-linux-amd64-v3-v1.19.30.deb \
    && dpkg -i mihomo-linux-amd64-v3-v1.19.30.deb \
    && rm mihomo-linux-amd64-v3-v1.19.30.deb \
    && rm -rf /var/lib/apt/lists/*
