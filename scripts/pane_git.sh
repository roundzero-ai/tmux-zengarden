#!/usr/bin/env bash
# pane_git.sh — compact git branch + dirty flag for pane-border-format
# Outputs "git: main" or "git: main*" or nothing if not in a git repo.
# Usage: pane_git.sh <path>

cd "${1:-.}" 2>/dev/null || exit 0
BRANCH=$(git branch --show-current 2>/dev/null) || exit 0
[[ -z "$BRANCH" ]] && exit 0

if git status --porcelain 2>/dev/null | grep -q .; then
    printf 'git: %s*' "$BRANCH"
else
    printf 'git: %s' "$BRANCH"
fi
