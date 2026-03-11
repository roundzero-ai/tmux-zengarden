# tmux ZenGarden

A clean, modern tmux setup for coding and vibe-coding across Mac Studio, DGX Spark, and MacBook Pro via SSH.

## Features

- **256-color + true color** — optimized for Ghostty terminal
- **Two-line status bar**: session · CPU · RAM · GPU · clock
- **Native window tabs** with per-window color cycling and instant updates on switch
- **Vim pane navigation**: `Alt+h/j/k/l` (no prefix) or `prefix + h/j/k/l`
- **Smart pane splits**: bottom-quarter and right-third toggles (create or focus)
- **Nested tmux support**: F12 toggles key passthrough with visual REMOTE mode dimming
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
| Resize pane (coarse) | `prefix + H/J/K/L` |
| Resize pane (fine) | `prefix + Alt+H/J/K/L` |
| Split horizontal | `prefix + \|` |
| Split vertical | `prefix + -` |
| Bottom pane 25% | `prefix + _` — creates if none, focuses if exists |
| Right pane 33% | `prefix + \` — creates if none, focuses if exists |
| Zoom pane | `prefix + z` |
| Swap pane down/up | `prefix + >` / `prefix + <` |
| New window | `prefix + c` |
| Switch window | `Alt+1..9` · `Alt+[` / `Alt+]` |
| Cycle window | `Alt+Tab` / `Alt+Shift+Tab` |
| Swap window left/right | `prefix + Shift+←` / `prefix + Shift+→` |
| Last window | `prefix + Tab` |
| Reload config | `prefix + r` |
| Copy mode | `prefix + [` → `v` select → `y` yank |
| Nested tmux toggle (REMOTE mode) | `F12` — suspend/resume local key interception |

### Inner tmux — Ctrl-key layer (Ghostty + MacBook)

A second way to control an inner (SSH-remote) tmux **without activating F12 REMOTE mode**.
All outer bindings stay active; the Ctrl-modifier routes the equivalent command to the inner session.
Requires `extended-keys on` (set automatically).

**Prefix-free** — handled by tmux, work on any terminal with extended keys:

| Action | Key |
|---|---|
| Inner pane navigation | `Ctrl+Alt+h/j/k/l` |
| Inner select window 1..9 | `Ctrl+Alt+1..9` |
| Inner next window | `Ctrl+Alt+Tab` |
| Inner prev window | `Ctrl+Alt+Shift+Tab` |

**Prefix-based** — require outer prefix (`Ctrl-Space`) first, then:

| Action | Key (after prefix) |
|---|---|
| Inner new window | `Ctrl+c` |
| Inner close pane | `Ctrl+x` |
| Inner zoom toggle | `Ctrl+z` |
| Inner split horizontal | `Ctrl+\|` |
| Inner split vertical | `Ctrl+-` |
| Inner bottom pane 25% | `Ctrl+_` |
| Inner right pane 33% | `Ctrl+\` |
| Inner swap window left/right | `Ctrl+Shift+←` / `Ctrl+Shift+→` |
| Inner resize pane (coarse) | `Ctrl+H/J/K/L` (repeatable) |
| Inner resize pane (fine) | `Ctrl+Alt+H/J/K/L` (repeatable) |

**Ghostty single-keystroke shortcuts** (optional, eliminates the prefix press):

The Ghostty config in [tui-zening](https://github.com/roundzero-ai/tui-zening) adds keybindings that send the outer-prefix CSI u sequence + command CSI u sequence in one keypress. For example, `Ctrl+Alt+c` sends `\x1b[32;5u\x1b[99;5u` (Ctrl-Space + Ctrl-c in kitty encoding), which the outer tmux processes as prefix → `bind C-c` → inner new window.

| Action | Ghostty shortcut | Without Ghostty |
|---|---|---|
| Inner new window | `Ctrl+Alt+c` | `prefix + Ctrl+c` |
| Inner close pane | `Ctrl+Alt+x` | `prefix + Ctrl+x` |
| Inner zoom toggle | `Ctrl+Alt+z` | `prefix + Ctrl+z` |
| Inner split horizontal | `Ctrl+Alt+\|` | `prefix + Ctrl+\|` |
| Inner split vertical | `Ctrl+Alt+-` | `prefix + Ctrl+-` |
| Inner bottom pane 25% | `Ctrl+Alt+_` | `prefix + Ctrl+_` |
| Inner right pane 33% | `Ctrl+Alt+\` | `prefix + Ctrl+\` |
| Inner swap window L/R | `Ctrl+Alt+Shift+←/→` | `prefix + Ctrl+Shift+←/→` |
| Inner resize coarse | `Ctrl+Alt+Shift+H/J/K/L` | `prefix + Ctrl+H/J/K/L` |

## Status Bar

```
≋ ZenGarden  user@host          1:project  2:folder>nvim  3:user@remote
[session]   branch* +1 ~2  │  CPU 45%  │  MEM 8.2G 51%  │  GPU 78%  │  14:30 Thu Mar 06
```

### Line 0 (top): Brand pill + identity + window tabs

- **Left**: brand pill (`≋ ZenGarden` or `⇥ REMOTE`)
- **Right**: native window tabs rendered via `#{W:...}` tmux format

### Line 1 (bottom): Session pill + system stats

- **Left**: session name pill; `≋ PREFIX` pill appears when prefix is active
- **Right**: CPU · MEM · GPU · clock (via `#()` shell scripts, refreshed every `status-interval` = 5s)

### Window Tab Labels

Labels are set via `automatic-rename-format` and displayed using native `#{W:...}` format:

| Pane state | Label | Mechanism |
|---|---|---|
| Shell at prompt (zsh/bash/fish/sh/etc.) | `folder` | Native format: `#{b:pane_current_path}` |
| Program running | `folder>program` | Native format: `#{b:pane_current_path}>#{pane_current_command}` |
| SSH session | `user@host` | Shell script: `ssh_label.sh` inspects child processes via `ps` |

Shell detection uses `#{m:*sh,#{pane_current_command}}` glob match, with an explicit `#{==:#{pane_current_command},ssh}` check first to route SSH panes to the script.

### Window Tab Styling

Tabs use **native `#{W:...}` tmux format** (not a shell script) so active/inactive styling updates instantly on window switch — no `status-interval` delay.

- **Active tab**: Nerd Font rounded pill (U+E0B6/U+E0B4 caps) with colored background
- **Inactive tab**: dim colored text, no pill
- **Color cycling**: 9-color palette indexed by window number (1=sky, 2=purple, 3=green, 4=amber, 5=coral, 6=cyan, 7=gold, 8=pink, 9=orange; 10+ fallback to grey)
- **Flags**: ` Z` for zoomed, `!` for activity

### REMOTE Mode (F12) Tab Dimming

When F12 activates REMOTE mode (`key-table=off`), the **outer** tmux visually dims all window tabs to signal that keys pass through to the inner tmux:

| Element | Normal mode | REMOTE mode |
|---|---|---|
| Brand pill | Blue `≋ ZenGarden` | Coral `⇥ REMOTE` |
| Active tab | Per-window colored pill | Muted grey pill (`colour238` bg, `colour250` fg) |
| Inactive tabs | Dim per-window colored text | Dim grey text (`colour240` fg) |

The inner tmux (remote) displays its own tabs normally, so the active window on the remote session remains clearly visible.

**Status colors (line 1 stats):**
- Green → normal
- Orange → moderate (CPU≥50%, MEM≥60%, GPU≥50%)
- Red → high (CPU≥80%, MEM≥85%, GPU≥80%)

## Colour Palette

All styling uses named 256-colour values for consistency:

| Name | Value | Usage |
|---|---|---|
| sky | `colour75` | Brand pill, active pane border, clock, window 1 |
| purple | `colour141` | GPU stats, window 2 |
| green | `colour82` | Username, healthy stats, window 3 |
| amber | `colour214` | PREFIX pill, moderate stats, window 4 |
| coral | `colour203` | REMOTE pill, window 5 |
| cyan | `colour51` | Window 6 |
| gold | `colour220` | Window 7 |
| pink | `colour177` | Window 8 |
| orange | `colour208` | Window 9 |
| nearblack | `colour232` | Pill text foreground |
| darkgray | `colour238` | Separators, REMOTE active tab bg, pane borders |
| gray | `colour240` | Git status, REMOTE inactive tab fg |
| nearwhite | `colour250` | Hostname, REMOTE active tab fg |

## Scripts

All scripts live in `scripts/` and are deployed to `~/.tmux/scripts/` by `deploy.sh`.

| Script | Called from | Purpose |
|---|---|---|
| `ssh_label.sh` | `automatic-rename-format` | Extracts SSH target (`user@host`) from child processes via `ps` |
| `git_status.sh` | `status-format[1]` | Git branch, staged/unstaged/untracked counts, ahead/behind |
| `cpu.sh` | `status-format[1]` | CPU usage percentage (macOS: `top`, Linux: `top -bn1`) |
| `memory.sh` | `status-format[1]` | Memory usage (macOS: `vm_stat`, Linux: `free`) |
| `gpu.sh` | `status-format[1]` | GPU utilization (macOS: `ioreg`, Linux: `nvidia-smi`) |
| `gpu_daemon.sh` | — | Optional background GPU polling daemon |
| `window_tabs.sh` | — | Legacy shell-based tab renderer (replaced by native `#{W:...}` format) |
| `pane_header.sh` | — | Prints `user@host` + git info then execs shell (superseded by `pane-border-status`) |
| `pane_git.sh` | `pane-border-format` | Outputs compact `git: branch` or `git: branch*` for the pinned pane border header |

## Architecture Decisions

### Native `#{W:...}` for window tabs (not shell script)

Window tabs were originally rendered by `window_tabs.sh` called via `#(...)` in `status-format[0]`. This caused a visible delay (up to `status-interval` seconds) when switching windows with `Alt+number`, because `#()` command output is cached by tmux. The fix replaces the shell script call with native `#{W:...}` tmux format iteration, which tmux re-evaluates on every status redraw — giving instant visual feedback. The per-window color cycling is implemented as nested `#{?#{==:#{window_index},N},...}` conditionals (9 levels deep).

### `automatic-rename-format` with conditional `#()` for SSH

The label for each window tab comes from `#{window_name}`, which is set by `automatic-rename-format`. For shell and program panes, the label is computed entirely with native tmux format variables (instant, no shell overhead). Only SSH panes invoke `#($HOME/.tmux/scripts/ssh_label.sh #{pane_pid})` to inspect child processes — this `#()` is inside a `#{?#{==:#{pane_current_command},ssh},...}` conditional so it never fires for non-SSH panes.

### Comma-safety in tmux formats

tmux's `#{?condition,true,false}` parser splits on commas. Commas inside `#[style,attr]` blocks are indistinguishable from branch separators. All multi-attribute styles must use separate `#[...]` blocks (e.g., `#[bg=default]#[fg=colour75]` not `#[bg=default,fg=colour75]`) when nested inside conditionals or `#{W:...}`.

## Nested tmux (SSH into a remote machine running tmux)

Two modes for controlling inner tmux, both active simultaneously:

### F12 — REMOTE mode (full passthrough)

Press `F12` to suspend local key interception — all keypresses (including `Ctrl-Space`) pass through to the inner session. The brand pill swaps from blue `≋ ZenGarden` to coral `⇥ REMOTE`, and all outer window tabs dim to grey. Press `F12` again to resume local control.

### Ctrl-key layer (no mode toggle needed)

Without toggling REMOTE mode, the **Ctrl-key layer** lets you send common commands to the inner tmux while keeping full control of the outer. The outer session stays fully functional for outer-window management.

Pattern: outer binding uses an extra **Ctrl** (or **Ctrl+Alt**) modifier; each binding executes `send-keys` with the equivalent key to the inner pane.

- **Prefix-free** (`Ctrl+Alt+…`): window select 1–9, window cycle (Tab/Shift+Tab)
- **With outer prefix** (`prefix + Ctrl+…`): splits, new window, close pane, swap window, resize

Requires `set -g extended-keys on` (auto-set) and Ghostty with kitty keyboard protocol so the terminal can distinguish `Ctrl+|` from `Ctrl+\`, `Ctrl+Tab` from `Tab`, etc.

**Optional Ghostty single-keystroke layer**: add Ghostty keybindings to send the outer-prefix byte sequence + command byte in one keypress. For example, bind `Ctrl+Alt+n` in Ghostty to `text:\u001b[32;5u\u001b[99;5u` (outer Ctrl-Space + Ctrl-c in kitty encoding) so the outer tmux executes its `prefix + Ctrl+c` → inner new window, without the user pressing the prefix separately.

### Clipboard in nested tmux

Two mechanisms work together to ensure copy works through all nesting layers:

| Setting | Purpose |
|---|---|
| `set-clipboard on` | tmux processes raw OSC 52 from apps and forwards to the outer terminal |
| `allow-passthrough on` | tmux forwards DCS passthrough sequences (active pane only) to the outer terminal |

**Why both are needed:** tmux copy-mode generates raw OSC 52 sequences, which `set-clipboard on` handles directly. But TUI applications like [OpenCode](https://github.com/anomalyco/opencode) detect `$TMUX` and wrap OSC 52 inside a DCS tmux passthrough (`\x1bPtmux;\x1b...\x1b\\`). Without `allow-passthrough on`, the inner tmux blocks this DCS sequence and the copy never reaches the outer terminal.

The copy chain for a TUI app in nested tmux:
```
App sends DCS-wrapped OSC 52
  → inner tmux (allow-passthrough on) strips DCS, forwards raw OSC 52
    → outer tmux (set-clipboard on) processes OSC 52, forwards to terminal
      → Ghostty copies to system clipboard
```

`allow-passthrough on` restricts passthrough to the **active pane only**, which is the safe default — only the pane the user is focused on can send escape sequences to the outer terminal.

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
