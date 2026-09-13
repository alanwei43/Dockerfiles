当前镜像基于 Debian:12.15 镜像创建，然后从 GitHub 官方仓库的 Release 下载并安装 Claude Code 和 Codex :

- 需求下载的文件
  - https://github.com/openai/codex/releases/download/rust-v0.154.0/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz
  - https://github.com/openai/codex/releases/download/rust-v0.154.0/bwrap-x86_64-unknown-linux-musl.tar.gz
  - https://github.com/openai/codex/releases/download/rust-v0.154.0/codex-x86_64-unknown-linux-musl.tar.gz
  - https://github.com/anthropics/claude-code/releases/download/v2.1.270/claude-linux-x64.tar.gz
- 文件下载完成后，需要解压之后把可执行文件复制至 `/usr/local/bin` 目录下