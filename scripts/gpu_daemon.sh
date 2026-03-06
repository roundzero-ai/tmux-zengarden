#!/usr/bin/env bash
# Background daemon for macOS Apple Silicon GPU utilization via powermetrics.
# Requires sudo. Run once per login session:
#   sudo ~/Projects/tmux_zengarden/scripts/gpu_daemon.sh &
#
# On Linux with nvidia-smi this daemon is not needed.

if [[ "$(uname)" != "Darwin" ]]; then
    echo "This daemon is for macOS only." >&2
    exit 1
fi

cache_file="${TMPDIR:-/tmp}/tmux_gpu_cache"

while true; do
    util=$(sudo powermetrics -n 1 -i 2000 --samplers gpu_power 2>/dev/null \
           | awk '/GPU HW active/{gsub(/%/,""); print int($NF)}' | head -1)
    [[ -n "$util" ]] && echo "$util" > "$cache_file"
    sleep 5
done
