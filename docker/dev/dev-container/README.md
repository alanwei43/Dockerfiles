基于 Ubuntu:24.04 创建镜像 dev-container, 需要集成常见开发环境（NodeJS、Python、JDK 1.8 + Maven）, 同时安装 code-server 用于使用VSCode进行开发。

  需要下载安装一下服务：

  - 安装code-server: https://github.com/coder/code-server/releases/download/v4.137.0/code-server_4.137.0_amd64.deb
  - 安装NodeJS: https://nodejs.org/dist/v24.21.0/node-v24.21.0-linux-x64.tar.xz
  - 使用 apt 安装 python3 和 python3-pip
  - 安装uv: https://releases.astral.sh/github/uv/releases/download/0.12.13/uv-x86_64-unknown-linux-gnu.tar.gz
  - 安装 apache maven 3.6.x
  - 安装 OpenJDK 1.8
  - 安装 OpenCode: https://github.com/anomalyco/opencode/releases/download/v1.18.30/opencode-linux-x64.tar.gz

## 安装要求
- 需要把 node/npm/npx/uv/uvx/opencode 等从压缩包安装的命令，在解压之后使用软链形式添加到 /usr/local/bin 目录下
- 安装完依赖，把系统mirror、uv/pip mirror 设置成清华大学的 mirror，npm mirror 设置成 npmmirror.com。

## 镜像设置

- 创建以下目录:
  - `/app`
  - `/data`
- 设置镜像的默认工作目录为 `/data`
- 设置镜像监听以下端口号:
  - code-server 默认监听端口号: `8080`
  - OpenCode Web端口号: `8090`

### 启动脚本

把启动脚本安装到 `/usr/local/bin/entrypoint.sh`，并创建软链接 `/data/entrypoint.sh`。镜像通过 `CMD` 默认执行 `/usr/local/bin/entrypoint.sh`，避免挂载 `/data` 时启动脚本被遮蔽。该脚本需要同时启动 code-server 和 opencode web；任一服务退出时，停止另一个服务并退出容器：

启动脚本是通过 `CMD`（而非 `ENTRYPOINT`）执行的，因此在 `docker run` 时可直接传入其他命令/脚本整体替换默认行为，例如 `docker run --rm -it alanway/dev:dev-container bash` 会直接进入 bash，而不启动 code-server 和 opencode web。

**code-server服务**

启动 code-server 时检测是否存在配置文件 `/data/config.yaml`，如果存在配置文件则执行 `code-server --config /data/config.yaml /app`

如果不存在配置文件 `/data/config.yaml`，则执行 code-server 监听 `0.0.0.0:8080`。设置 `PASSWORD` 环境变量时启用密码认证，否则不启用认证。

**opencode web**

在 `/app` 目录启动 OpenCode Web 服务，监听 `0.0.0.0:8090`。可通过 `OPENCODE_SERVER_PASSWORD` 环境变量启用密码认证。
