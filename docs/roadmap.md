# Roadmap

## Milestone 1 — Foundation (this release)

- [x] Repository structure
- [x] `termlab` CLI dispatcher + interactive menu
- [x] System, network, filesystem, process modules
- [x] Git, Python, Homebrew, macOS automation modules
- [x] Terminal UI experiments
- [x] Learning documentation seed
- [x] Installer / uninstaller
- [x] Syntax tests + CI

## Milestone 2 — Depth

- [ ] Config-driven theme switching in the live menu
- [ ] `termlab files search` with fd-like filters
- [ ] `termlab network http` request inspector
- [ ] Process tree view (`termlab processes tree`)
- [ ] More learning notes as new topics come up

## Milestone 3 — Portability (this release)

- [x] Platform detection module (`cli/lib/platform.zsh`, `termlab platform`)
- [x] Linux implementation of system/network/process modules (branched
      internally, not a separate copy)
- [x] Native Windows PowerShell CLI (`cli/windows/termlab.ps1`) with core
      modules: system, network, filesystem, processes, git, python,
      packages, windows automation, utilities
- [x] Cross-platform package manager module (brew/apt/dnf/pacman/zypper/
      winget/choco)
- [x] Linux desktop automation module (lock/volume/notify/open/say)
- [x] Per-OS startup integration with the same opt-in, recursion-guarded
      design on all three platforms
- [ ] Exercise the Windows CLI against a real `pwsh` runtime end-to-end
      (currently parse-checked only, see [cross-platform.md](cross-platform.md))
- [ ] Windows absolute volume control (needs the optional
      `AudioDeviceCmdlets` module, deliberately not bundled yet)
- [ ] WSL-specific conveniences (e.g. surfacing the Windows host's
      clipboard/notifications from inside WSL)

## Milestone 4 — Polish

- [ ] Man page / `--help` generated from module metadata
- [ ] Homebrew tap for `brew install termlab`
- [ ] winget/choco package manifest for the Windows CLI
- [ ] Plugin mechanism for personal one-off commands outside the repo

This roadmap grows whenever something new gets learned about terminals.
