#!/usr/bin/env bash
# Memory usage - cross-platform (macOS / Linux)

if [[ "$(uname)" == "Darwin" ]]; then
    total_pages=$(sysctl -n hw.memsize)
    total_gb=$(echo "scale=1; $total_pages / 1073741824" | bc)

    # vm_stat gives pages; page size is 16384 on Apple Silicon, 4096 on Intel
    page_size=$(pagesize 2>/dev/null || echo 4096)
    vm=$(vm_stat)
    free_pages=$(echo "$vm" | awk '/Pages free/ {gsub(/\./,""); print $3}')
    spec_pages=$(echo "$vm" | awk '/Pages speculative/ {gsub(/\./,""); print $3}')
    inac_pages=$(echo "$vm" | awk '/Pages inactive/ {gsub(/\./,""); print $3}')
    free_gb=$(echo "scale=1; ($free_pages + $spec_pages + $inac_pages) * $page_size / 1073741824" | bc)
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
