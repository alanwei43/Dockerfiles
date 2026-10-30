ARG CADDY_VERSION="2.11.4"

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

ARG CADDY_VERSION
ARG CADDY_WEBDAV_COMMIT="fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b"
ARG CADDY_DNS_CLOUDFLARE_VERSION="v0.2.4"

RUN xcaddy build "v${CADDY_VERSION}" \
        --with "github.com/mholt/caddy-webdav@${CADDY_WEBDAV_COMMIT}" \
        --with "github.com/caddy-dns/cloudflare@${CADDY_DNS_CLOUDFLARE_VERSION}"

FROM caddy:${CADDY_VERSION}-alpine

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-09-13" \
    org.opencontainers.image.version="v2"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
