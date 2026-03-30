#!/usr/bin/env bash
# pane_git.sh — pane context for pane-border-format
# Usage: pane_git.sh <path> [pane_pid] [pane_active]

path="${1:-$PWD}"
pane_pid="${2:-}"
pane_active="${3:-1}"

CACHE_DIR="${TMPDIR:-/tmp}/tmux-zengarden-${UID:-$(id -u)}"
TTL=4

mkdir -p "$CACHE_DIR"

dir_name="${path##*/}"
[[ -z "$dir_name" || "$path" == "/" ]] && dir_name="/"

venv_name=""
if [[ "$pane_active" == "1" && -n "$pane_pid" ]]; then
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

if [[ "$pane_active" != "1" ]]; then
    exit 0
fi

if [[ -n "$venv_name" ]]; then
    printf ' #[fg=colour244]venv:#[fg=colour220] %s' "$venv_name"
fi

repo_root=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null) || exit 0
cache_key=$(printf '%s' "$repo_root" | cksum | awk '{print $1}')
cache_file="$CACHE_DIR/pane-git-${cache_key}.cache"
now=$(date +%s)

if [[ -r "$cache_file" ]]; then
    IFS='|' read -r cached_at branch dirty < "$cache_file" || true
    if [[ -n "${cached_at:-}" && "$cached_at" =~ ^[0-9]+$ ]] && (( now - cached_at < TTL )); then
        :
    else
        branch=""
    fi
else
    branch=""
fi

if [[ -z "${branch:-}" ]]; then
    branch=$(git -C "$repo_root" branch --show-current 2>/dev/null)
    [[ -z "$branch" ]] && branch=$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null)
    [[ -z "$branch" ]] && exit 0

    if git -C "$repo_root" status --porcelain --ignore-submodules=dirty 2>/dev/null | grep -q .; then
        dirty=1
    else
        dirty=0
    fi

    printf '%s|%s|%s\n' "$now" "$branch" "$dirty" > "$cache_file"
fi

if [[ "$dirty" == "1" ]]; then
    printf ' #[fg=colour244]git:#[fg=colour214] %s*' "$branch"
else
    printf ' #[fg=colour244]git:#[fg=colour82] %s' "$branch"
fi
