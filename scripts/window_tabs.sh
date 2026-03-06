#!/usr/bin/env bash
# window_tabs.sh — colored per-window tab bar for tmux status line
#
# Active tab:   colored rounded pill using Nerd Font powerline glyphs
# Inactive tab: dim colored label
# Each window index cycles through a distinct color palette

# 8-color palette — sky, purple, green, amber, coral, cyan, gold, pink
COLORS=(colour75 colour141 colour82 colour214 colour203 colour51 colour220 colour177)
NUM_COLORS=${#COLORS[@]}

# Nerd Font soft rounded powerline caps (U+E0B6, U+E0B4)
# Using printf hex for bash 3.x / macOS sh compatibility
L_CAP=$(printf '\xee\x82\xb6')   # left  rounded cap
R_CAP=$(printf '\xee\x82\xb4')   # right rounded cap

output=""

while IFS='|' read -r idx name active activity zoomed; do
    color=${COLORS[$(( (idx - 1) % NUM_COLORS ))]}

    flags=""
    [[ "$zoomed"   == "1" ]] && flags+=" Z"
    [[ "$activity" == "1" ]] && flags+="!"

    if [[ "$active" == "1" ]]; then
        # Active: soft rounded pill  idx:name
        output+="#[bg=default,fg=${color}]${L_CAP}#[bg=${color},fg=colour232,bold] ${idx}:${name}${flags} #[bg=default,fg=${color}]${R_CAP}#[default] "
    else
        # Inactive: dim colored label
        output+="#[fg=${color},nobold,dim] ${idx}:${name}${flags} #[default]"
    fi
done < <(tmux list-windows -F '#{window_index}|#{window_name}|#{window_active}|#{window_activity_flag}|#{window_zoomed_flag}' 2>/dev/null)

printf "%s" "$output"
