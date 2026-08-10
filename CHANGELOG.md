# Changelog

All notable changes to this project are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/).

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
