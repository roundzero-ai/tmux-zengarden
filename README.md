# tmux ZenGarden

A clean, modern tmux setup for coding and vibe-coding across Mac Studio, DGX Spark, and MacBook Pro via SSH.

## Features

- **256-color + true color** — optimized for Ghostty terminal
- **Two-line status bar**: session · host · git branch/status · CPU · RAM · GPU · clock
- **Smart window tabs**: idle → `folder`, program running → `folder>program`, SSH → `user@host`
- **Vim pane navigation**: `Alt+h/j/k/l` (no prefix) or `prefix + h/j/k/l`
- **Smart pane splits**: bottom-quarter and right-third toggles (create or focus)
- **Nested tmux support**: F12 toggles key passthrough to inner (remote) session
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

| Action | Key |
|---|---|
| Prefix | `Ctrl-Space` |
| Navigate panes | `Alt+h/j/k/l` or `prefix + h/j/k/l` |
| Resize pane (coarse) | `prefix + H/J/K/L` |
| Resize pane (fine) | `prefix + Alt+H/J/K/L` |
| Split horizontal | `prefix + \|` |
| Split vertical | `prefix + -` |
| Bottom pane 25% | `prefix + _` — creates if none, focuses if exists |
| Right pane 33% | `prefix + \` — creates if none, focuses if exists |
| Zoom pane | `prefix + z` |
| New window | `prefix + c` |
| Switch window | `Alt+1..9` · `Alt+[` / `Alt+]` |
| Last window | `prefix + Tab` |
| Reload config | `prefix + r` |
| Copy mode | `prefix + [` → `v` select → `y` yank |
| Nested tmux toggle | `F12` — suspend/resume local key interception |

## Status Bar

```
≋ ZenGarden  user@host          1:project  2:folder>nvim  3:user@remote
[session]   branch* +1 ~2  │  CPU 45%  │  MEM 8.2G 51%  │  GPU 78%  │  14:30 Thu Mar 06
```

**Window tab labels:**
- Shell at prompt → `folder`
- Program running → `folder>program`
- SSH session → `user@host`

**Status colors:**
- Green → normal
- Orange → moderate (CPU≥50%, MEM≥60%, GPU≥50%)
- Red → high (CPU≥80%, MEM≥85%, GPU≥80%)

## Nested tmux (SSH into a remote machine running tmux)

Press `F12` to suspend local key interception — all keypresses (including `Ctrl-Space`) pass through to the inner session. The brand pill swaps from blue `≋ ZenGarden` to coral `⇥ REMOTE` as a visual indicator. Press `F12` again to resume local control.

## GPU Stats

**macOS**: Uses `ioreg IOAccelerator` — no `sudo` required, works on Apple Silicon and Intel.

**Linux / DGX Spark**: Uses `nvidia-smi`. On GB10 Grace Blackwell (unified memory), GPU utilization is shown with `UMA` label since dedicated VRAM is not applicable.

## Remote Deploy via SSH

```bash
# Copy project to remote machine, then deploy:
rsync -av ~/Projects/tmux_zengarden/ mac-studio:~/Projects/tmux_zengarden/
ssh mac-studio "bash ~/Projects/tmux_zengarden/deploy.sh"

rsync -av ~/Projects/tmux_zengarden/ dgx-spark:~/Projects/tmux_zengarden/
ssh dgx-spark "bash ~/Projects/tmux_zengarden/deploy.sh"
```
