#!/usr/bin/env bash
# ============================================================
#  tmux ZenGarden — deploy script
#  Run on any machine (Mac Studio, DGX Spark, MacBook Pro...)
#  Usage: bash deploy.sh [--reload] [--posh]
#
#  --reload   reload live tmux session after deploy
#  --posh     also deploy oh-my-posh theme (oh-my-posh.json)
#             installs to ~/.config/oh-my-posh/zengarden.json
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DST="$HOME/.tmux/scripts"
CONF_DST="$HOME/.tmux.conf"

echo "==> Deploying tmux ZenGarden from $SCRIPT_DIR"

# ── 1. Install scripts ────────────────────────────────────────
mkdir -p "$SCRIPTS_DST"
find "$SCRIPTS_DST" -maxdepth 1 -type f -name '*.sh' -delete
cp "$SCRIPT_DIR/scripts/"*.sh "$SCRIPTS_DST/"
chmod +x "$SCRIPTS_DST/"*.sh
echo "    Scripts  -> $SCRIPTS_DST"

# ── 2. Backup existing tmux.conf ─────────────────────────────
if [[ -f "$CONF_DST" && ! -L "$CONF_DST" ]]; then
    bak="${CONF_DST}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$CONF_DST" "$bak"
    echo "    Backup   -> $bak"
fi

# ── 3. Install tmux.conf ──────────────────────────────────────
cp "$SCRIPT_DIR/tmux.conf" "$CONF_DST"
echo "    Config   -> $CONF_DST"

# ── 4. OS-specific checks ─────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
    echo ""
    echo "    macOS detected."
    if ! command -v tmux &>/dev/null; then
        echo "    [!] tmux not found. Install with: brew install tmux"
    else
        echo "    tmux $(tmux -V | cut -d' ' -f2) found."
    fi
    echo ""
    echo "    GPU stats use ioreg (no sudo required)."
else
    echo ""
    echo "    Linux detected."
    if command -v nvidia-smi &>/dev/null; then
        echo "    nvidia-smi found — GPU stats enabled automatically."
    else
        echo "    [!] nvidia-smi not found — GPU stats will show N/A."
    fi
fi

# ── 5. Deploy oh-my-posh theme (optional) ────────────────────
for arg in "$@"; do
    if [[ "$arg" == "--posh" ]]; then
        POSH_DST="$HOME/.config/oh-my-posh/zengarden.json"
        mkdir -p "$(dirname "$POSH_DST")"
        cp "$SCRIPT_DIR/oh-my-posh.json" "$POSH_DST"
        echo "    oh-my-posh -> $POSH_DST"

        if command -v oh-my-posh &>/dev/null; then
            echo ""
            echo "    To activate, add to ~/.zshrc or ~/.bashrc:"
            echo "      eval \"\$(oh-my-posh init zsh --config $POSH_DST)\""
        else
            echo "    [!] oh-my-posh not found."
            if [[ "$(uname)" == "Darwin" ]]; then
                echo "        Install: brew install jandedobbeleer/oh-my-posh/oh-my-posh"
            else
                echo "        Install: curl -s https://ohmyposh.dev/install.sh | bash -s"
            fi
        fi
        break
    fi
done

# ── 6. Reload live tmux server if running ────────────────────
if [[ "${1:-}" == "--reload" ]] || [[ "${1:-}" == "-r" ]]; then
    if tmux list-sessions &>/dev/null 2>&1; then
        tmux source-file "$CONF_DST" && echo "" && echo "    Reloaded live tmux session."
    else
        echo "    No running tmux session to reload."
    fi
fi

echo ""
echo "Done. Start tmux with: tmux new -s \"Main | \$(hostname -s)\""
echo ""
echo "Key bindings cheatsheet:"
echo "  Prefix              : Ctrl-Space"
echo "  Pane nav            : prefix + h/j/k/l  OR  Alt+h/j/k/l (no prefix)"
echo "  Pane resize (coarse): prefix + Arrow keys (3 cells)"
echo "  Split horiz         : prefix + \\"
echo "  Split vert          : prefix + -"
echo "  Bottom pane 25%     : prefix + =  (create or focus)"
echo "  Right pane 33%      : prefix + /  (create or focus)"
echo "  Zoom pane           : prefix + z"
echo "  Reload config       : prefix + r"
echo "  Switch window       : Alt+1..9"
echo "  Cycle window        : Alt+Tab"
echo "  Swap window         : prefix + p / prefix + n"
echo "  Copy mode           : prefix + [  (vi keys, v to select, y to yank)"
echo ""
echo "  Nested tmux — REMOTE mode (F12):"
echo "  F12                 : suspend/resume local key interception"
echo ""
echo "  Nested tmux — Ctrl-key layer (Ghostty + MacBook, no REMOTE needed):"
echo "  Inner pane nav      : Ctrl+Alt+h/j/k/l"
echo "  Inner window select : Ctrl+Alt+1..9"
echo "  Inner cycle window  : Ctrl+Alt+Tab"
echo "  Inner new window    : prefix + Ctrl+c  (or Ctrl+Alt+c with Ghostty)"
echo "  Inner close pane    : prefix + Ctrl+x  (or Ctrl+Alt+x with Ghostty)"
echo "  Inner zoom toggle   : prefix + Ctrl+z  (or Ctrl+Alt+z with Ghostty)"
echo "  Inner split horiz   : prefix + Ctrl+\\"
echo "  Inner split vert    : prefix + Ctrl+-"
echo "  Inner bottom pane   : prefix + Ctrl+="
echo "  Inner right pane    : prefix + Ctrl+/"
echo "  Inner swap window   : prefix + Ctrl+p / prefix + Ctrl+n"
echo "  Inner resize coarse : prefix + Ctrl+Arrow keys"
