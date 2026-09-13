FROM ubuntu:24.04

LABEL maintainer="Alan Wei" \
    org.opencontainers.image.source="https://github.com/alanwei43/Dockerfiles" \
    org.opencontainers.image.created="2026-09-13" \
    org.opencontainers.image.version="v3"

ARG CODE_SERVER_VERSION="4.137.0"
ARG NODE_VERSION="24.21.0"
ARG UV_VERSION="0.12.13"
ARG TEMURIN_VERSION="8u504-b01"
ARG TEMURIN_ARCHIVE_VERSION="8u504b01"
ARG MAVEN_VERSION="3.6.3"
ARG OPENCODE_VERSION="1.18.30"

ENV JAVA_HOME="/opt/java" \
    MAVEN_HOME="/opt/maven" \
    PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" \
    UV_DEFAULT_INDEX="https://pypi.tuna.tsinghua.edu.cn/simple"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        less \
        openssh-client \
        python3 \
        python3-pip \
        unzip \
        vim \
        xz-utils \
        sqlite3 \
        zip; \
    download_dir="$(mktemp -d)"; \
    curl --fail --location \
        --output "${download_dir}/code-server.deb" \
        "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb"; \
    apt-get install -y --no-install-recommends "${download_dir}/code-server.deb"; \
    curl --fail --location \
        --output "${download_dir}/node.tar.xz" \
        "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"; \
    install -d -m 0755 /opt/node; \
    tar --extract --xz --file "${download_dir}/node.tar.xz" \
        --directory /opt/node --strip-components=1; \
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
        --output "${download_dir}/opencode.tar.gz" \
        "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-x64.tar.gz"; \
    install -d -m 0755 /opt/opencode; \
    tar --extract --gzip --file "${download_dir}/opencode.tar.gz" \
        --directory /opt/opencode; \
    ln --symbolic /opt/node/bin/node /usr/local/bin/node; \
    ln --symbolic /opt/node/bin/npm /usr/local/bin/npm; \
    ln --symbolic /opt/node/bin/npx /usr/local/bin/npx; \
    ln --symbolic /opt/uv/uv /usr/local/bin/uv; \
    ln --symbolic /opt/uv/uvx /usr/local/bin/uvx; \
    ln --symbolic /opt/opencode/opencode /usr/local/bin/opencode; \
    ln --symbolic "${JAVA_HOME}/bin/java" /usr/local/bin/java; \
    ln --symbolic "${JAVA_HOME}/bin/javac" /usr/local/bin/javac; \
    ln --symbolic "${JAVA_HOME}/bin/jar" /usr/local/bin/jar; \
    ln --symbolic "${MAVEN_HOME}/bin/mvn" /usr/local/bin/mvn; \
    npm config set --global registry https://registry.npmmirror.com; \
    install -d -m 0755 /etc/uv /app /data; \
    printf '%s\n' \
        '[global]' \
        'index-url = https://pypi.tuna.tsinghua.edu.cn/simple' \
        > /etc/pip.conf; \
    printf '%s\n' \
        'default-index = "https://pypi.tuna.tsinghua.edu.cn/simple"' \
        > /etc/uv/uv.toml; \
    sed -i \
        -e 's|http://archive.ubuntu.com/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ubuntu|g' \
        -e 's|http://security.ubuntu.com/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ubuntu|g' \
        /etc/apt/sources.list.d/ubuntu.sources; \
    rm -rf "${download_dir}" /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 0755 /usr/local/bin/entrypoint.sh; \
    ln --symbolic /usr/local/bin/entrypoint.sh /data/entrypoint.sh

WORKDIR /data

EXPOSE 8080 8090

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl --silent --show-error --output /dev/null --max-time 2 http://127.0.0.1:8080/ \
        && curl --silent --show-error --output /dev/null --max-time 2 http://127.0.0.1:8090/ \
        || exit 1

CMD ["/usr/local/bin/entrypoint.sh"]
