FROM alanway/dev:claude-in-one

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-10-28" \
    org.opencontainers.image.version="v3"

ARG TARGETARCH
ARG MULTICA_VERSION="0.7.1"

USER root

RUN set -eux; \
    target_arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "${target_arch}" in \
        amd64|arm64) ;; \
        *) echo "Unsupported architecture: ${target_arch}" >&2; exit 1 ;; \
    esac; \
    download_dir="$(mktemp -d)"; \
    curl --fail --location \
        --output "${download_dir}/multica.tar.gz" \
        "https://github.com/multica-ai/multica/releases/download/v${MULTICA_VERSION}/multica-cli-${MULTICA_VERSION}-linux-${target_arch}.tar.gz"; \
    tar --extract --gzip --file "${download_dir}/multica.tar.gz" \
        --directory "${download_dir}" multica; \
    install -m 0755 "${download_dir}/multica" /usr/local/bin/multica; \
    rm -rf "${download_dir}"

USER dev

CMD ["multica", "daemon", "start", "--foreground"]
