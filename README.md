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
