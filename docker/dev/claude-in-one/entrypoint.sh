#!/usr/bin/env bash

set -Eeuo pipefail

child_pids=()

terminate_children() {
    trap - EXIT INT TERM

    for pid in "${child_pids[@]}"; do
        kill -TERM "${pid}" 2>/dev/null || true
    done

    for pid in "${child_pids[@]}"; do
        wait "${pid}" 2>/dev/null || true
    done
}

trap terminate_children EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ -f /data/config/code-server.yml ]]; then
    code-server --config /data/config/code-server.yml "$WEB_APP_DIR" &
    child_pids+=("$!")
fi

if [[ -f "$WEB_APP_DIR/control.sh" ]]; then
    (cd "$WEB_APP_DIR" && bash ./control.sh start)
fi

if [[ -f /data/config/Caddyfile ]]; then
    caddy run --config /data/config/Caddyfile --adapter caddyfile &
    child_pids+=("$!")
fi

if (( ${#child_pids[@]} > 0 )); then
    wait -n "${child_pids[@]}"
fi
