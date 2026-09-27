#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mode="${1:-}"

case "${mode}" in
    all)
        mapfile -t dockerfiles < <(
            cd -- "${ROOT_DIR}"
            find docker -type f -name Dockerfile | LC_ALL=C sort
        )
        ;;
    changed)
        (($# == 3)) || { echo 'Usage: changed-images.sh changed BEFORE_SHA AFTER_SHA' >&2; exit 1; }
        before_sha="$2"
        after_sha="$3"
        empty_tree="$(git -C "${ROOT_DIR}" hash-object -t tree /dev/null)"
        zero_sha="0000000000000000000000000000000000000000"

        if [[ "${before_sha}" == "${zero_sha}" ]]; then
            base="${empty_tree}"
        else
            if ! git -C "${ROOT_DIR}" cat-file -e "${before_sha}^{commit}" 2>/dev/null; then
                git -C "${ROOT_DIR}" fetch --no-tags --depth=1 origin "${before_sha}" || true
            fi
            if git -C "${ROOT_DIR}" cat-file -e "${before_sha}^{commit}" 2>/dev/null; then
                base="${before_sha}"
            elif git -C "${ROOT_DIR}" cat-file -e "${after_sha}^" 2>/dev/null; then
                echo 'Warning: push base unavailable; comparing with previous commit.' >&2
                base="${after_sha}^"
            else
                echo 'Warning: no parent commit; comparing with empty tree.' >&2
                base="${empty_tree}"
            fi
        fi

        mapfile -t dockerfiles < <(
            git -C "${ROOT_DIR}" diff --name-only --diff-filter=ACMRT "${base}" "${after_sha}" -- \
                ':(glob)docker/**/Dockerfile' | LC_ALL=C sort -u
        )
        ;;
    *)
        echo 'Usage: changed-images.sh all | changed BEFORE_SHA AFTER_SHA' >&2
        exit 1
        ;;
esac

images=()
for dockerfile in "${dockerfiles[@]}"; do
    [[ -f "${ROOT_DIR}/${dockerfile}" ]] || continue
    if [[ "${dockerfile}" =~ ^docker/([^/]+)/([^/]+)/Dockerfile$ ]]; then
        images+=("${BASH_REMATCH[1]}:${BASH_REMATCH[2]}")
    else
        echo "Invalid Dockerfile path: ${dockerfile}" >&2
        exit 1
    fi
done

printf '%s\n' "${images[@]}" | jq -R -s -c 'split("\n") | map(select(length > 0))'
