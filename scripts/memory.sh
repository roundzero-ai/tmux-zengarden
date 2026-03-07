#!/usr/bin/env bash
# Memory usage - cross-platform (macOS / Linux)

if [[ "$(uname)" == "Darwin" ]]; then
    total_bytes=$(sysctl -n hw.memsize)
    total_gb=$(echo "scale=1; $total_bytes / 1073741824" | bc)

    # Parse page size from vm_stat header (16384 on Apple Silicon, 4096 on Intel)
    vm=$(vm_stat)
    page_size=$(echo "$vm" | awk -F'[()]' '/page size of/{gsub(/[^0-9]/,"",$2); print $2}')
    page_size=${page_size:-16384}
    free_pages=$(echo "$vm" | awk '/Pages free/ {gsub(/\./,""); print $3}')
    spec_pages=$(echo "$vm" | awk '/Pages speculative/ {gsub(/\./,""); print $3}')
    inac_pages=$(echo "$vm" | awk '/Pages inactive/ {gsub(/\./,""); print $3}')
    free_gb=$(echo "scale=1; (${free_pages:-0} + ${spec_pages:-0} + ${inac_pages:-0}) * $page_size / 1073741824" | bc)
    used_gb=$(echo "scale=1; $total_gb - $free_gb" | bc)
    pct=$(echo "scale=0; ($used_gb * 100) / $total_gb" | bc)
else
    read used total <<< $(free -m | awk '/^Mem/ {printf "%d %d", $3, $2}')
    pct=$(( used * 100 / total ))
    used_gb=$(echo "scale=1; $used / 1024" | bc)
    total_gb=$(echo "scale=1; $total / 1024" | bc)
fi

if   (( pct >= 85 )); then color="#[fg=colour196]"
elif (( pct >= 60 )); then color="#[fg=colour214]"
else                       color="#[fg=colour82]"
fi

printf "${color}MEM %.1fG %d%%#[default]" "$used_gb" "$pct"
