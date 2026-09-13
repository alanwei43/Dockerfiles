# Dockerfiles

个人 Dockerfile 集合。仓库会自动构建 `docker/` 目录下的镜像，并分别推送到 Docker Hub 和阿里云容器镜像服务。

## 镜像列表

### `dev:happy-server`

[Happy](https://github.com/slopus/happy) 项目的自托管服务端镜像。构建时获取 Happy 主分支源码，并使用项目提供的 `Dockerfile.server` 构建服务端。

```shell
# Docker Hub
docker pull alanway/dev:happy-server

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/dev:happy-server
```

### `dev:network-tools`

基于 Debian 12 的网络工具镜像，预装 Mihomo `v1.19.30` 以及 FRP `v0.71.0` 的 `frpc`、`frps`。

```shell
# Docker Hub
docker pull alanway/dev:network-tools

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/dev:network-tools
```

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

## 目录规划

- `docker/os` 存放 Alpine、Ubuntu、Debian 等基础 OS 镜像
- `docker/service` 存放 RabbitMQ、Redis、数据库、中间件等常用服务镜像
- `docker/runtime` 存放 Node.js、Python、Deno、Bun、JDK、Go、Rust 等常用运行时镜像
- `docker/dev` 存放常用开发者工具以及可私有化部署的服务镜像
