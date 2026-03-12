#!/usr/bin/env bash
# pane_header.sh — print pane context on new pane open, then exec shell
# Called by split-window bindings so the user can tell
# whether this pane belongs to the outer or inner tmux session.

# ── Colours (256-colour, matching ZenGarden palette) ──────────
C_SKY=$'\033[38;5;75m'       # sky   — user@host
C_GREEN=$'\033[38;5;82m'    # green — git branch (clean)
C_AMBER=$'\033[38;5;214m'   # amber — git dirty indicator
C_GRAY=$'\033[38;5;240m'    # gray  — separators
C_CYAN=$'\033[38;5;51m'     # cyan  — current folder
C_GOLD=$'\033[38;5;220m'    # gold  — python venv
C_BOLD=$'\033[1m'
C_RST=$'\033[0m'

# ── Identity ───────────────────────────────────────────────────
USER_AT_HOST="${USER}@$(hostname -s)"
CURRENT_DIR="${PWD##*/}"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR="/"

if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    VENV_NAME="${VIRTUAL_ENV##*/}"
    VENV_PART="  ${C_GRAY}venv:${C_RST}${C_GOLD} ${VENV_NAME}${C_RST}"
fi

DIR_PART="  ${C_GRAY}dir:${C_RST}${C_CYAN} ${CURRENT_DIR}${C_RST}"

# ── Git info (current directory = pane_current_path via -c) ───
GIT_BRANCH=$(git branch --show-current 2>/dev/null)
if [[ -n "$GIT_BRANCH" ]]; then
    DIRTY=$(git status --porcelain 2>/dev/null)
    if [[ -n "$DIRTY" ]]; then
        GIT_PART="  ${C_GRAY}git:${C_RST}${C_AMBER} ${GIT_BRANCH}*${C_RST}"
    else
        GIT_PART="  ${C_GRAY}git:${C_RST}${C_GREEN} ${GIT_BRANCH}${C_RST}"
    fi
fi

# ── Print header line ──────────────────────────────────────────
printf "${C_GRAY}──${C_RST} ${C_BOLD}${C_SKY}%s${C_RST}%s ${C_GRAY}──${C_RST}\n" \
    "$USER_AT_HOST" "${DIR_PART}${VENV_PART:-}${GIT_PART:-}"

# ── Hand off to the user's shell ──────────────────────────────
exec "${SHELL:-zsh}"
