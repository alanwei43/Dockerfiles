# 开发工具镜像

## Dockerfile

按照以下逻辑生成 `docker/dev/network-tools/Dockerfile`:

- 设置工作目录为 `/data`
- 使用 `curl` 从远程下载 `https://github.com/MetaCubeX/mihomo/releases/download/v1.19.30/mihomo-linux-amd64-v3-v1.19.30.deb`, 并执行 `dpkg -i` 命令安装
- 使用 `curl` 从远程下载 `https://github.com/fatedier/frp/releases/download/v0.71.0/frp_0.71.0_linux_amd64.tar.gz` 并解压，然后把解压后的 `frp_0.71.0_linux_amd64/frpc` 和 `frp_0.71.0_linux_amd64/frps` 移动到 `/usr/local/bin/` 目录下
- 清理下载文件和解压目录

## 使用