#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
DOCKER_DIR="${ROOT_DIR}/docker"

HUB_NAMESPACE="alanway"
ALIYUN_NAMESPACE="registry.cn-hangzhou.aliyuncs.com/alanwei"

usage() {
    cat <<'EOF'
用法: d.sh <command> [options]

命令:
  list                    列出所有 Dockerfile 对应的 Docker tag
  build [--tag TAG]       构建指定镜像；未指定 --tag 时构建全部镜像
  push-hub [--tag TAG]    推送到 Docker Hub；未指定 --tag 时推送全部镜像
  push-aliyun [--tag TAG] 推送到阿里云；未指定 --tag 时推送全部镜像
  help                    显示此帮助文档

选项:
  --tag TAG               指定要操作的 Docker tag
EOF
}

die() {
    printf '错误: %s\n' "$*" >&2
    exit 1
}

docker_tag_for_file() {
    local dockerfile="$1"
    local relative_dir
    local image_name
    local image_tag

    relative_dir="${dockerfile#"${DOCKER_DIR}/"}"
    relative_dir="${relative_dir%/Dockerfile}"

    image_name="${relative_dir%%/*}"
    image_tag="${relative_dir#*/}"

    if [[ "${image_name}" == "${image_tag}" || "${image_tag}" == */* ]]; then
        die "Dockerfile 路径必须为 docker/<镜像名>/<版本名>/Dockerfile: ${dockerfile}"
    fi

    printf '%s:%s\n' "${image_name}" "${image_tag}"
}

load_dockerfiles() {
    [[ -d "${DOCKER_DIR}" ]] || die "docker 目录不存在: ${DOCKER_DIR}"

    mapfile -d '' DOCKERFILES < <(
        find "${DOCKER_DIR}" -type f -name Dockerfile -print0 | LC_ALL=C sort -z
    )

    ((${#DOCKERFILES[@]} > 0)) || die "docker 目录下没有找到 Dockerfile"
}

find_dockerfile_by_tag() {
    local wanted_tag="$1"
    local dockerfile
    local current_tag
    local matched_file=""

    for dockerfile in "${DOCKERFILES[@]}"; do
        current_tag="$(docker_tag_for_file "${dockerfile}")"
        if [[ "${current_tag}" == "${wanted_tag}" ]]; then
            [[ -z "${matched_file}" ]] || die "多个 Dockerfile 对应同一个 tag: ${wanted_tag}"
            matched_file="${dockerfile}"
        fi
    done

    [[ -n "${matched_file}" ]] || die "找不到 Docker tag: ${wanted_tag}"
    printf '%s\n' "${matched_file}"
}

select_dockerfiles() {
    local requested_tag="$1"

    if [[ -n "${requested_tag}" ]]; then
        SELECTED_DOCKERFILES=("$(find_dockerfile_by_tag "${requested_tag}")")
    else
        SELECTED_DOCKERFILES=("${DOCKERFILES[@]}")
    fi
}

parse_tag_option() {
    TAG=""

    while (($# > 0)); do
        case "$1" in
            --tag)
                (($# >= 2)) || die "--tag 缺少参数"
                [[ -z "${TAG}" ]] || die "--tag 只能指定一次"
                TAG="$2"
                shift 2
                ;;
            --tag=*)
                [[ -z "${TAG}" ]] || die "--tag 只能指定一次"
                TAG="${1#--tag=}"
                [[ -n "${TAG}" ]] || die "--tag 缺少参数"
                shift
                ;;
            *)
                die "未知选项: $1"
                ;;
        esac
    done
}

list_images() {
    local index=1
    local dockerfile

    printf '序号 Docker Tag\n'
    for dockerfile in "${DOCKERFILES[@]}"; do
        printf '%d. %s\n' "${index}" "$(docker_tag_for_file "${dockerfile}")"
        ((index += 1))
    done
}

build_images() {
    local dockerfile
    local image_dir
    local image_tag

    for dockerfile in "${SELECTED_DOCKERFILES[@]}"; do
        image_dir="$(dirname -- "${dockerfile}")"
        image_tag="$(docker_tag_for_file "${dockerfile}")"
        printf '构建镜像 %s\n' "${image_tag}"
        (
            cd -- "${image_dir}"
            if [[ -f init.sh ]]; then
                printf '执行初始化脚本 %s\n' "${image_dir}/init.sh"
                bash ./init.sh
            fi
            docker build --tag "${image_tag}" --file Dockerfile ./
        )
    done
}

push_images() {
    local namespace="$1"
    local dockerfile
    local image_tag
    local remote_tag

    for dockerfile in "${SELECTED_DOCKERFILES[@]}"; do
        image_tag="$(docker_tag_for_file "${dockerfile}")"
        remote_tag="${namespace}/${image_tag}"
        printf '推送镜像 %s -> %s\n' "${image_tag}" "${remote_tag}"
        docker tag "${image_tag}" "${remote_tag}"
        docker push "${remote_tag}"
    done
}

main() {
    local command="${1:-help}"
    if (($# > 0)); then
        shift
    fi

    case "${command}" in
        help|-h|--help)
            (($# == 0)) || die "help 命令不接受参数"
            usage
            ;;
        list)
            (($# == 0)) || die "list 命令不接受参数"
            load_dockerfiles
            list_images
            ;;
        build|push-hub|push-aliyun)
            parse_tag_option "$@"
            load_dockerfiles
            select_dockerfiles "${TAG}"
            case "${command}" in
                build) build_images ;;
                push-hub) push_images "${HUB_NAMESPACE}" ;;
                push-aliyun) push_images "${ALIYUN_NAMESPACE}" ;;
            esac
            ;;
        *)
            printf '错误: 未知命令: %s\n\n' "${command}" >&2
            usage >&2
            exit 1
            ;;
    esac
}

main "$@"
