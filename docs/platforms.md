# Platform support

## Request flow

```
CLI
  ↓
Core (config, theme, dispatch)
  ↓
Capability Interface (cli/lib/capabilities.zsh)
  ↓
Platform Adapter (mac_*/linux_* branches, commands/{macos,linux}/*.zsh,
                   or the whole cli/windows/ tree)
  ↓
Native OS Implementation (sysctl, /proc, Get-CimInstance, ...)
```

`termlab system` means "show system information," not "run
`system_profiler`." The CLI and its modules never assume a specific OS
command exists — they ask a capability a question (`termlab_capability_status
battery`) or branch on `$TERMLAB_PLATFORM`, and the platform-specific code
answers using whatever native tool actually exists there.

## Support levels

- **Supported** — implemented, and exercised by the test suite on that
  platform (locally or in CI).
- **Partial** — implemented, but with a real, documented gap (a
  feature the OS doesn't cleanly expose, or a code path only reviewed,
  not executed).
- **Experimental** — implemented but never run against a real instance
  of that platform in this project's development environment; CI syntax-
  checks it, nothing more.

Nothing below is marked Supported unless it has actually run and been
checked in this repository — not just "detection exists for it."

## Matrix

| Feature | macOS | Linux | WSL | Windows |
|---|---|---|---|---|
| Platform detection | Supported | Supported | Supported | Experimental |
| Capability detection | Supported | Supported | Supported | — (not implemented) |
| System info | Supported | Partial¹ | Partial¹ | Experimental |
| Network diagnostics | Supported | Partial¹ | Partial¹ | Experimental |
| Filesystem inspection | Supported | Supported | Supported | Experimental |
| Process inspection/kill | Supported | Partial² | Partial² | Experimental |
| Git helpers | Supported | Supported | Supported | Experimental |
| Python helpers | Supported | Supported | Supported | Experimental |
| Package manager detection | Supported | Partial³ | Partial³ | Experimental |
| Lock/volume/notify/open/say | Supported (macos module) | Partial⁴ (linux module) | Partial⁴ | Experimental |
| Startup integration | Supported | Partial⁵ | Partial⁵ | Experimental |
| CI validation | Supported (macos-latest job) | Supported (ubuntu-latest job) | — (no CI runner) | Partial (parse-check only, windows-latest job) |

¹ Implemented and tested on this development machine (macOS); the Linux
branches (`/proc`, `ip`/`ss`, GNU `ps` flags) are reviewed and covered by
CI on `ubuntu-latest`, but weren't hand-verified against every distro.
² `kill` requires typed confirmation on both platforms; GNU vs BSD `ps`
sort-flag handling is CI-tested on Linux, not manually verified on every
distro's `ps` variant.
³ apt/dnf/yum/pacman/zypper detection logic is written and CI-syntax-
checked; only the `brew` path has been run against a real package
manager in this project.
⁴ Each Linux automation subcommand checks for its own tool
(`loginctl`/`pactl`/`notify-send`/`xdg-open`/`spd-say`) and fails
clearly if missing, but hasn't been run on a real desktop Linux install
here — only in Linux CI, which has no desktop session.
⁵ `install.sh`/`shell/zsh/init.zsh` are identical on macOS and Linux and
tested against a fake `$HOME` on macOS; not run on a real Linux `~/.zshrc`.

Windows is Experimental across the board: `cli/windows/` is a complete,
independently written implementation (see [cross-platform.md](cross-platform.md)),
parse-checked by `tests/windows-syntax-check.ps1` in CI on `windows-latest`,
but this development environment has no `pwsh`, so nothing on the Windows
side has been executed end-to-end here. Treat it as a solid first cut
that needs real-world Windows testing before calling it Supported.

## Why platform abstraction matters

See [learning/cli-development/platform-abstraction.md](../learning/cli-development/platform-abstraction.md)
for what this project actually learned building the capability layer —
concretely, the difference between "no adapter for this" and "adapter
exists, tool isn't installed" turned out to matter more than expected
once `termlab platform` had to report both truthfully instead of just
printing green checkmarks for everything.
