#!/usr/bin/env bash
# pane_git.sh — pane context for pane-border-format
# Usage: pane_git.sh <path> [pane_pid]

path="${1:-$PWD}"
pane_pid="${2:-}"

dir_name="${path##*/}"
[[ -z "$dir_name" || "$path" == "/" ]] && dir_name="/"

venv_name=""
if [[ -n "$pane_pid" ]]; then
    pane_cmd=$(ps eww -p "$pane_pid" -o command= 2>/dev/null)
    if [[ "$pane_cmd" =~ (^|[[:space:]])VIRTUAL_ENV=([^[:space:]]+) ]]; then
        venv_path="${BASH_REMATCH[2]}"
        venv_name="${venv_path##*/}"
    elif [[ "$pane_cmd" =~ (^|[[:space:]])CONDA_DEFAULT_ENV=([^[:space:]]+) ]]; then
        venv_name="${BASH_REMATCH[2]}"
    elif [[ -d "$path/.venv" ]]; then
        venv_name=".venv"
    fi
fi

printf '#[fg=colour244]dir:#[fg=colour51] %s' "$dir_name"

if [[ -n "$venv_name" ]]; then
    printf ' #[fg=colour244]venv:#[fg=colour220] %s' "$venv_name"
fi

cd "$path" 2>/dev/null || exit 0
branch=$(git branch --show-current 2>/dev/null)
[[ -z "$branch" ]] && exit 0

if git status --porcelain 2>/dev/null | grep -q .; then
    printf ' #[fg=colour244]git:#[fg=colour214] %s*' "$branch"
else
    printf ' #[fg=colour244]git:#[fg=colour82] %s' "$branch"
fi
