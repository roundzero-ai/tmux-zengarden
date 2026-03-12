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

This setup has three layers:

- `outer tmux`: your local tmux session in the current terminal
- `inner tmux`: a nested tmux session, usually over SSH, while outer tmux stays active
- `Ghostty shortcut layer`: optional terminal shortcuts that skip the outer prefix for a small set of bindings

### Outer tmux

Core controls:

| Action | Key |
|---|---|
| Prefix | `Ctrl+Space` |
| Toggle nested passthrough | `F12` |
| Reload config | `prefix + r` |
| Copy mode | `prefix + [` -> `v` select -> `y` yank |

Panes:

| Action | Key |
|---|---|
| Move focus | `Alt+h/j/k/l` or `prefix + h/j/k/l` |
| Resize coarse (3 cells) | `prefix + ←/↓/↑/→` |
| Resize fine (1 cell) | `prefix + Alt+←/↓/↑/→` |
| Split horizontal | `prefix + \` |
| Split vertical | `prefix + -` |
| Bottom pane 25% | `prefix + =` |
| Right pane 33% | `prefix + /` |
| Swap pane down / up | `prefix + .` / `prefix + ,` |
| Zoom pane | `prefix + z` |
| Close pane | `prefix + x` |

Windows:

| Action | Key |
|---|---|
| New window | `prefix + c` |
| Select window 1..9 | `Alt+1..9` |
| Next window | `Alt+Tab` |
| Swap window left / right | `prefix + p` / `prefix + n` |

### Inner tmux — Ctrl-key layer

Use this when you want to control an inner tmux session **without** turning on `F12` REMOTE mode.

Rule of thumb:

- prefix-free inner actions use `Ctrl+Alt+...`
- prefix-based inner actions use `outer prefix`, then the matching `Ctrl+...` key
- plain keys after prefix still target the outer tmux

Prefix-free inner actions:

| Action | Key |
|---|---|
| Move inner pane focus | `Ctrl+Alt+h/j/k/l` |
| Select inner window 1..9 | `Ctrl+Alt+1..9` |
| Next inner window | `Ctrl+Alt+Tab` |

Prefix-based inner actions after outer `Ctrl+Space`:

| Action | Key after prefix |
|---|---|
| New inner window | `Ctrl+c` |
| Close inner pane | `Ctrl+x` |
| Toggle inner zoom | `Ctrl+z` |
| Reload inner config | `Ctrl+r` |
| Inner split horizontal | `Ctrl+\` |
| Inner split vertical | `Ctrl+-` |
| Inner bottom pane 25% | `Ctrl+=` |
| Inner right pane 33% | `Ctrl+/` |
| Swap inner pane down / up | `Ctrl+.` / `Ctrl+,` |
| Swap inner window left / right | `Ctrl+p` / `Ctrl+n` |
| Resize inner pane coarse | `Ctrl+←/↓/↑/→` |
| Resize inner pane fine | `Ctrl+Alt+←/↓/↑/→` |
| Inner copy mode | `Ctrl+[` |

How it works:

- `prefix + c` means "act on outer tmux"
- `prefix + Ctrl+c` means "forward outer prefix + c to inner tmux"
- this keeps outer and inner controls available at the same time, without mode switching

### Ghostty single-keystroke shortcuts (optional)

Ghostty adds a helper layer on top of tmux:

- `Alt+...` skips the prefix for the full **outer** prefix-based binding set
- `Ctrl+Alt+...` skips the prefix for selected **inner** bindings
- prefix-free inner bindings like `Ctrl+Alt+h/j/k/l` still work natively in tmux and do not need a Ghostty entry

| Action | Ghostty shortcut | Equivalent tmux input |
|---|---|---|
| Outer resize fine | `Ctrl+Alt+←/↓/↑/→` | `prefix + Alt+←/↓/↑/→` |
| Outer split horizontal | `Alt+\` | `prefix + \` |
| Outer split vertical | `Alt+-` | `prefix + -` |
| Outer bottom pane 25% | `Alt+=` | `prefix + =` |
| Outer zoom pane | `Alt+z` | `prefix + z` |
| Outer new window | `Alt+c` | `prefix + c` |
| Outer close pane | `Alt+x` | `prefix + x` |
| Outer swap pane down / up | `Alt+.` / `Alt+;` | `prefix + .` / `prefix + ,` |
| Outer swap window left / right | `Alt+p` / `Alt+n` | `prefix + p` / `prefix + n` |
| Outer resize coarse | `Alt+←/↓/↑/→` | `prefix + ←/↓/↑/→` |
| Outer reload config | `Alt+r` | `prefix + r` |
| Outer copy mode | `Alt+[` | `prefix + [` |
| Inner select window 1..9 | `Ctrl+Alt+1..9` | `Ctrl+Alt+1..9` |
| Inner next window | `Ctrl+Alt+Tab` | `Ctrl+Alt+Tab` |
| Inner new window | `Ctrl+Alt+c` | `prefix + Ctrl+c` |
| Inner close pane | `Ctrl+Alt+x` | `prefix + Ctrl+x` |
| Inner zoom toggle | `Ctrl+Alt+z` | `prefix + Ctrl+z` |
| Inner reload config | `Ctrl+Alt+r` | `prefix + Ctrl+r` |
| Inner split horizontal | `Ctrl+Alt+\` | `prefix + Ctrl+\` |
| Inner split vertical | `Ctrl+Alt+-` | `prefix + Ctrl+-` |
| Inner bottom pane 25% | `Ctrl+Alt+=` | `prefix + Ctrl+=` |
| Inner right pane 33% | `Ctrl+Alt+/` | `prefix + Ctrl+/` |
| Inner swap pane down / up | `Ctrl+Alt+.` / `Ctrl+Alt+;` | `prefix + Ctrl+.` / `prefix + Ctrl+,` |
| Inner copy mode | `Ctrl+Alt+[` | `prefix + Ctrl+[` |
| Inner swap window left / right | `Ctrl+Alt+p` / `Ctrl+Alt+n` | `prefix + Ctrl+p` / `prefix + Ctrl+n` |
| Inner resize coarse | `Ctrl+Alt+←/↓/↑/→` | `prefix + Ctrl+←/↓/↑/→` |

Maintenance rules for future updates:

- Avoid adding bindings that require `Shift` for normal use; prefer letters, arrows, or unshifted punctuation.
- Keep the mapping pattern aligned across layers: outer tmux, inner tmux, then Ghostty shortcut if one exists.
- If an outer binding changes and it has an inner equivalent, update the inner `Ctrl+...` form to match the same semantic action.
- Keep the full outer Ghostty alias set aligned with prefix-based outer actions: resize, split, toggle pane layouts, zoom, new/close, swaps, reload, and copy mode.
- If an inner action has a Ghostty shortcut, update the matching line in `tui-zening/config/ghostty` at the same time.
- Prefix-free inner bindings belong to tmux root-table bindings; prefix-based inner bindings belong to the `prefix + Ctrl+...` family.
- Document the tmux binding first, then the Ghostty shortcut as a convenience alias.

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
