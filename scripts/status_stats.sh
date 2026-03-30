#!/usr/bin/env bash

set -u

CACHE_DIR="${TMPDIR:-/tmp}/tmux-zengarden-${UID:-$(id -u)}"
CACHE_FILE="$CACHE_DIR/status-stats.cache"
TTL=4

mkdir -p "$CACHE_DIR"

now=$(date +%s)
if [[ -r "$CACHE_FILE" ]]; then
    read -r cached_at cached_line < "$CACHE_FILE" || true
    if [[ -n "${cached_at:-}" && "$cached_at" =~ ^[0-9]+$ ]] && (( now - cached_at < TTL )); then
        printf '%s' "${cached_line:-}"
        exit 0
    fi
fi

cpu=0
mem_used_tenths=0
mem_pct=0
gpu_label="#[fg=colour244]GPU  ---#[default]"
os=$(uname)

if [[ "$os" == "Darwin" ]]; then
    cpu=$(top -l 1 -s 0 | awk '/CPU usage/ {gsub(/%/, "", $3); gsub(/%/, "", $5); print int($3 + $5); exit}')

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
    mem_used_tenths=$(( used_bytes * 10 / 1073741824 ))
    mem_pct=$(( used_bytes * 100 / total_bytes ))

    util=$(ioreg -r -d 1 -c IOAccelerator 2>/dev/null | awk -F'=|"' '/Device Utilization %/ {gsub(/[^0-9]/, "", $3); print $3; exit}')
    if [[ -n "$util" && "$util" =~ ^[0-9]+$ ]]; then
        if   (( util >= 80 )); then gpu_color="colour196"
        elif (( util >= 50 )); then gpu_color="colour214"
        else                       gpu_color="colour141"
        fi
        gpu_label=$(printf '#[fg=%s]GPU %3d%%#[default]' "$gpu_color" "$util")
    else
        gpu_label='#[fg=colour244]GPU  N/A#[default]'
    fi
else
    cpu=$(top -bn1 | awk '/^%Cpu/ {printf "%.0f", 100 - $8; exit}')

    read -r used total <<< "$(free -m | awk '/^Mem/ {printf "%d %d", $3, $2; exit}')"
    if [[ -n "${used:-}" && -n "${total:-}" && "$total" -gt 0 ]]; then
        mem_pct=$(( used * 100 / total ))
        mem_used_tenths=$(( used * 10 / 1024 ))
    fi

    if command -v nvidia-smi >/dev/null 2>&1; then
        IFS=',' read -r util mem_used <<< "$(nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv,noheader,nounits 2>/dev/null | awk 'NR==1 {gsub(/ /, "", $1); gsub(/ /, "", $2); print $1 "," $2}')"
        if [[ -n "$util" && "$util" =~ ^[0-9]+$ ]]; then
            if   (( util >= 80 )); then gpu_color="colour196"
            elif (( util >= 50 )); then gpu_color="colour214"
            else                       gpu_color="colour141"
            fi

            if [[ -n "$mem_used" && "$mem_used" =~ ^[0-9]+$ ]]; then
                mem_gb=$(( mem_used / 1024 ))
                gpu_label=$(printf '#[fg=%s]GPU %3d%% %dG#[default]' "$gpu_color" "$util" "$mem_gb")
            else
                gpu_label=$(printf '#[fg=%s]GPU %3d%% UMA#[default]' "$gpu_color" "$util")
            fi
        else
            gpu_label='#[fg=colour244]GPU  N/A#[default]'
        fi
    fi
fi

if [[ -z "$cpu" || ! "$cpu" =~ ^[0-9]+$ ]]; then
    cpu=0
fi

if   (( cpu >= 80 )); then cpu_color='colour196'
elif (( cpu >= 50 )); then cpu_color='colour214'
else                       cpu_color='colour82'
fi

if   (( mem_pct >= 85 )); then mem_color='colour196'
elif (( mem_pct >= 60 )); then mem_color='colour214'
else                          mem_color='colour82'
fi

mem_whole=$(( mem_used_tenths / 10 ))
mem_frac=$(( mem_used_tenths % 10 ))

line=$(printf '#[fg=%s]CPU %3d%%#[default] #[fg=colour238]│ #[fg=%s]MEM %d.%dG %d%%#[default] #[fg=colour238]│ %s' \
    "$cpu_color" "$cpu" "$mem_color" "$mem_whole" "$mem_frac" "$mem_pct" "$gpu_label")

printf '%s %s\n' "$now" "$line" > "$CACHE_FILE"
printf '%s' "$line"
