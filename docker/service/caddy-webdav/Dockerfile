ARG CADDY_VERSION="2.11.4"

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

ARG CADDY_WEBDAV_COMMIT="fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b"

RUN xcaddy build \
        --with "github.com/mholt/caddy-webdav@${CADDY_WEBDAV_COMMIT}"

FROM caddy:${CADDY_VERSION}-alpine

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-09-13" \
    org.opencontainers.image.version="v1"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
