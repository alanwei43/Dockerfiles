FROM alanway/dev:claude-in-one

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-10-28" \
    org.opencontainers.image.version="v2"

ARG MULTICA_VERSION="0.7.1"

USER root

RUN set -eux; \
    download_dir="$(mktemp -d)"; \
    curl --fail --location \
        --output "${download_dir}/multica.tar.gz" \
        "https://github.com/multica-ai/multica/releases/download/v${MULTICA_VERSION}/multica-cli-${MULTICA_VERSION}-linux-amd64.tar.gz"; \
    tar --extract --gzip --file "${download_dir}/multica.tar.gz" \
        --directory "${download_dir}" multica; \
    install -m 0755 "${download_dir}/multica" /usr/local/bin/multica; \
    rm -rf "${download_dir}"

USER dev

CMD ["multica", "daemon", "start", "--foreground"]
