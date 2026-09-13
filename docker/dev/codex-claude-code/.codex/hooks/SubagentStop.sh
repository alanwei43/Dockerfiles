#!/usr/bin/env bash
set -eu

log_dir="${HOME}/logs"
mkdir -p "${log_dir}"
{
    printf '\n[%s] SubagentStop\n' "$(date --utc '+%Y-%m-%dT%H:%M:%SZ')"
    cat
} >> "${log_dir}/SubagentStop.log"
