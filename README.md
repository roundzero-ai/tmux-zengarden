# tmux ZenGarden

A clean, modern tmux setup for coding across MacBook Pro, Mac Studio, DGX Spark, and Ubuntu machines via SSH.

## Features

- **256-color + true color** — optimized for Ghostty terminal
- **Two-line status bar**: session · CPU · RAM · GPU · clock
- **Native window tabs** with per-window color cycling and instant updates on switch
- **Vim pane navigation**: `Alt+h/j/k/l` (no prefix) or `prefix + h/j/k/l`
- **Smart pane splits**: bottom-quarter and right-third toggles (create or focus)
- **Nested tmux support**: F12 toggles key passthrough with visual REMOTE mode dimming
- **Ctrl-key layer**: operate inner tmux without toggling REMOTE mode
- **Cross-platform**: macOS (Apple Silicon/Intel) & Linux (NVIDIA GPU via `nvidia-smi`)

## Quick Deploy

```bash
# On any machine (local or via SSH):
bash ~/Projects/tmux_zengarden/deploy.sh

# Deploy and reload a live tmux session:
bash ~/Projects/tmux_zengarden/deploy.sh --reload

# Also deploy oh-my-posh theme:
bash ~/Projects/tmux_zengarden/deploy.sh --posh
```

## Key Bindings

### Outer tmux

| Action | Key |
|---|---|
| Prefix | `Ctrl-Space` |
| Navigate panes | `Alt+h/j/k/l` (no prefix) or `prefix + h/j/k/l` |
| Resize pane (coarse, 3 cells) | `prefix + H/J/K/L` (repeatable) |
| Resize pane (fine, 1 cell) | `prefix + Alt+H/J/K/L` (repeatable) |
| Split horizontal | `prefix + \|` |
| Split vertical | `prefix + -` |
| Bottom pane 25% | `prefix + _` — creates if none, focuses if exists |
| Right pane 33% | `prefix + \` — creates if none, focuses if exists |
| Zoom pane | `prefix + z` |
| New window | `prefix + c` |
| Close pane (confirm) | `prefix + x` |
| Switch window | `Alt+1..9` |
| Cycle window | `Alt+Tab` / `Alt+Shift+Tab` |
| Swap pane down / up | `prefix + >` / `prefix + <` |
| Swap window left / right | `prefix + Shift+←` / `prefix + Shift+→` (repeatable) |
| Reload config | `prefix + r` |
| Copy mode | `prefix + [` → `v` select → `y` yank |
| Nested tmux toggle (REMOTE mode) | `F12` — suspend/resume local key interception |

### Inner tmux — Ctrl-key layer

Control an inner (SSH-remote) tmux **without activating F12 REMOTE mode**. Pattern: add **Ctrl** to the outer binding. Requires `extended-keys on` (set automatically) and a terminal that supports CSI u / kitty keyboard protocol (e.g. Ghostty).

**Prefix-free** — handled by tmux root-table bindings:

| Action | Key |
|---|---|
| Inner pane navigation | `Ctrl+Alt+h/j/k/l` |
| Inner select window 1..9 | `Ctrl+Alt+1..9` |
| Inner next window | `Ctrl+Alt+Tab` |
| Inner prev window | `Ctrl+Alt+Shift+Tab` |

**Prefix-based** — require outer prefix (`Ctrl-Space`) first:

| Action | Key (after prefix) |
|---|---|
| Inner new window | `Ctrl+c` |
| Inner close pane | `Ctrl+x` |
| Inner zoom toggle | `Ctrl+z` |
| Inner reload config | `Ctrl+r` |
| Inner split horizontal | `Ctrl+\|` |
| Inner split vertical | `Ctrl+-` |
| Inner bottom pane 25% | `Ctrl+_` |
| Inner right pane 33% | `Ctrl+\` |
| Inner swap pane down / up | `Ctrl+>` / `Ctrl+<` |
| Inner copy mode | `Ctrl+[` (CSI u only) |
| Inner swap window left / right | `Ctrl+Shift+←` / `Ctrl+Shift+→` |
| Inner resize coarse | `Ctrl+H/J/K/L` (repeatable) |
| Inner resize fine | `Ctrl+Alt+H/J/K/L` (repeatable) |

### Ghostty single-keystroke shortcuts (optional)

The Ghostty config in [tui-zening](https://github.com/roundzero-ai/tui-zening) adds keybindings that send the outer-prefix CSI u sequence + command in one keypress, eliminating the manual prefix press. It also sends proper CSI u for prefix-free combos that macOS can't produce natively (digits, Tab).

| Action | Ghostty shortcut | Without Ghostty |
|---|---|---|
| Inner window select 1..9 | `Ctrl+Alt+1..9` | `Ctrl+Alt+1..9` (needs CSI u fix) |
| Inner next / prev window | `Ctrl+Alt+Tab` / `Shift+Tab` | `Ctrl+Alt+Tab` / `Shift+Tab` |
| Inner new window | `Ctrl+Alt+c` | `prefix + Ctrl+c` |
| Inner close pane | `Ctrl+Alt+x` | `prefix + Ctrl+x` |
| Inner zoom toggle | `Ctrl+Alt+z` | `prefix + Ctrl+z` |
| Inner reload config | `Ctrl+Alt+r` | `prefix + Ctrl+r` |
| Inner split horizontal | `Ctrl+Alt+\|` | `prefix + Ctrl+\|` |
| Inner split vertical | `Ctrl+Alt+-` | `prefix + Ctrl+-` |
| Inner bottom pane 25% | `Ctrl+Alt+_` | `prefix + Ctrl+_` |
| Inner right pane 33% | `Ctrl+Alt+\` | `prefix + Ctrl+\` |
| Inner swap pane down / up | `Ctrl+Alt+>` / `<` | `prefix + Ctrl+>` / `<` |
| Inner copy mode | `Ctrl+Alt+[` | `prefix + Ctrl+[` |
| Inner swap window L/R | `Ctrl+Alt+Shift+←/→` | `prefix + Ctrl+Shift+←/→` |
| Inner resize coarse | `Ctrl+Alt+Shift+H/J/K/L` | `prefix + Ctrl+H/J/K/L` |

> **Note:** Inner pane navigation (`Ctrl+Alt+h/j/k/l`) needs no Ghostty keybind — works natively via tmux extended-keys. Inner fine resize (`prefix + Ctrl+Alt+H/J/K/L`) has no Ghostty shortcut — modifier stack is maxed.

## Status Bar

```
 ≋ ZenGarden  user@host          1:project  2:folder>nvim  3:user@remote
  session                        CPU 18%  MEM 8.2G 51%  GPU 20%  14:35 Fri
```

- **Line 0** — Brand pill + identity (left) · Colored window tabs (right)
- **Line 1** — Session pill + PREFIX indicator (left) · CPU · RAM · GPU · time (right)
- **Window tab labels**: idle shell → `folder` · program running → `folder>program` · SSH → `user@host`
- GPU stats: `ioreg` on Apple Silicon (no sudo) · `nvidia-smi` on DGX Spark (UMA-aware for GB10)

### Window Tab Styling

Tabs use **native `#{W:...}` tmux format** for instant updates on switch — no `status-interval` delay.

- **Active tab**: Nerd Font rounded pill with colored background
- **Inactive tab**: dim colored text, no pill
- **Color cycling**: 9-color palette indexed by window number (1=sky, 2=purple, 3=green, 4=amber, 5=coral, 6=cyan, 7=gold, 8=pink, 9=orange)
- **Flags**: `Z` for zoomed, `!` for activity

### REMOTE Mode (F12) Tab Dimming

When F12 activates REMOTE mode, all outer window tabs dim to grey and the brand pill swaps from blue `≋ ZenGarden` to coral `⇥ REMOTE`. Press F12 again to resume local control.

| Element | Normal mode | REMOTE mode |
|---|---|---|
| Brand pill | Blue `≋ ZenGarden` | Coral `⇥ REMOTE` |
| Active tab | Per-window colored pill | Muted grey pill |
| Inactive tabs | Dim per-window colored text | Dim grey text |

**Status colors (line 1 stats):**
- Green → normal
- Orange → moderate (CPU≥50%, MEM≥60%, GPU≥50%)
- Red → high (CPU≥80%, MEM≥85%, GPU≥80%)

## Pane Borders

Persistent header at top of each pane shows `user@host` and git branch:
- **Active pane**: bold green username, sky blue border
- **Inactive pane**: dim grey username

## Nested tmux Clipboard

Two settings work together for copy through nested tmux layers:

| Setting | Purpose |
|---|---|
| `set-clipboard on` | tmux processes raw OSC 52 from apps and forwards to the outer terminal |
| `allow-passthrough on` | tmux forwards DCS passthrough sequences (active pane only) to the outer terminal |

Copy chain for a TUI app in nested tmux:
```
App sends DCS-wrapped OSC 52
  → inner tmux (allow-passthrough on) strips DCS, forwards raw OSC 52
    → outer tmux (set-clipboard on) processes OSC 52, forwards to terminal
      → Ghostty copies to system clipboard
```

## Scripts

All scripts live in `scripts/` and are deployed to `~/.tmux/scripts/` by `deploy.sh`.

| Script | Called from | Purpose |
|---|---|---|
| `ssh_label.sh` | `automatic-rename-format` | Extracts SSH target (`user@host`) from child processes via `ps` |
| `cpu.sh` | `status-format[1]` | CPU usage percentage (macOS: `top`, Linux: `top -bn1`) |
| `memory.sh` | `status-format[1]` | Memory usage (macOS: `vm_stat`, Linux: `free`) |
| `gpu.sh` | `status-format[1]` | GPU utilization (macOS: `ioreg`, Linux: `nvidia-smi`) |
| `pane_git.sh` | `pane-border-format` | Compact `git: branch` or `git: branch*` for pane header |

## GPU Stats

**macOS**: Uses `ioreg IOAccelerator` — no `sudo` required, works on Apple Silicon and Intel.

**Linux / DGX Spark**: Uses `nvidia-smi`. On GB10 Grace Blackwell (unified memory), GPU utilization is shown with `UMA` label since dedicated VRAM is not applicable.

## Remote Deploy via SSH

```bash
rsync -av ~/Projects/tmux_zengarden/ mac-studio:~/Projects/tmux_zengarden/
ssh mac-studio "bash ~/Projects/tmux_zengarden/deploy.sh"

rsync -av ~/Projects/tmux_zengarden/ dgx-spark:~/Projects/tmux_zengarden/
ssh dgx-spark "bash ~/Projects/tmux_zengarden/deploy.sh"
```
