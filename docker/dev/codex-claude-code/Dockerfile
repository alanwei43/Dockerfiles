FROM debian:12.15

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-09-13" \
    org.opencontainers.image.version="v9"

ARG CODEX_VERSION="0.154.0"
ARG CLAUDE_CODE_VERSION="2.1.270"
ARG NODE_VERSION="24.21.0"
ARG UV_VERSION="0.12.13"
ARG TARGETARCH

# node_arch: Node.js 与 Claude Code 的发布命名（x64/arm64）
# rust_arch: uv 与 Codex 系列的发布命名（x86_64/aarch64）
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) node_arch=x64; rust_arch=x86_64 ;; \
        arm64) node_arch=arm64; rust_arch=aarch64 ;; \
        *) printf '不支持的架构: %s\n' "${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gzip \
        python3 \
        python3-pip \
        tar \
        vim \
        xz-utils; \
    download_dir="$(mktemp -d)"; \
    curl --fail --location \
        --output "${download_dir}/node.tar.xz" \
        "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${node_arch}.tar.xz"; \
    install -d -m 0755 /opt/node; \
    tar --extract --xz --file "${download_dir}/node.tar.xz" \
        --directory /opt/node --strip-components=1; \
    curl --fail --location \
        --output "${download_dir}/uv.tar.gz" \
        "https://releases.astral.sh/github/uv/releases/download/${UV_VERSION}/uv-${rust_arch}-unknown-linux-gnu.tar.gz"; \
    install -d -m 0755 /opt/uv; \
    tar --extract --gzip --file "${download_dir}/uv.tar.gz" \
        --directory /opt/uv --strip-components=1; \
    ln --symbolic /opt/node/bin/node /usr/local/bin/node; \
    ln --symbolic /opt/node/bin/npm /usr/local/bin/npm; \
    ln --symbolic /opt/node/bin/npx /usr/local/bin/npx; \
    ln --symbolic /opt/node/bin/corepack /usr/local/bin/corepack; \
    ln --symbolic /opt/uv/uv /usr/local/bin/uv; \
    ln --symbolic /opt/uv/uvx /usr/local/bin/uvx; \
    ln --symbolic /usr/bin/python3 /usr/bin/python; \
    curl --fail --location \
        --output "${download_dir}/codex-code-mode-host.tar.gz" \
        "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/codex-code-mode-host-${rust_arch}-unknown-linux-musl.tar.gz"; \
    curl --fail --location \
        --output "${download_dir}/bwrap.tar.gz" \
        "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/bwrap-${rust_arch}-unknown-linux-musl.tar.gz"; \
    curl --fail --location \
        --output "${download_dir}/codex.tar.gz" \
        "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/codex-${rust_arch}-unknown-linux-musl.tar.gz"; \
    curl --fail --location \
        --output "${download_dir}/claude.tar.gz" \
        "https://github.com/anthropics/claude-code/releases/download/v${CLAUDE_CODE_VERSION}/claude-linux-${node_arch}.tar.gz"; \
    tar --extract --gzip --file "${download_dir}/codex-code-mode-host.tar.gz" --directory "${download_dir}"; \
    tar --extract --gzip --file "${download_dir}/bwrap.tar.gz" --directory "${download_dir}"; \
    tar --extract --gzip --file "${download_dir}/codex.tar.gz" --directory "${download_dir}"; \
    tar --extract --gzip --file "${download_dir}/claude.tar.gz" --directory "${download_dir}"; \
    install -m 0755 \
        "${download_dir}/codex-code-mode-host-${rust_arch}-unknown-linux-musl" \
        /usr/local/bin/codex-code-mode-host; \
    install -m 0755 \
        "${download_dir}/bwrap-${rust_arch}-unknown-linux-musl" \
        /usr/local/bin/bwrap; \
    install -m 0755 \
        "${download_dir}/codex-${rust_arch}-unknown-linux-musl" \
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
