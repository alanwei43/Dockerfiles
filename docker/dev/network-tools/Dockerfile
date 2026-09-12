FROM debian:12.15

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-09-12" \
    org.opencontainers.image.version="v1"

WORKDIR /data
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl --fail --location --output mihomo-linux-amd64-v3-v1.19.30.deb \
        https://github.com/MetaCubeX/mihomo/releases/download/v1.19.30/mihomo-linux-amd64-v3-v1.19.30.deb \
    && dpkg -i mihomo-linux-amd64-v3-v1.19.30.deb \
    && curl --fail --location --output frp_0.71.0_linux_amd64.tar.gz \
        https://github.com/fatedier/frp/releases/download/v0.71.0/frp_0.71.0_linux_amd64.tar.gz \
    && tar --extract --gzip --file frp_0.71.0_linux_amd64.tar.gz \
    && mv frp_0.71.0_linux_amd64/frpc frp_0.71.0_linux_amd64/frps /usr/local/bin/ \
    && rm -rf \
        mihomo-linux-amd64-v3-v1.19.30.deb \
        frp_0.71.0_linux_amd64.tar.gz \
        frp_0.71.0_linux_amd64 \
    && rm -rf /var/lib/apt/lists/*
