#!/usr/bin/env bash
# ============================================================
#  tmux ZenGarden — verification gate
#
#  Must pass before any commit is pushed (see AGENTS.md).
#  Also run by CI (.github/workflows/verify.yml).
#
#  Checks:
#    1. bash -n syntax check on every shell script
#    2. shellcheck on every shell script (when installed)
#    3. real tmux parse of tmux.conf on an isolated socket
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

FAILURES=0

pass() { echo "  ok    $1"; }
fail() { echo "  FAIL  $1"; FAILURES=$((FAILURES + 1)); }

SHELL_FILES=(deploy.sh verify.sh scripts/*.sh)

echo "==> 1/3 bash -n syntax check"
for f in "${SHELL_FILES[@]}"; do
    if bash -n "$f" 2>&1; then
        pass "$f"
    else
        fail "$f"
    fi
done

echo "==> 2/3 shellcheck"
if command -v shellcheck &>/dev/null; then
    if shellcheck -S error "${SHELL_FILES[@]}"; then
        pass "shellcheck -S error"
    else
        fail "shellcheck -S error"
    fi
else
    echo "  skip  shellcheck not installed (CI runs it; brew/apt install shellcheck locally)"
fi

echo "==> 3/3 tmux config parse (isolated socket)"
if command -v tmux &>/dev/null; then
    SOCK="zg-verify-$$"
    if tmux -L "$SOCK" -f /dev/null new-session -d -s verify 2>&1; then
        if tmux -L "$SOCK" source-file "$SCRIPT_DIR/tmux.conf"; then
            pass "tmux.conf parses cleanly (tmux $(tmux -V | cut -d' ' -f2))"
        else
            fail "tmux.conf has parse errors (see above)"
        fi
        tmux -L "$SOCK" kill-server 2>/dev/null
    else
        fail "could not start isolated tmux server"
    fi
else
    fail "tmux not installed — cannot validate tmux.conf"
fi

echo ""
if [[ "$FAILURES" -gt 0 ]]; then
    echo "verify: $FAILURES check(s) FAILED — do not push."
    exit 1
fi
echo "verify: all checks passed."
