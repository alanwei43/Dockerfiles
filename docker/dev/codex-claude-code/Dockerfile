FROM debian:12.15

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-09-13" \
    org.opencontainers.image.version="v5"

ARG CODEX_VERSION="0.154.0"
ARG CLAUDE_CODE_VERSION="2.1.270"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gzip tar vim; \
    download_dir="$(mktemp -d)"; \
    curl --fail --location \
        --output "${download_dir}/codex-code-mode-host.tar.gz" \
        "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz"; \
    curl --fail --location \
        --output "${download_dir}/bwrap.tar.gz" \
        "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/bwrap-x86_64-unknown-linux-musl.tar.gz"; \
    curl --fail --location \
        --output "${download_dir}/codex.tar.gz" \
        "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/codex-x86_64-unknown-linux-musl.tar.gz"; \
    curl --fail --location \
        --output "${download_dir}/claude.tar.gz" \
        "https://github.com/anthropics/claude-code/releases/download/v${CLAUDE_CODE_VERSION}/claude-linux-x64.tar.gz"; \
    tar --extract --gzip --file "${download_dir}/codex-code-mode-host.tar.gz" --directory "${download_dir}"; \
    tar --extract --gzip --file "${download_dir}/bwrap.tar.gz" --directory "${download_dir}"; \
    tar --extract --gzip --file "${download_dir}/codex.tar.gz" --directory "${download_dir}"; \
    tar --extract --gzip --file "${download_dir}/claude.tar.gz" --directory "${download_dir}"; \
    install -m 0755 \
        "${download_dir}/codex-code-mode-host-x86_64-unknown-linux-musl" \
        /usr/local/bin/codex-code-mode-host; \
    install -m 0755 \
        "${download_dir}/bwrap-x86_64-unknown-linux-musl" \
        /usr/local/bin/bwrap; \
    install -m 0755 \
        "${download_dir}/codex-x86_64-unknown-linux-musl" \
        /usr/local/bin/codex; \
    install -m 0755 "${download_dir}/claude" /usr/local/bin/claude; \
    install -d -m 0755 /root/.local/bin; \
    install -m 0755 \
        /usr/local/bin/codex \
        /usr/local/bin/codex-code-mode-host \
        /usr/local/bin/bwrap \
        /usr/local/bin/claude \
        /root/.local/bin/; \
    rm -rf "${download_dir}" /var/lib/apt/lists/*

COPY .claude.json /root/.claude.json
COPY .claude/ /root/.claude/
COPY .codex/ /root/.codex/

RUN chmod 0755 /root/.codex/hooks/*.sh
