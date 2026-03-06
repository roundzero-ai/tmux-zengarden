#!/usr/bin/env bash
# Git status for the current pane's directory
# Usage: git_status.sh <pane_current_path>

dir="${1:-$PWD}"
cd "$dir" 2>/dev/null || exit 0

# Not a git repo
git rev-parse --git-dir &>/dev/null || exit 0

branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
[[ -z "$branch" ]] && exit 0

# Porcelain status
status=$(git status --porcelain 2>/dev/null)
staged=$(echo "$status" | grep -c '^[MADRC]' 2>/dev/null || echo 0)
unstaged=$(echo "$status" | grep -c '^.[MD]' 2>/dev/null || echo 0)
untracked=$(echo "$status" | grep -c '^??' 2>/dev/null || echo 0)

# Ahead / behind
upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
if [[ -n "$upstream" ]]; then
    ahead=$(git rev-list --count "@{upstream}..HEAD" 2>/dev/null || echo 0)
    behind=$(git rev-list --count "HEAD..@{upstream}" 2>/dev/null || echo 0)
else
    ahead=0; behind=0
fi

# Compose indicators
flags=""
(( staged   > 0 )) && flags+=" +${staged}"
(( unstaged > 0 )) && flags+=" ~${unstaged}"
(( untracked> 0 )) && flags+=" ?${untracked}"
(( ahead    > 0 )) && flags+=" ↑${ahead}"
(( behind   > 0 )) && flags+=" ↓${behind}"

if [[ -z "$flags" ]]; then
    color="#[fg=colour82]"
    marker=""
else
    color="#[fg=colour214]"
    marker="*"
fi

printf "${color} ${branch}${marker}${flags}#[default]"
