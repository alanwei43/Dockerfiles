# Caddy WebDAV 镜像调研

调研日期：2026-09-13

本仓库此前没有独立调研笔记目录，因此将本次上游调研放在 `docs/research/`。以下只采用项目 README、源码、官方 Caddy 文档与官方镜像源码。

## 结论

推荐用官方 Caddy builder 和运行时镜像做多阶段构建：builder 阶段通过 `xcaddy` 加入 `github.com/mholt/caddy-webdav`，运行时阶段只把生成的 `/usr/bin/caddy` 覆盖到同版本的官方 Caddy 镜像。官方镜像文档明确推荐这一模式，第二阶段能保留官方镜像的运行目录、证书存储、端口、能力和启动命令，同时避免把 Go、Git、xcaddy 等构建工具带入最终镜像。[官方镜像的自定义模块示例](https://hub.docker.com/_/caddy#adding-custom-caddy-modules)、[官方 Alpine 运行时 Dockerfile](https://github.com/caddyserver/caddy-docker/blob/fba2853501d36e8a72f946ac8cb7ff64d07e48f2/2.11/alpine/Dockerfile)、[官方 builder Dockerfile](https://github.com/caddyserver/caddy-docker/blob/fba2853501d36e8a72f946ac8cb7ff64d07e48f2/2.11/builder/Dockerfile)

建议的构建核心如下（版本号应作为 Dockerfile `ARG` 固定，并确保两个 `FROM` 使用相同 Caddy 版本）：

```dockerfile
ARG CADDY_VERSION=2.11.4
ARG CADDY_WEBDAV_COMMIT=fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder
ARG CADDY_WEBDAV_COMMIT
RUN xcaddy build \
    --with github.com/mholt/caddy-webdav@${CADDY_WEBDAV_COMMIT}

FROM caddy:${CADDY_VERSION}-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

`caddy-webdav` 自己给出的推荐命令是 `xcaddy build --with github.com/mholt/caddy-webdav`；上面的命令仅增加完整提交 SHA，以得到可复现的镜像。[插件 README](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/README.md)、[xcaddy 自定义构建语法](https://github.com/caddyserver/xcaddy#custom-builds)

## 版本策略

- Caddy 和官方 builder/runtime 镜像应使用明确版本，不要用 `latest`。官方镜像文档也明确提醒生产镜像不要使用 `latest`，并展示了 builder 与 runtime 使用同一 `<version>` 的多阶段构建。[官方镜像文档](https://hub.docker.com/_/caddy#building-your-own-caddy-based-image)
- `xcaddy build [<caddy_version>] --with <module[@version]>` 支持给 Caddy 核心和插件分别指定标签、分支或提交；不指定 Caddy 版本时默认构建最新 Caddy，`--with` 的版本语义与 `go get` 相同。[xcaddy README](https://github.com/caddyserver/xcaddy#custom-builds)
- `caddy-webdav` 的模块路径是 `github.com/mholt/caddy-webdav`。[go.mod](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/go.mod)
- 截至调研日，上游没有 tag 或 GitHub Release；`master`/HEAD 为 `fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b`。因此不能使用语义化发布版本，推荐固定完整提交 SHA，升级时人工更新 SHA 并重新做静态检查。[Tags 页面](https://github.com/mholt/caddy-webdav/tags)、[Releases 页面](https://github.com/mholt/caddy-webdav/releases)、[提交记录](https://github.com/mholt/caddy-webdav/commits/master/)
- 当前插件 `go.mod` 声明 `go 1.23.0`、`toolchain go1.24.5`，且其历史直接依赖仍写为 Caddy `v2.5.2`。这是插件仓库自身的模块元数据，不等同于只支持 Caddy 2.5.2；最终依赖图由 xcaddy/Go 在构建指定 Caddy 版本时解析。升级 Caddy 或插件提交后，应至少让构建流程验证模块仍能编译，并通过 `caddy list-modules` 确认 `http.handlers.webdav` 存在。[插件 go.mod](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/go.mod)、[模块 ID 源码](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/webdav.go#L56-L61)

## 运行时要求

- WebDAV 插件编译进 Caddy 二进制后，最终镜像不需要 Go 或 xcaddy；官方推荐复制自定义二进制到常规 Caddy 运行时镜像。[官方镜像文档](https://hub.docker.com/_/caddy#adding-custom-caddy-modules)
- 保留官方镜像的 `/etc/caddy/Caddyfile`、`/srv` 工作目录、`/data`、`/config`、80/443 TCP、443 UDP，以及 `caddy run --config /etc/caddy/Caddyfile --adapter caddyfile` 启动约定。官方镜像设置 `XDG_DATA_HOME=/data` 与 `XDG_CONFIG_HOME=/config`；其中 `/data` 保存 TLS 证书、私钥等关键资产，必须可写并持久化。[官方运行时 Dockerfile](https://github.com/caddyserver/caddy-docker/blob/fba2853501d36e8a72f946ac8cb7ff64d07e48f2/2.11/alpine/Dockerfile)、[Caddy 文件位置约定](https://caddyserver.com/docs/conventions#file-locations)
- WebDAV 共享目录本身也必须对 Caddy 进程可写，否则 `PUT` 无法工作。容器部署时应挂载共享目录，并按实际运行 UID/GID 配置其所有权或写权限。[插件权限说明](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/README.md#permissions)
- 插件使用 `webdav.NewMemLS()` 保存锁，锁状态只在进程内存中，容器/进程重启后不会保留；这也意味着多个副本之间不会共享锁。这一点是根据源码作出的直接推论。[锁系统源码](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/webdav.go#L64-L71)

## Caddyfile 指令

插件注册的 Caddyfile 指令为：

```caddyfile
webdav [<matcher>] {
    root <path>
    prefix <request-base-path>
}
```

`root` 和 `prefix` 都支持占位符。`root` 未设置时先使用 `{http.vars.root}`，若它也未设置则落到当前工作目录；插件自身只接受 `root`、`prefix` 两个子指令。[Caddyfile 解析源码](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/caddyfile.go)、[处理器字段与默认值](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/webdav.go#L34-L51)

最小全路径 WebDAV 配置可写成：

```caddyfile
{
    order webdav before file_server
}

:80 {
    root /srv
    webdav
}
```

第三方 handler 不在 Caddy 的内置指令顺序中，必须用全局 `order` 指定顺序，或放入 `route` 以保持字面顺序。插件 README 建议与 `file_server` 合用时把 `webdav` 放在它之前。[插件顺序说明](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/README.md#syntax)、[Caddy `order` 文档](https://caddyserver.com/docs/caddyfile/options#order)、[Caddy `route` 文档](https://caddyserver.com/docs/caddyfile/directives/route)

挂在子路径时应显式配置 `prefix`，并把裸 `/dav` 重定向或改写为 `/dav/`：

```caddyfile
:80 {
    root /srv
    route {
        rewrite /dav /dav/
        webdav /dav/* {
            prefix /dav
        }
        file_server
    }
}
```

插件会在响应中使用绝对路径，所以与 matcher 或路径改写组合时 `prefix` 虽是语法上的可选项，实际必须与请求基路径一致。[插件子路径示例与说明](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/README.md#syntax)

## 安全与行为注意事项

- WebDAV handler 本身不提供用户认证或只读开关。源码列出了 GET/HEAD/OPTIONS 和 PUT/DELETE/COPY/MOVE 等读写方法，并留有“集成 Caddy 认证以强制只读”的 TODO。因此暴露到非可信网络时，应在 handler 前配置 Caddy `basic_auth`，或通过 method matcher 明确限制方法。[处理器源码](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/webdav.go#L75-L79)
- Caddy 2.8 之后指令名是 `basic_auth`（旧名 `basicauth`）；密码必须是哈希，不能把明文写入配置。Basic Auth 在明文 HTTP 上不安全，应配合 HTTPS。[Caddy `basic_auth` 文档](https://caddyserver.com/docs/caddyfile/directives/basic_auth)
- 插件对目录的 GET/HEAD 会改按 `PROPFIND` 行为处理（缺少 `Depth` 时设为 `1`）；如需同一路径同时提供普通网页目录列表，需用 method matcher 把 GET/HEAD 交给 `file_server browse`，其余请求交给 WebDAV。[插件 README 示例](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/README.md#syntax)、[GET/HEAD 实现](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/webdav.go#L112-L132)
- 插件仓库属于 `mholt` 个人账号，并非 `caddyserver` 官方组织；镜像说明中应避免把该插件称为官方 Caddy 模块。[插件 README 顶部说明](https://github.com/mholt/caddy-webdav/blob/fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b/README.md)

