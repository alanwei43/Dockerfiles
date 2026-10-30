# Caddy WebDAV

基于 Caddy `2.11.4` 官方镜像，使用 xcaddy 编译并加入 [caddy-webdav](https://github.com/mholt/caddy-webdav) WebDAV 模块和 [caddy-dns/cloudflare `v0.2.4`](https://github.com/caddy-dns/cloudflare/tree/v0.2.4) DNS 模块，支持通过 Cloudflare 进行 DNS-01 验证，自动申请和续期 HTTPS 证书。

## 镜像地址

```shell
# Docker Hub
docker pull alanway/service:caddy-webdav

# 阿里云容器镜像服务
docker pull registry.cn-hangzhou.aliyuncs.com/alanwei/service:caddy-webdav
```

以下示例使用 Docker Hub 镜像，也可替换为对应的阿里云地址。

## 本地目录与持久化

选择一个固定的部署目录，在其中创建以下目录，并保存所选场景的 `Caddyfile`。所有命令均在该部署目录执行；每个场景可选择 `docker run` 或 Docker Compose 启动。

```shell
mkdir -p webdav caddy/data caddy/config
```

| 本地路径 | 容器路径 | 用途 |
| --- | --- | --- |
| `./Caddyfile` | `/etc/caddy/Caddyfile` | 只读挂载的服务配置 |
| `./webdav` | `/srv/webdav` | WebDAV 文件，需可写 |
| `./caddy/data` | `/data` | Caddy 数据目录，保存证书、私钥及 ACME 账户信息，需可写 |
| `./caddy/config` | `/config` | Caddy 配置状态目录，需可写 |

以下所有启动示例都将这些路径绑定到宿主机。删除或重建容器时，保留 `./caddy/data` 和 `./caddy/config`，并继续挂载原来的本地目录，Caddy 即可复用已有证书和账户信息，避免因容器存储丢失而重复申请证书。切换启动方式或部署位置时也应复用或迁移这些目录。证书到期前，Caddy 仍会正常自动续期。[Caddy 数据与配置目录说明](https://caddyserver.com/docs/conventions#file-locations)

## HTTP WebDAV

将以下内容保存为部署目录中的 `Caddyfile`：

```Caddyfile
{
    order webdav before file_server
}

http:// {
    root * /srv/webdav
    webdav
}
```

### 使用 docker run

```shell
docker run --detach \
    --name caddy-webdav \
    --restart unless-stopped \
    --publish 127.0.0.1:8080:80 \
    --mount type=bind,source="$(pwd)/Caddyfile",target=/etc/caddy/Caddyfile,readonly \
    --mount type=bind,source="$(pwd)/webdav",target=/srv/webdav \
    --mount type=bind,source="$(pwd)/caddy/data",target=/data \
    --mount type=bind,source="$(pwd)/caddy/config",target=/config \
    alanway/service:caddy-webdav
```

### 使用 docker-compose.yml

在部署目录保存以下 `docker-compose.yml`：

```yaml
services:
  caddy-webdav:
    image: alanway/service:caddy-webdav
    restart: unless-stopped
    ports:
      - "127.0.0.1:8080:80"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./webdav:/srv/webdav
      - ./caddy/data:/data
      - ./caddy/config:/config
```

```shell
docker compose -f docker-compose.yml up -d
```

WebDAV 客户端连接地址为 `http://127.0.0.1:8080/`，文件保存在本地 `./webdav` 目录。

## HTTPS WebDAV 与 DNS-01（Cloudflare）

域名的权威 DNS 需托管在 Cloudflare。创建具有目标域名 `Zone.Zone:Read` 和 `Zone.DNS:Edit` 权限的 API Token。[插件配置及权限说明](https://github.com/caddy-dns/cloudflare/blob/v0.2.4/README.md#configuration)

在部署目录中创建 `.env` 文件，将占位值替换为实际 Token。两种启动方式都会在运行时读取该文件：

```dotenv
CF_API_TOKEN=replace-with-your-cloudflare-api-token
```

将以下内容保存为 `Caddyfile`，把 `dav.example.com` 替换为自己的域名：

```Caddyfile
{
    order webdav before file_server
}

dav.example.com {
    tls {
        dns cloudflare {env.CF_API_TOKEN}
    }

    root * /srv/webdav
    webdav
}
```

### 使用 docker run

```shell
docker run --detach \
    --name caddy-webdav \
    --restart unless-stopped \
    --publish 443:443 \
    --env-file "$(pwd)/.env" \
    --mount type=bind,source="$(pwd)/Caddyfile",target=/etc/caddy/Caddyfile,readonly \
    --mount type=bind,source="$(pwd)/webdav",target=/srv/webdav \
    --mount type=bind,source="$(pwd)/caddy/data",target=/data \
    --mount type=bind,source="$(pwd)/caddy/config",target=/config \
    alanway/service:caddy-webdav
```

### 使用 docker-compose.yml

在部署目录保存以下 `docker-compose.yml`：

```yaml
services:
  caddy-webdav:
    image: alanway/service:caddy-webdav
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./webdav:/srv/webdav
      - ./caddy/data:/data
      - ./caddy/config:/config
```

```shell
docker compose -f docker-compose.yml up -d
```

WebDAV 客户端连接地址为 `https://dav.example.com/`。客户端使用的域名需解析到可访问的服务地址。

DNS-01 通过创建 DNS TXT 记录完成验证，无需为证书验证开放入站 80/443 端口；上例发布 443 端口用于访问 WebDAV。容器需能访问 ACME 服务、Cloudflare API 和公共 DNS。也可将站点域名改为 `*.example.com` 申请通配符证书。[Caddy DNS 验证说明](https://caddyserver.com/docs/automatic-https#dns-challenge)

其他 DNS 服务商需要在 [Dockerfile](Dockerfile) 的 `xcaddy build` 中加入对应的 `caddy-dns` 插件，并按插件文档调整 `tls` 配置与运行时凭据。当前镜像内置的 DNS 插件为 Cloudflare。
