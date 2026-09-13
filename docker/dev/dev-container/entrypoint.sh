#!/usr/bin/env bash

set -Eeuo pipefail

child_pids=()

terminate_children() {
    trap - INT TERM

    for pid in "${child_pids[@]}"; do
        kill -TERM "${pid}" 2>/dev/null || true
    done

    for pid in "${child_pids[@]}"; do
        wait "${pid}" 2>/dev/null || true
    done
}

trap 'terminate_children; exit 130' INT
trap 'terminate_children; exit 143' TERM

if [[ -f /data/config.yaml ]]; then
    code-server --config /data/config.yaml /app &
elif [[ -n "${PASSWORD:-}" ]]; then
    code-server --bind-addr 0.0.0.0:8080 --auth password /app &
else
    code-server --bind-addr 0.0.0.0:8080 --auth none /app &
fi
child_pids+=("$!")

(
    cd /app
    exec opencode web --hostname 0.0.0.0 --port 8090
) &
child_pids+=("$!")

set +e
wait -n "${child_pids[@]}"
exit_status="$?"
set -e

terminate_children
exit "${exit_status}"
