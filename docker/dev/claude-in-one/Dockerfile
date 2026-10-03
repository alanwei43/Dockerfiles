FROM ubuntu:24.04

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-10-03" \
    org.opencontainers.image.version="v6"

ARG CADDY_VERSION="2.11.4"
ARG FNM_VERSION="1.39.0"
ARG NODE_VERSION="24.21.0"
ARG UV_VERSION="0.12.13"
ARG CLAUDE_CODE_VERSION="2.1.270"
ARG CODE_SERVER_VERSION="4.137.0"
ARG TEMURIN_VERSION="8u504-b01"
ARG TEMURIN_ARCHIVE_VERSION="8u504b01"
ARG MAVEN_VERSION="3.6.3"

ENV FNM_DIR="/opt/fnm" \
    JAVA_HOME="/opt/java" \
    MAVEN_HOME="/opt/maven" \
    WEB_APP_DIR="/app" \
    PATH="/opt/java/bin:/opt/maven/bin:${PATH}"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        python3 \
        python3-pip \
        python-is-python3 \
        tmux \
        unzip \
        xz-utils; \
    download_dir="$(mktemp -d)"; \
    curl --fail --location \
        --output "${download_dir}/fnm.zip" \
        "https://github.com/Schniz/fnm/releases/download/v${FNM_VERSION}/fnm-linux.zip"; \
    unzip -q "${download_dir}/fnm.zip" -d "${download_dir}/fnm"; \
    if [ -f "${download_dir}/fnm/fnm" ]; then \
        install -m 0755 "${download_dir}/fnm/fnm" /usr/local/bin/fnm; \
    else \
        install -m 0755 "${download_dir}/fnm/fnm-linux/fnm" /usr/local/bin/fnm; \
    fi; \
    fnm install "${NODE_VERSION}"; \
    fnm default "${NODE_VERSION}"; \
    curl --fail --location \
        --output "${download_dir}/uv.tar.gz" \
        "https://releases.astral.sh/github/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz"; \
    install -d -m 0755 /opt/uv; \
    tar --extract --gzip --file "${download_dir}/uv.tar.gz" \
        --directory /opt/uv --strip-components=1; \
    curl --fail --location \
        --output "${download_dir}/temurin.tar.gz" \
        "https://github.com/adoptium/temurin8-binaries/releases/download/jdk${TEMURIN_VERSION}/OpenJDK8U-jdk_x64_linux_hotspot_${TEMURIN_ARCHIVE_VERSION}.tar.gz"; \
    install -d -m 0755 "${JAVA_HOME}"; \
    tar --extract --gzip --file "${download_dir}/temurin.tar.gz" \
        --directory "${JAVA_HOME}" --strip-components=1; \
    curl --fail --location \
        --output "${download_dir}/maven.tar.gz" \
        "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"; \
    install -d -m 0755 "${MAVEN_HOME}"; \
    tar --extract --gzip --file "${download_dir}/maven.tar.gz" \
        --directory "${MAVEN_HOME}" --strip-components=1; \
    curl --fail --location \
        --output "${download_dir}/code-server.deb" \
        "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb"; \
    apt-get install -y --no-install-recommends "${download_dir}/code-server.deb"; \
    curl --fail --location \
        --output "${download_dir}/caddy.tar.gz" \
        "https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_amd64.tar.gz"; \
    tar --extract --gzip --file "${download_dir}/caddy.tar.gz" \
        --directory "${download_dir}" caddy; \
    install -m 0755 "${download_dir}/caddy" /usr/local/bin/caddy; \
    curl --fail --location \
        --output "${download_dir}/claude.tar.gz" \
        "https://github.com/anthropics/claude-code/releases/download/v${CLAUDE_CODE_VERSION}/claude-linux-x64.tar.gz"; \
    tar --extract --gzip --file "${download_dir}/claude.tar.gz" \
        --directory "${download_dir}"; \
    install -m 0755 "${download_dir}/claude" /usr/local/bin/claude; \
    ln --symbolic /opt/uv/uv /usr/local/bin/uv; \
    ln --symbolic /opt/uv/uvx /usr/local/bin/uvx; \
    install -d -m 0755 /app /data/config /etc/uv; \
    rm -rf "${download_dir}" /var/lib/apt/lists/*

COPY ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources
COPY home/ /root/
COPY home/pip.conf /etc/pip.conf
COPY home/uv.toml /etc/uv/uv.toml
COPY code-server.yaml /data/config/code-server-example.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 0755 /usr/local/bin/entrypoint.sh; \
    ln --symbolic /usr/local/bin/entrypoint.sh /data/entrypoint.sh; \
    printf '%s\n' 'eval "$(fnm env --use-on-cd --shell bash)"' >> /root/.bashrc

WORKDIR /data

EXPOSE 80 443 443/udp 8080

CMD ["/usr/local/bin/entrypoint.sh"]
