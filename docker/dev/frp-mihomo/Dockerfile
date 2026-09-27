FROM debian:12.15

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-09-12" \
    org.opencontainers.image.version="v3"

ARG MIHOMO_VERSION="1.19.30"
ARG FRP_VERSION="0.71.0"
ARG TARGETARCH

# mihomo 包名：amd64 使用 x86-64-v3 微架构级别，arm64 无细分级别
# frp 发布包名直接使用 TARGETARCH（amd64/arm64）
WORKDIR /data
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) mihomo_pkg="mihomo-linux-amd64-v3" ;; \
        arm64) mihomo_pkg="mihomo-linux-arm64" ;; \
        *) printf '不支持的架构: %s\n' "${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl; \
    curl --fail --location --output mihomo.deb \
        "https://github.com/MetaCubeX/mihomo/releases/download/v${MIHOMO_VERSION}/${mihomo_pkg}-v${MIHOMO_VERSION}.deb"; \
    dpkg -i mihomo.deb; \
    curl --fail --location --output "frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz" \
        "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    tar --extract --gzip --file "frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    mv "frp_${FRP_VERSION}_linux_${TARGETARCH}/frpc" \
        "frp_${FRP_VERSION}_linux_${TARGETARCH}/frps" \
        /usr/local/bin/; \
    rm -rf \
        mihomo.deb \
        "frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz" \
        "frp_${FRP_VERSION}_linux_${TARGETARCH}"; \
    rm -rf /var/lib/apt/lists/*
