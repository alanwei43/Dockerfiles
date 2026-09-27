# 开发工具镜像

## Dockerfile

按照以下逻辑生成 `docker/dev/frp-mihomo/Dockerfile`:

- 设置工作目录为 `/data`
- 镜像构建 `linux/amd64` 与 `linux/arm64` 双架构，下载地址中的架构标识按构建目标架构（`TARGETARCH`）选择
- 使用 `curl` 从远程下载 mihomo 的 deb 包, 并执行 `dpkg -i` 命令安装。amd64 架构使用 `mihomo-linux-amd64-v3`（x86-64-v3 微架构级别），arm64 架构使用 `mihomo-linux-arm64`（无细分级别），例如 amd64 架构下载 `https://github.com/MetaCubeX/mihomo/releases/download/v1.19.30/mihomo-linux-amd64-v3-v1.19.30.deb`
- 使用 `curl` 从远程下载 `https://github.com/fatedier/frp/releases/download/v0.71.0/frp_0.71.0_linux_${TARGETARCH}.tar.gz`（`amd64` 或 `arm64`）并解压，然后把解压后的 `frp_0.71.0_linux_${TARGETARCH}/frpc` 和 `frp_0.71.0_linux_${TARGETARCH}/frps` 移动到 `/usr/local/bin/` 目录下
- 清理下载文件和解压目录

## 使用