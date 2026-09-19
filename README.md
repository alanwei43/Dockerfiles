# Dockerfiles

个人 Dockerfile 集合。仓库会自动构建 `docker/` 目录下的镜像，并分别推送到 Docker Hub 和阿里云容器镜像服务。

## 镜像列表

### `dev:codex-claude-code`

基于 Debian `12.15` 的 AI 编程助手镜像，预装以下开发者工具:
- OpenAI Codex CLI `v0.154.0`（含 `codex-code-mode-host` 与 `bwrap`）
- Claude Code `v2.1.270`
- Node.js `24.21.0`
- uv `0.12.13`
- Python 3

```shell
# Docker Hub
docker pull alanway/dev:codex-claude-code

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/dev:codex-claude-code
```

#### 本地测试使用
```shell
docker run --rm -it --mount type=bind,source=$HOME/.codex/config.toml,target=/root/.codex/config-machine.toml,readonly registry.cn-hangzhou.aliyuncs.com/alanwei/dev:codex-claude-code bash

# 以下命令在容器内执行
# cp ~/.codex/config-machine.toml /root/.codex/config.toml
```

#### 挂载物理机的 Claude Code 配置（读写）
```shell
docker run --rm -it \
    --mount type=bind,source=$HOME/.claude.json,target=/root/.claude.json \
    --mount type=bind,source=$HOME/.claude/settings.json,target=/root/.claude/settings.json \
    registry.cn-hangzhou.aliyuncs.com/alanwei/dev:codex-claude-code bash
```

#### 挂载物理机的 Codex 配置（读写）
```shell
docker run --rm -it \
    --mount type=bind,source=$HOME/.codex/auth.json,target=/root/.codex/auth.json \
    --mount type=bind,source=$HOME/.codex/config.toml,target=/root/.codex/config.toml \
    registry.cn-hangzhou.aliyuncs.com/alanwei/dev:codex-claude-code bash
```

### `dev:happy-server`

[Happy](https://github.com/slopus/happy) 项目的自托管服务端镜像。构建时获取 Happy 主分支源码，并使用项目提供的 `Dockerfile.server` 构建服务端。

```shell
# Docker Hub
docker pull alanway/dev:happy-server

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/dev:happy-server
```

### `dev:frp-mihomo`

基于 Debian 12 的网络工具镜像，预装 Mihomo `v1.19.30` 以及 FRP `v0.71.0` 的 `frpc`、`frps`。

```shell
# Docker Hub
docker pull alanway/dev:frp-mihomo

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/dev:frp-mihomo
```

### `dev:dev-container`

基于 Ubuntu `24.04` 的 AMD64 通用开发环境镜像，预装 code-server `v4.137.0`（浏览器中使用 VS Code）、OpenCode `v1.18.30`、Node.js `v24.21.0`、Python 3（含 pip 与 uv `0.12.13`）、OpenJDK 1.8（Temurin `8u504-b01`）以及 Apache Maven `3.6.3`。apt、pip、uv 源已配置为清华大学开源软件镜像站，npm 源配置为 npmmirror。

```shell
# Docker Hub
docker pull alanway/dev:dev-container

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/dev:dev-container
```

code-server 使用 `8080` 端口，OpenCode Web 使用 `8090` 端口。默认不启用认证；不要将未设置密码的端口暴露到公网。可分别通过 `PASSWORD` 和 `OPENCODE_SERVER_PASSWORD` 设置两个服务的登录密码：

```shell
docker run --rm -d \
    --publish 0.0.0.0:8085:8080 \
    --publish 0.0.0.0:8095:8090 \
    --mount type=bind,source="$(pwd)",target=/app \
    alanway/dev:dev-container
```

如需使用 code-server 配置文件，可将其挂载到 `/data/config.yaml`。挂载整个 `/data` 目录也不会遮蔽镜像的实际启动脚本。

### `os:alpine-3.11.6`

基于 Alpine Linux `3.11.6`，将 APK 软件源替换为清华大学开源软件镜像站，适合国内网络环境使用。

```shell
# Docker Hub
docker pull alanway/os:alpine-3.11.6

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/os:alpine-3.11.6
```

### `runtime:node-24`

基于 Node.js 24 官方镜像，将 Debian 软件源替换为清华大学开源软件镜像站，并将 npm 与 Corepack registry 配置为 npmmirror。

```shell
# Docker Hub
docker pull alanway/runtime:node-24

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/runtime:node-24
```

### `runtime:python-3.12`

基于 Python `3.12-slim-bookworm` 官方镜像，预装 `uv` 和 `uvx`，并为 Debian、pip 和 uv 配置清华大学开源软件镜像站。

```shell
# Docker Hub
docker pull alanway/runtime:python-3.12

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/runtime:python-3.12
```

### `service:caddy-webdav`

基于 Caddy `2.11.4` 官方镜像，使用 xcaddy 编译并加入 [caddy-webdav](https://github.com/mholt/caddy-webdav) WebDAV 处理模块。

```shell
# Docker Hub
docker pull alanway/service:caddy-webdav

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/service:caddy-webdav
```

使用时挂载 Caddyfile 和可写的数据目录。例如：

```Caddyfile
{
    order webdav before file_server
}

http:// {
    root * /data/webdav
    webdav
}
```

```shell
docker run --rm \
    --publish 127.0.0.1:8080:80 \
    --mount type=bind,source="$(pwd)/Caddyfile",target=/etc/caddy/Caddyfile,readonly \
    --mount type=bind,source="$(pwd)/data",target=/data/webdav \
    alanway/service:caddy-webdav
```

## 目录规划

- `docker/os` 存放 Alpine、Ubuntu、Debian 等基础 OS 镜像
- `docker/service` 存放 RabbitMQ、Redis、数据库、中间件等常用服务镜像
- `docker/runtime` 存放 Node.js、Python、Deno、Bun、JDK、Go、Rust 等常用运行时镜像
- `docker/dev` 存放常用开发者工具以及可私有化部署的服务镜像
