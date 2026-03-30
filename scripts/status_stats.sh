#!/usr/bin/env bash

set -u

CACHE_DIR="${TMPDIR:-/tmp}/tmux-zengarden-${UID:-$(id -u)}"
CACHE_FILE="$CACHE_DIR/status-stats-v3.cache"
TTL=4

mkdir -p "$CACHE_DIR"

now=$(date +%s)
if [[ -r "$CACHE_FILE" ]]; then
    IFS= read -r cached_line < "$CACHE_FILE" || true
    cached_at=${cached_line%% *}
    cached_payload=${cached_line#* }
    if [[ -n "${cached_at:-}" && "$cached_at" =~ ^[0-9]+$ ]] && (( now - cached_at < TTL )); then
        printf '%s' "$cached_payload"
        exit 0
    fi
fi

os=$(uname)
arch=$(uname -m)

cpu_pct=0
mem_used_mb=0
mem_total_mb=0
gpu_pct=""
gpu_used_mb=""
gpu_total_mb=""
gpu_name=""
uma_mode=0

metric_color() {
    local pct=${1:-0}
    if ! [[ "$pct" =~ ^[0-9]+$ ]]; then
        printf 'colour244'
    elif (( pct >= 80 )); then
        printf 'colour196'
    elif (( pct >= 50 )); then
        printf 'colour214'
    else
        printf 'colour82'
    fi
}

format_size_mb() {
    local mb=${1:-0}
    if ! [[ "$mb" =~ ^[0-9]+$ ]]; then
        printf '0M'
    elif (( mb >= 10240 )); then
        printf '%dG' $(( (mb + 512) / 1024 ))
    elif (( mb >= 1024 )); then
        printf '%d.%dG' $(( mb / 1024 )) $(( ((mb % 1024) * 10 + 512) / 1024 ))
    else
        printf '%dM' "$mb"
    fi
}

format_metric() {
    local label=$1
    local used_mb=$2
    local total_mb=$3
    local pct=$4
    local color
    color=$(metric_color "$pct")
    printf '#[fg=%s]%s %s/%s %d%%#[default]' \
        "$color" "$label" "$(format_size_mb "$used_mb")" "$(format_size_mb "$total_mb")" "$pct"
}

format_pct_metric() {
    local label=$1
    local pct=$2
    local color
    color=$(metric_color "$pct")
    printf '#[fg=%s]%s %3d%%#[default]' "$color" "$label" "$pct"
}

if [[ "$os" == "Darwin" ]]; then
    cpu_pct=$(top -l 1 -s 0 | awk '/CPU usage/ {gsub(/%/, "", $3); gsub(/%/, "", $5); print int($3 + $5); exit}')

    total_bytes=$(sysctl -n hw.memsize 2>/dev/null)
    if [[ -z "$total_bytes" || ! "$total_bytes" =~ ^[0-9]+$ || "$total_bytes" -le 0 ]]; then
        total_bytes=1
    fi
    vm=$(vm_stat 2>/dev/null)
    page_size=$(awk -F'[()]' '/page size of/ {gsub(/[^0-9]/, "", $2); print $2; exit}' <<< "$vm")
    page_size=${page_size:-16384}
    read -r free_pages spec_pages inac_pages <<< "$(awk '
        /Pages free/ {gsub(/\./, "", $3); free=$3}
        /Pages speculative/ {gsub(/\./, "", $3); spec=$3}
        /Pages inactive/ {gsub(/\./, "", $3); inac=$3}
        END {print free+0, spec+0, inac+0}
    ' <<< "$vm")"
    free_bytes=$(( (free_pages + spec_pages + inac_pages) * page_size ))
    used_bytes=$(( total_bytes - free_bytes ))
    (( used_bytes < 0 )) && used_bytes=0
    mem_used_mb=$(( used_bytes / 1048576 ))
    mem_total_mb=$(( total_bytes / 1048576 ))

    gpu_pct=$(ioreg -r -d 1 -c IOAccelerator 2>/dev/null | awk -F'Device Utilization %"=' '/Device Utilization %/ {
        split($2, a, /[^0-9]/)
        print a[1]
        exit
    }')
    [[ "$arch" == "arm64" ]] && uma_mode=1
elif command -v tegrastats >/dev/null 2>&1; then
    tegra_line=$(timeout 2 tegrastats --interval 1000 2>/dev/null | awk 'NR==1 {print; exit}')
    cpu_pct=$(echo "$tegra_line" | sed -E 's/.*CPU \[([0-9%@,]+)\].*/\1/' | awk -F',' '
        {
            total=0; count=0
            for (i=1; i<=NF; i++) {
                if ($i ~ /%@/) {
                    gsub(/%@.*/, "", $i)
                    total += $i + 0
                    count++
                }
            }
            if (count > 0) printf "%d", total / count
            else print 0
        }')
    mem_used_mb=$(echo "$tegra_line" | sed -E 's/.*RAM ([0-9]+)\/([0-9]+)MB.*/\1/')
    mem_total_mb=$(echo "$tegra_line" | sed -E 's/.*RAM ([0-9]+)\/([0-9]+)MB.*/\2/')
    gpu_pct=$(echo "$tegra_line" | sed -E 's/.*GR3D_FREQ ([0-9]+)%.*/\1/')
    uma_mode=1
else
    cpu_pct=$(top -bn1 | awk '/^%Cpu/ {printf "%.0f", 100 - $8; exit}')
    read -r mem_used_mb mem_total_mb <<< "$(free -m | awk '/^Mem/ {printf "%d %d", $3, $2; exit}')"

    if command -v nvidia-smi >/dev/null 2>&1; then
        gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | awk 'NR==1 {sub(/^[[:space:]]+/, ""); sub(/[[:space:]]+$/, ""); print; exit}')
        IFS=',' read -r gpu_pct gpu_used_mb gpu_total_mb <<< "$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | awk -F',' 'NR==1 {
            for (i=1; i<=3; i++) {
                gsub(/^[[:space:]]+/, "", $i)
                gsub(/[[:space:]]+$/, "", $i)
            }
            print $1 "," $2 "," $3
            exit
        }')"
        if [[ "$gpu_name" =~ (GB10|DGX[[:space:]]+Spark) ]]; then
            uma_mode=1
            gpu_used_mb=""
            gpu_total_mb=""
        elif [[ ! "$gpu_used_mb" =~ ^[0-9]+$ || ! "$gpu_total_mb" =~ ^[0-9]+$ ]]; then
            gpu_used_mb=""
            gpu_total_mb=""
        fi
    fi
fi

if [[ -z "$cpu_pct" || ! "$cpu_pct" =~ ^[0-9]+$ ]]; then
    cpu_pct=0
fi
if [[ -z "$mem_used_mb" || ! "$mem_used_mb" =~ ^[0-9]+$ ]]; then
    mem_used_mb=0
fi
if [[ -z "$mem_total_mb" || ! "$mem_total_mb" =~ ^[0-9]+$ || "$mem_total_mb" -le 0 ]]; then
    mem_total_mb=1
fi
mem_pct=$(( mem_used_mb * 100 / mem_total_mb ))

parts=()
parts+=("$(format_pct_metric CPU "$cpu_pct")")

if (( uma_mode )); then
    parts+=("$(format_metric UMA "$mem_used_mb" "$mem_total_mb" "$mem_pct")")
else
    parts+=("$(format_metric RAM "$mem_used_mb" "$mem_total_mb" "$mem_pct")")
fi

if [[ -n "$gpu_pct" && "$gpu_pct" =~ ^[0-9]+$ ]]; then
    parts+=("$(format_pct_metric GPU "$gpu_pct")")
else
    parts+=("#[fg=colour244]GPU  N/A#[default]")
fi

if (( ! uma_mode )); then
    if [[ -n "$gpu_used_mb" && "$gpu_used_mb" =~ ^[0-9]+$ && -n "$gpu_total_mb" && "$gpu_total_mb" =~ ^[0-9]+$ && "$gpu_total_mb" -gt 0 ]]; then
        gpu_mem_pct=$(( gpu_used_mb * 100 / gpu_total_mb ))
        parts+=("$(format_metric VRAM "$gpu_used_mb" "$gpu_total_mb" "$gpu_mem_pct")")
    else
        parts+=("#[fg=colour244]VRAM N/A#[default]")
    fi
fi

line=''
for i in "${!parts[@]}"; do
    (( i > 0 )) && line+=" #[fg=colour238]│ "
    line+="${parts[$i]}"
done

printf '%s %s\n' "$now" "$line" > "$CACHE_FILE"
printf '%s' "$line"
