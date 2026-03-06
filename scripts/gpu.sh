#!/usr/bin/env bash
# GPU usage - cross-platform, no sudo required
#
# macOS (Apple Silicon & Intel):
#   Uses ioreg IOAccelerator PerformanceStatistics — no sudo needed
#
# Linux / DGX Spark (GB10 Grace Blackwell, unified memory):
#   nvidia-smi utilization.gpu works; memory.used returns "Not Supported" on UMA

if [[ "$(uname)" == "Darwin" ]]; then
    # ioreg exposes GPU Device Utilization % without any elevated privileges
    util=$(ioreg -r -d 1 -c IOAccelerator 2>/dev/null \
           | grep "PerformanceStatistics" \
           | grep -o '"Device Utilization %"=[0-9]*' \
           | grep -o '[0-9]*$' \
           | head -1)

    if [[ -n "$util" ]] && [[ "$util" =~ ^[0-9]+$ ]]; then
        if   (( util >= 80 )); then color="#[fg=colour196]"
        elif (( util >= 50 )); then color="#[fg=colour214]"
        else                       color="#[fg=colour141]"
        fi
        printf "${color}GPU %3d%%#[default]" "$util"
    else
        printf "#[fg=colour244]GPU  N/A#[default]"
    fi

elif command -v nvidia-smi &>/dev/null; then
    util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null \
           | head -1 | tr -d ' ')

    # Bail if util is empty or not a number (driver issue)
    if [[ -z "$util" ]] || ! [[ "$util" =~ ^[0-9]+$ ]]; then
        printf "#[fg=colour244]GPU  N/A#[default]"
        exit 0
    fi

    if   (( util >= 80 )); then color="#[fg=colour196]"
    elif (( util >= 50 )); then color="#[fg=colour214]"
    else                       color="#[fg=colour141]"
    fi

    # Try memory — DGX Spark GB10 unified memory returns "Not Supported"
    mem_used=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null \
               | head -1 | tr -d ' ')

    if [[ "$mem_used" =~ ^[0-9]+$ ]]; then
        # Discrete GPU with dedicated VRAM (standard server/desktop GPU)
        mem_gb=$(echo "scale=0; $mem_used / 1024" | bc)
        printf "${color}GPU %3d%% %dG#[default]" "$util" "$mem_gb"
    else
        # Unified memory (DGX Spark GB10 Grace Blackwell) — memory is shared system RAM
        printf "${color}GPU %3d%% UMA#[default]" "$util"
    fi
else
    printf "#[fg=colour244]GPU  ---#[default]"
fi
