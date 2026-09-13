# 个人 Dockerfile 集合

## Dockerfile 规范

`Dockerfile` 要增加以下 `LABEL` 信息:

- 维护人: Alan Wei
- 镜像所属仓库地址: https://github.com/alanwei43/Dockerfiles
- 镜像构建日期: 默认是 Dockerfile 文件创建日期，格式为 `2026-09-11`
- 镜像版本: 版本默认是 `v1`, 每次Dockerfile有修改，同时需要把版本加1

## 目录规划

### 基于官方镜像定制

以下目录中的镜像，一般会基于官方镜像做一些定制：

- `docker/os` 存放 Alpine/Ubuntu/Debian 等基础OS镜像
- `docker/runtime` 存放常用运行时，比如 NodeJS/Python/Deno/Bun/JDK/Go/Rust 等
- `docker/service` 存放 RabbitMQ/Redis/DB/Middleware 等常用服务镜像

且子目录命名规范为 `<official-image-name>-<version>`, 比如 `node-24`, 或者 `python-3.12`。

一般情况下，定制主要是添加一些mirror，方便国内用户使用。

### 开发者工具镜像

常用开发者工具，或者可私有化部署的服务，一般存放在目录 `docker/dev` 下。

## 开发约定

- 修改 Dockerfile 文件时，如果 Dockerfile 同级目录下有 README.md 文件，需要阅读并遵守 README.md 文件中的描述和约定，再修改 Dockerfile 文件。
- 修改 Dockerfile 后，仅执行不依赖网络的静态检查，不要执行在线构建验证，包括任何需要联网拉取基础镜像、构建阶段镜像或镜像元数据的命令。
- 每次新增 Dockerfile ，需要同步修改项目根目录的 `README.md` 文件，把新增的镜像信息补充到 **镜像列表** 章节。
