# tmux ZenGarden

A clean, modern tmux setup for coding and vibe-coding across Mac Studio, DGX Spark, and MacBook Pro via SSH.

## Features

- **256-color + true color** — optimized for Ghostty terminal
- **Status bar**: session · host · git branch/status · CPU · RAM · GPU · clock
- **Vim pane navigation**: `Alt+h/j/k/l` (no prefix) or `prefix + h/j/k/l`
- **Pane resize**: `prefix + H/J/K/L` (3 cells) · `prefix + Alt+H/J/K/L` (1 cell)
- **Cross-platform**: macOS (Apple Silicon/Intel) & Linux (NVIDIA GPU via `nvidia-smi`)
- **Window names** auto-set to current directory basename

## Quick Deploy

```bash
# On any machine (local or via SSH):
bash ~/Projects/tmux_zengarden/deploy.sh

# Deploy and reload a live tmux session:
bash ~/Projects/tmux_zengarden/deploy.sh --reload
```

## Key Bindings

| Action | Key |
|---|---|
| Prefix | `Ctrl-a` |
| Navigate panes | `Alt+h/j/k/l` or `prefix + h/j/k/l` |
| Resize pane (coarse) | `prefix + H/J/K/L` |
| Resize pane (fine) | `prefix + Alt+H/J/K/L` |
| Split horizontal | `prefix + \|` |
| Split vertical | `prefix + -` |
| Zoom pane | `prefix + z` |
| New window | `prefix + c` |
| Switch window | `Alt+1..5` · `Alt+[` / `Alt+]` |
| Last window | `prefix + Tab` |
| Reload config | `prefix + r` |
| Copy mode | `prefix + [` → `v` select → `y` yank |

## Status Bar

```
[session] host  │  branch* +1 ~2  │  CPU 45%  │  MEM 12G  │  GPU 78% 8G  │  14:30 Thu Mar 06
```

Colors:
- Green → normal
- Orange → moderate (CPU≥50%, MEM≥60%, GPU≥50%)
- Red → high (CPU≥80%, MEM≥85%, GPU≥80%)

## GPU on macOS (Apple Silicon)

GPU stats require `sudo powermetrics`. Enable with a background daemon:

```bash
sudo ~/.tmux/scripts/gpu_daemon.sh &
```

Or add to `/etc/sudoers` for passwordless access (optional).

Alternatively, install [iStats](https://github.com/Chris911/iStats): `sudo gem install iStats`

## Remote Deploy via SSH

```bash
# Copy project to remote machine, then deploy:
rsync -av ~/Projects/tmux_zengarden/ mac-studio:~/Projects/tmux_zengarden/
ssh mac-studio "bash ~/Projects/tmux_zengarden/deploy.sh"

rsync -av ~/Projects/tmux_zengarden/ dgx-spark:~/Projects/tmux_zengarden/
ssh dgx-spark "bash ~/Projects/tmux_zengarden/deploy.sh"
```
