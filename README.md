# terminal-lab

A personal terminal laboratory: a CLI toolkit for macOS built while learning
Unix, shell scripting, networking, Git, Python, and CLI architecture. It is
both a usable tool (`bhargi`) and a record of what was learned building it.

## Why

Most dotfiles repos are a pile of aliases nobody remembers the reason for.
This one exists to force the opposite: every feature is built to understand
something concrete about the terminal, and the understanding gets written
down in `learning/`.

```
LEARN -> EXPERIMENT -> BUILD -> DOCUMENT -> TEST -> COMMIT
```

## What's here

- `cli/` - the `bhargi` command entrypoint and interactive menu
- `commands/` - one module per domain (system, network, filesystem,
  processes, git, python, homebrew, macos, utilities)
- `shell/` - zsh aliases, functions, and prompt integration, refactored out
  of a personal `.zshrc`
- `themes/` - terminal color/theme definitions
- `experiments/` - small, safe, isolated scripts exploring one concept each
- `learning/` - notes on what was tried and what it taught
- `docs/` - architecture, command reference, install guide, roadmap
- `tests/` - syntax and smoke checks
- `install.sh` / `uninstall.sh` - opt-in installer with backups

## Install

See [docs/installation.md](docs/installation.md). Short version:

```sh
./install.sh
```

The installer backs up your existing `.zshrc`, never overwrites it silently,
and only adds shell startup integration if you opt in.

## Usage

```sh
bhargi            # interactive command center
bhargi system     # system info
bhargi network    # network diagnostics
bhargi git status # git helpers
bhargi --help     # full command list
```

Press `T` in the menu to drop straight into a normal shell. Press `Q` to quit.
See [docs/commands.md](docs/commands.md) for the full command reference.

## Architecture

`bhargi` is a thin dispatcher (`cli/bhargi`) that sources one script per
module from `commands/<module>/`. Each module is plain POSIX-ish zsh, no
framework, no external runtime dependency beyond native macOS tools
(`sw_vers`, `system_profiler`, `sysctl`, `pmset`, `ps`, `lsof`, ...) and
things already on the system (`git`, `python3`, `brew` when present).
Platform-specific code lives behind a single `commands/*/macos.sh`-style
seam so Linux/Windows implementations can be added later without touching
the dispatcher. Details in [docs/architecture.md](docs/architecture.md).

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
