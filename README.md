# Dockerfiles

Dockerfiles

本仓库会自动把 `docker/` 目录下的 `Dockerfile` 构建成镜像之后，分别推送到 Docker Hub 和 Aliyun Docker Container，如果需要获取本仓库下的镜像，可使用以下命令获取：

```shell
# 这里假设获取的镜像和标签是 dev:network-tools

## Docker Hub 镜像
docker pull alanway/dev:network-tools

## Aliyun 镜像
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/dev:network-tools
```

## 目录规划

- `docker/os` 存放 Alpine/Ubuntu/Debian 等基础OS镜像
- `docker/service` 存放 RabbitMQ/Redis/DB/Middleware 等常用服务镜像
- `docker/runtime` 存放常用运行时，比如 NodeJS/Python/Deno/Bun/JDK/Go/Rust 等
- `docker/dev` 存放常用开发者工具，以及可私有化部署的服务