#!/usr/bin/env bash
# window_tabs.sh — colored per-window tab bar for tmux status line
#
# Active tab:   colored rounded pill using Nerd Font powerline glyphs
# Inactive tab: dim colored label
# Each window index cycles through a distinct color palette
#
# Label logic:
#   ssh session      → user@host
#   program running  → folder>program
#   shell idle       → folder

# 8-color palette — sky, purple, green, amber, coral, cyan, gold, pink
COLORS=(colour75 colour141 colour82 colour214 colour203 colour51 colour220 colour177 colour208)
NUM_COLORS=${#COLORS[@]}

# Nerd Font soft rounded powerline caps (U+E0B6, U+E0B4)
# Using printf hex for bash 3.x / macOS sh compatibility
L_CAP=$(printf '\xee\x82\xb6')   # left  rounded cap
R_CAP=$(printf '\xee\x82\xb4')   # right rounded cap

# Known shell names — these mean "idle at prompt"
SHELLS="|zsh|bash|fish|sh|dash|ksh|tcsh|csh|"

output=""

while IFS='|' read -r idx cmd path pid active activity zoomed; do
    color=${COLORS[$(( (idx - 1) % NUM_COLORS ))]}
    dir=$(basename "$path")

    # Determine display label
    if [[ "$cmd" == "ssh" ]]; then
        # Find the ssh child process and extract its target argument
        ssh_target=$(ps -eo ppid=,args= 2>/dev/null \
            | awk -v ppid="$pid" '$1==ppid && $2~/^ssh$/ {print $NF; exit}')
        label="${ssh_target:-ssh}"
    elif [[ "$SHELLS" == *"|${cmd}|"* ]]; then
        # Shell at prompt — show directory name only
        label="$dir"
    else
        # Foreground program running — show folder>program
        label="${dir}>${cmd}"
    fi

    flags=""
    [[ "$zoomed"   == "1" ]] && flags+=" Z"
    [[ "$activity" == "1" ]] && flags+="!"

    if [[ "$active" == "1" ]]; then
        # Active: soft rounded pill  idx:label
        output+="#[bg=default,fg=${color}]${L_CAP}#[bg=${color},fg=colour232,bold] ${idx}:${label}${flags} #[bg=default,fg=${color}]${R_CAP}#[default] "
    else
        # Inactive: dim colored label
        output+="#[fg=${color},nobold,dim] ${idx}:${label}${flags} #[default]"
    fi
done < <(tmux list-windows -F '#{window_index}|#{pane_current_command}|#{pane_current_path}|#{pane_pid}|#{window_active}|#{window_activity_flag}|#{window_zoomed_flag}' 2>/dev/null)

printf "%s" "$output"
