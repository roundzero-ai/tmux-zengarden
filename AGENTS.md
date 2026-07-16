# AGENTS.md — tmux-zengarden

Instructions for coding agents (Claude Code, Codex CLI, …). `CLAUDE.md` is a
symlink to this file — edit this file only.

## What this repo is

The **source of truth for the entire ZenGarden keymap and tmux experience**:

| File | Owns |
|---|---|
| `tmux.conf` | tmux config: outer bindings, inner Ctrl-key layer, status bar, REMOTE mode |
| `ghostty-keys.conf` | Ghostty single-keystroke aliases mirroring the tmux keymap |
| `scripts/*.sh` | status bar samplers (`status_stats.sh`), SSH window labels (`ssh_label.sh`), pane border context (`pane_git.sh`) |
| `deploy.sh` | installs tmux.conf + scripts to `~/.tmux.conf` and `~/.tmux/scripts/` |
| `README.md` | **canonical keybinding reference** for the whole ZenGarden system |

Not in this repo: installation/bootstrap, Ghostty appearance config, oh-my-posh
theme, yazi, fonts — those live in the sibling repo **tui-zening**.

## Repo relationship (read this before any change)

- **tui-zening** (`github.com/roundzero-ai/tui-zening`) is the distribution
  repo. Its `setup.sh` clones THIS repo from GitHub `main` into
  `.cache/tmux-zengarden` and runs `deploy.sh`, and it copies
  `ghostty-keys.conf` next to the Ghostty config it deploys.
- Consequence: **anything pushed to `main` here reaches every machine on its
  next `setup.sh` run.** Never push unverified changes.
- Local edits here are invisible to tui-zening until pushed — except via
  `setup.sh --local`, which uses a sibling checkout (`../tmux-zengarden`)
  instead of the GitHub cache. Use that to test cross-repo changes end-to-end
  before pushing.
- tui-zening's README intentionally does NOT duplicate the keymap tables; it
  links here. Don't re-add keymap tables over there.

## Keymap change checklist

A binding change is not done until all of these (all in this repo) agree:

1. `tmux.conf` — the outer binding.
2. `tmux.conf` — the matching inner `Ctrl+...` form, if the action has an
   inner equivalent (`prefix + x` ⇒ `prefix + Ctrl+x` forwards to inner tmux).
3. `ghostty-keys.conf` — the Ghostty alias (`Alt+...` for outer,
   `Ctrl+Alt+...` for inner). CSI u encoding: prefix is `\x1b[32;5u`
   (Ctrl+Space); modifier math Ctrl=4, Alt=2, base=1 → Ctrl=`;5u`,
   Ctrl+Alt=`;7u`.
4. `README.md` — outer table, inner Ctrl-layer table, and Ghostty shortcut
   table.

Style rules:

- No bindings that require `Shift` for normal use; prefer letters, arrows,
  unshifted punctuation.
- Keep the semantic pattern aligned across layers: outer tmux → inner tmux
  (`Ctrl+` prefix-form) → Ghostty alias.
- Document tmux-native behavior first; Ghostty is a convenience alias layer.

## Workflow

1. Edit.
2. Run `bash verify.sh` — syntax check, shellcheck (if installed), and a real
   tmux parse of `tmux.conf` on an isolated socket. **Must pass.**
3. For cross-repo changes (keymap, deploy interface, script names): test with
   `bash ../tui-zening/setup.sh --local --dry-run`, and run tui-zening's
   `verify.sh` too.
4. Commit using conventional-commit style (`fix(status): …`, `feat(keys): …`,
   `docs: …`), matching existing history.
5. **Push policy: auto-push to `main` once `verify.sh` passes.** Push order
   when both repos changed: **this repo first, then tui-zening** (tui-zening
   consumes this repo's `main`).
6. After pushing, offer to propagate to the fleet via tui-zening's
   `sync-fleet.sh`.

Do **not** run `deploy.sh` (or reload the user's live tmux) on the development
machine as part of verification unless the user asks — `verify.sh` is the
gate; deploying is a user decision.

## Platform matrix

Code in `scripts/` and `tmux.conf` must keep working on all of these; only the
Mac is testable locally — the rest are exercised by CI (ubuntu-latest) and by
the machines themselves:

| Class | Detection | Stats path | Shell |
|---|---|---|---|
| Apple Silicon Mac (MacBook Pro, Mac Studio) | `arm64` macOS | `top` + `vm_stat` + `ioreg` → CPU·UMA·GPU | zsh |
| DGX Spark GB10 (UMA) | `nvidia-smi` GPU-name match | `top` + `free` + `nvidia-smi` → CPU·UMA·GPU | bash |
| Jetson / Orin | `tegrastats` present | `tegrastats` → CPU·UMA·GPU | bash |
| Linux + discrete NVIDIA | `nvidia-smi`, non-UMA name | `top` + `free` + `nvidia-smi` → CPU·RAM·GPU·VRAM | bash |
| Raspberry Pi 4 (headless) | device-tree model | no GPU stats | bash |

Portability traps that have bitten before: mawk lacks `match()` third arg
(use `sed`), BSD vs GNU `sed -i`, `tegrastats` needs `timeout` not `--count`.
Scripts must degrade gracefully when a probe tool is missing.

## Verification details

- `verify.sh` exits non-zero on any failure; CI runs it on every push/PR.
- tmux parse test uses `tmux -L <socket> -f /dev/null new-session -d` +
  `source-file tmux.conf` — config errors make `source-file` return 1.
- `tmux.conf` requires tmux ≥ 3.x (`extended-keys`, `allow-passthrough` is
  version-guarded with `-gq`).
