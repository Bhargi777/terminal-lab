# Cross-platform architecture

terminal-lab supports macOS, Linux (including WSL), and Windows through
two independently maintained CLI implementations that share the same
command vocabulary and safety rules, not one codebase pretending to be
universal.

## Why two implementations, not one

zsh doesn't run natively on Windows. Rather than force Windows users
through WSL just to get the CLI, or write everything in a lowest-common-
denominator language, terminal-lab has:

- `cli/bhargi` (zsh) — macOS, Linux, WSL
- `cli/windows/bhargi.ps1` (PowerShell) — native Windows

Both read the same `commands/<name>/` directory structure. A module
provides a `.zsh` file, a `.ps1` file, or both, depending on whether its
behavior is truly platform-specific.

## What's shared vs platform-specific

| Concern | Shared? |
|---|---|
| Command vocabulary (`system info`, `git status`, ...) | Yes — same subcommands, same help text shape |
| Config file format (`config`/`config.example`) | Yes — plain `KEY=value` lines, parsed by both sides |
| Safety rules (confirm before destructive ops) | Yes — enforced independently in each implementation |
| Actual system calls | No — `sysctl` vs `/proc` vs `Get-CimInstance`, etc. |
| Startup integration mechanism | No — `.zshrc` sourcing vs `$PROFILE` dot-sourcing |

Within the zsh side, `commands/system/system.zsh`,
`commands/network/network.zsh`, and `commands/processes/processes.zsh`
further branch internally by `$BHARGI_PLATFORM` (macOS vs Linux/WSL)
because the underlying tools genuinely differ — see
[architecture.md](architecture.md) for the module contract these branches
follow.

## Platform detection

- POSIX side: `cli/lib/platform.zsh`'s `bhargi_detect_platform` reads
  `uname -s`, plus `/proc/version` and `$WSL_DISTRO_NAME` to tell WSL
  apart from real Linux. Exposed as `bhargi platform`.
- Windows side: `cli/windows/lib/Modules.ps1`'s `Get-BhargiPlatform`
  reports OS version, architecture, PowerShell version, whether WSL is
  installed, and whether the session is running inside Windows Terminal.

Both are read-only — detection never changes behavior on its own beyond
choosing which code path to run.

## Menu behavior per platform

The interactive menu's item 9 ("OS Automation") and its label switch
based on detected platform:

- macOS → `commands/macos/macos.zsh`
- Linux/WSL → `commands/linux/linux.zsh`
- Windows → `commands/windows/windows.ps1` (native PowerShell menu)

Every other numbered item routes to the same module name across all
three menus so muscle memory transfers.

## Known limitations (intentionally scoped, not oversights)

- **Windows volume control has no absolute-level setter.** Unlike
  macOS (`osascript ... output volume`) and Linux (`pactl`/`amixer`),
  Windows has no built-in cmdlet for setting an exact volume percentage.
  `bhargi windows volume` emulates media-key presses (mute/step up/down)
  instead of faking a feature that isn't really there. Setting an exact
  level needs the optional `AudioDeviceCmdlets` module — not bundled, to
  keep dependencies minimal.
- **Windows notifications** prefer the optional `BurntToast` module and
  fall back to `msg.exe` (not present on all Windows editions); if
  neither exists, `bhargi windows notify` says so instead of pretending.
- **The Windows CLI is untested against a real PowerShell runtime in
  this development environment** (no `pwsh` available here). It's
  parse-checked (`tests/windows-syntax-check.ps1`) and reviewed
  line-by-line, and CI runs the same parse check on `windows-latest`,
  but hasn't been exercised end-to-end on real Windows. Treat it as a
  solid first cut, not battle-tested.
- **`homebrew` module stays macOS/Homebrew-specific** by design; use the
  cross-platform `packages` module (brew/apt/dnf/pacman/zypper/winget/
  choco) for anything that should work everywhere.
- **Linux package/desktop tooling varies by distro.** `commands/linux/linux.zsh`
  checks for each binary it needs (`loginctl`, `pactl`, `notify-send`,
  ...) and reports clearly when one is missing rather than assuming a
  specific desktop stack.

See [installation.md](installation.md) for OS-by-OS setup and
[roadmap.md](roadmap.md) for what's planned next on each platform.
