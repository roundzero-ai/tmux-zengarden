#!/usr/bin/env bash
# CPU usage - cross-platform (macOS / Linux)

if [[ "$(uname)" == "Darwin" ]]; then
    cpu=$(top -l 1 -s 0 | awk '/CPU usage/ {gsub(/%/,""); print int($3 + $5)}')
else
    cpu=$(top -bn1 | awk '/^%Cpu/ {printf "%.0f", 100 - $8}')
fi

if   (( cpu >= 80 )); then color="#[fg=colour196]"
elif (( cpu >= 50 )); then color="#[fg=colour214]"
else                       color="#[fg=colour82]"
fi

printf "${color}CPU %3d%%#[default]" "$cpu"
