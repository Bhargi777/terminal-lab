# terminal-lab

A personal terminal laboratory: a cross-platform CLI toolkit (macOS,
Linux/WSL, Windows) built while learning Unix, shell scripting,
networking, Git, Python, and CLI architecture. It is both a usable tool
(`termlab`) and a record of what was learned building it.

## Why

Most dotfiles repos are a pile of aliases nobody remembers the reason for.
This one exists to force the opposite: every feature is built to understand
something concrete about the terminal, and the understanding gets written
down in `learning/`.

```
LEARN -> EXPERIMENT -> BUILD -> DOCUMENT -> TEST -> COMMIT
```

## What's here

- `cli/` - the `termlab` command entrypoint and interactive menu (zsh:
  macOS/Linux/WSL); `cli/windows/` - the native PowerShell counterpart
- `commands/` - one module per domain (system, network, filesystem,
  processes, git, python, packages, homebrew, macos, linux, windows,
  utilities), as `.zsh` and/or `.ps1` per module
- `shell/zsh/`, `shell/windows/` - per-OS startup integration;
  `shell/aliases/`, `shell/functions/`, `shell/prompt/` - zsh personal
  layer refactored out of a personal `.zshrc`
- `themes/` - terminal color/theme definitions
- `experiments/` - small, safe, isolated scripts exploring one concept each
- `learning/` - notes on what was tried and what it taught
- `docs/` - architecture, cross-platform design, command reference,
  install guide, roadmap
- `tests/` - syntax, smoke, and platform-detection checks (POSIX + PowerShell)
- `install.sh` / `uninstall.sh` (macOS/Linux) and `install-windows.ps1` /
  `uninstall-windows.ps1` (Windows) - opt-in installers with backups

## Install

See [docs/installation.md](docs/installation.md) for full OS-by-OS steps.
Short version:

```sh
./install.sh              # macOS / Linux
```

```powershell
./install-windows.ps1     # Windows
```

Both back up your existing shell config before touching it, never
overwrite it silently, and only add startup integration if you opt in.

## Usage

```sh
termlab            # interactive command center
termlab system     # system info
termlab network    # network diagnostics
termlab git status # git helpers
termlab --help     # full command list
```

Press `T` in the menu to drop straight into a normal shell. Press `Q` to quit.
See [docs/commands.md](docs/commands.md) for the full command reference.

## Architecture

`termlab` is a thin dispatcher (`cli/termlab` on macOS/Linux/WSL,
`cli/windows/termlab.ps1` on Windows) that hands off to one script per
module from `commands/<module>/`. No framework, no external runtime
dependency beyond native OS tools (`sw_vers`/`sysctl`/`pmset` on macOS,
`/proc`+`ip`/`ss` on Linux, `Get-CimInstance`/`Get-NetTCPConnection` on
Windows) and things already on the system (`git`, `python3`, a package
manager when present). Platform detection (`cli/lib/platform.zsh` /
`Get-TermlabPlatform`) picks the right branch or module at dispatch time.
Details in [docs/architecture.md](docs/architecture.md) and
[docs/cross-platform.md](docs/cross-platform.md). Honest per-OS support
levels (Supported/Partial/Experimental — nothing claimed that hasn't
actually been run and checked) are in [docs/platforms.md](docs/platforms.md).

## Safety

- No destructive filesystem/process/git operation runs without explicit
  confirmation.
- Nothing personal (name, address, student ID, tokens) lives in this repo.
  Personal values go in a gitignored `config` file, seeded from
  `config.example`.
- The shell startup hook is optional and guarded against recursive launches.

## Roadmap

See [docs/roadmap.md](docs/roadmap.md).

## License

MIT, see [LICENSE](LICENSE).
