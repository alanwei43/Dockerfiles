# Alpine 

## 简介

软件源设置成 [Aliyun](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/).

## 使用

```sh
docker run -it --rm alanway/ubuntu:20.04 bash
# 或者
docker run -it --rm registry.cn-hangzhou.aliyuncs.com/alanwei/ubuntu:20.04 bash
```

## Alpine 包管理

Alpine包管理Wiki: [Alpine Linux package management](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management)

```sh
# Update the Package list
apk update 

# Add a Package
apk add openssh 
apk add openssh openntp vim

# This will tell apk to use that particular repository
apk add cherokee --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

# Add a local Package
apk add --allow-untrusted /path/to/file.apk

# Remove a Package
apk del openssh
apk del openssh openntp vim

# To upgrade only specific packages, use the -u or --upgrade option of the add command: 
apk update
apk add --upgrade busybox 

# To list all packages are part of the ACF system: 
apk search -v 'acf*' 

# To list all packages that list NTP as part of their description, use the -d or --description option: 
apk search -v --description 'NTP' 

# Information on Packages
apk info -a zlib
```