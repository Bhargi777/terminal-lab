# Architecture

## Layers

```
cli/bhargi               zsh dispatcher (macOS/Linux/WSL): parses argv[0],
                          loads theme/config/platform, hands off to a
                          module script or the menu
cli/lib/platform.zsh      OS detection (macos/linux/wsl/unknown)
cli/lib/modules.zsh       module registry + exec-based dispatch
cli/lib/menu.zsh          interactive menu, platform-aware item 9
cli/windows/bhargi.ps1    PowerShell dispatcher (native Windows), same
                          command vocabulary, independent implementation
cli/windows/lib/*.ps1     Windows platform detection + module dispatch
commands/<name>/*.zsh     zsh module implementation (macOS/Linux/WSL)
commands/<name>/*.ps1     PowerShell module implementation (Windows),
                          where one exists for that module
shell/zsh/, shell/windows/  per-OS startup integration, sourced by
                          .zshrc / $PROFILE respectively
shell/aliases/, functions/, prompt/  zsh-only personal shell layer
themes/                   color variable sets, selected via config
experiments/              standalone scripts, one concept each, never
                          imported by the CLI
learning/                 notes, not code
```

See [cross-platform.md](cross-platform.md) for how the two CLI
implementations relate to each other and what's shared vs platform-only.

## Module contract

Every module lives at `commands/<name>/<name>.zsh`, is independently
executable (`chmod +x`, its own shebang), and:

- Defaults to a safe, read-only action when called with no subcommand.
- Parses its own subcommands via a `case` statement.
- Prints its own `--help`/`help` text.
- Requires a typed `yes` confirmation before anything destructive
  (`processes kill`, `homebrew upgrade`).

`cli/lib/modules.zsh` knows only the module *name* — it execs
`commands/<name>/<name>.zsh "$@"` and nothing else, so a new module is a
new directory plus one line added to `BHARGI_MODULES`, not a change to the
dispatcher.

## Startup integration and the recursion guard

`install.sh` can append a single sourcing line to `~/.zshrc` that loads
`shell/zsh/init.zsh`. That file optionally launches `bhargi` on new
interactive shells, gated by `BHARGI_STARTUP_ENABLED` in `config`.

Recursion is prevented by `BHARGI_ACTIVE`: `cli/bhargi` exports it on
start, and the startup hook checks it's unset before auto-launching.
Choosing `T` (Terminal) in the menu unsets it before `exec`ing a fresh
shell, so that fresh shell won't relaunch the menu even with startup
integration on.

## Cross-platform seam

All macOS-specific calls (`sw_vers`, `system_profiler`, `sysctl`, `pmset`,
`osascript`) are confined to the `mac_*` functions inside `commands/system/system.zsh`
and `commands/processes/processes.zsh`, plus `commands/macos/macos.zsh` and
`shell/functions/macos.zsh` entirely. Linux equivalents live alongside
them as `linux_*` functions in the same files (branching on
`$BHARGI_PLATFORM`, set by `cli/lib/platform.zsh`) or as the sibling
`commands/linux/linux.zsh` module. Windows has no zsh runtime at all, so
it gets a fully separate PowerShell tree (`cli/windows/`, `commands/*/*.ps1`)
rather than a branch inside the same file — see
[cross-platform.md](cross-platform.md).

## Configuration

`config.example` documents every setting with a safe default. A gitignored
`config` file overrides it. `shell/functions/config.zsh` sources both (example
first, then the real file) so the CLI always has a full set of variables
even before a user has customized anything.
