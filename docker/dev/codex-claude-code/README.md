当前镜像基于 Debian:12.15 镜像创建，然后从 GitHub 官方仓库的 Release 下载并安装 Claude Code 和 Codex :

镜像构建 `linux/amd64` 与 `linux/arm64` 双架构，下载地址中的架构标识按构建目标架构（`TARGETARCH`）选择：

- `x86_64` ↔ `aarch64`（uv 与 Codex 系列）
- `x64` ↔ `arm64`（Node.js 与 Claude Code）

- 需求下载的文件（以下以 amd64 架构为例）
  - https://github.com/openai/codex/releases/download/rust-v0.154.0/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz
  - https://github.com/openai/codex/releases/download/rust-v0.154.0/bwrap-x86_64-unknown-linux-musl.tar.gz
  - https://github.com/openai/codex/releases/download/rust-v0.154.0/codex-x86_64-unknown-linux-musl.tar.gz
  - https://github.com/anthropics/claude-code/releases/download/v2.1.270/claude-linux-x64.tar.gz
- 文件下载完成后，需要解压之后把可执行文件复制至 `/usr/local/bin` 目录下
- 需要安装 NodeJS v24（官方 tarball 解压至 `/opt/node`，`node`/`npm`/`npx`/`corepack` 以软链接方式暴露在 `/usr/local/bin`）
- 需要安装 uv（官方 tarball 解压至 `/opt/uv`，`uv`/`uvx` 以软链接方式暴露在 `/usr/local/bin`）
- 需要安装 Python 3（Debian 仓库的 `python3`/`python3-pip`），并以软链接方式在 `/usr/bin` 下提供 `python` 命令（指向 `python3`）