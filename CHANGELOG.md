# Changelog

All notable changes to this project are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/).

## [0.2.0] — Cross-platform milestone

### Added

- Platform detection (`cli/lib/platform.zsh`, `bhargi platform`):
  macOS / Linux / WSL / unknown.
- Native Windows PowerShell CLI (`cli/windows/bhargi.ps1`) with system,
  network, filesystem, processes, git, python, packages, windows
  automation, and utilities modules — an independent implementation
  alongside the zsh CLI, not a WSL wrapper.
- Cross-platform `packages` module detecting brew/apt/dnf/yum/pacman/
  zypper/winget/choco.
- `commands/linux/linux.zsh` desktop automation (lock/volume/notify/
  open/say via loginctl, pactl/amixer, notify-send, xdg-open, spd-say).
- Per-OS startup integration on Windows (`install-windows.ps1`,
  `uninstall-windows.ps1`, `shell/windows/init.ps1`) with the same
  opt-in, recursion-guarded design as the existing macOS/Linux installer.
- `docs/cross-platform.md` and expanded `docs/installation.md` covering
  macOS, Linux, and Windows setup, and what's shared vs platform-specific.
- `tests/platform-detection-test.sh` and `tests/windows-syntax-check.ps1`,
  plus separate macOS/Linux/Windows CI jobs.
- Interactive menu now shows the detected platform and routes item 9 to
  the right OS-automation module automatically.

### Fixed

- `ps` sort flags in `commands/processes/processes.zsh`: GNU `ps -r`
  (Linux) means "running only," not "sort by CPU" like BSD `ps -r`
  (macOS) — top/mem now use the correct flags per platform.

### Changed

- `commands/system/system.zsh` and `commands/network/network.zsh` now
  branch internally between macOS and Linux/WSL tooling
  (`/proc`+`ip`/`ss` vs `sysctl`+`ifconfig`/`netstat`) instead of
  assuming macOS only.
- `tests/cli-smoke-test.sh` now exercises each module's `--help` instead
  of its bare default action, since several defaults depend on tools
  that legitimately aren't present on every machine (e.g. Homebrew on
  Linux) — that's an environment gap, not a dispatch bug.

## [0.1.0] — Initial milestone

### Added

- `bhargi` CLI with interactive menu and module dispatcher, including a
  `T -> Terminal` escape hatch guarded against recursive relaunch.
- Modules: system, network, filesystem, processes, git, python, homebrew,
  macos, utilities.
- Configuration system (`config.example` + gitignored `config`) and a
  two-theme color system (`default`, `neon`).
- Shell integration refactored out of a personal `.zshrc`: aliases,
  dev/macos helper functions, starship prompt, safe fallbacks for missing
  tools.
- Terminal UI, shell, filesystem, process, networking, macOS, and git
  experiments under `experiments/`.
- Learning notes under `learning/` covering pipefail, Unix permissions,
  macOS-vs-Linux tooling, curl timing, git reflog, Python venv detection,
  and CLI module dispatch design.
- `install.sh` / `uninstall.sh` with backups and idempotent, opt-in
  startup integration.
- Syntax checks and a CLI smoke test, wired into GitHub Actions CI.
- Project documentation: README, architecture, command reference,
  installation guide, roadmap, contributing guide, security policy.
