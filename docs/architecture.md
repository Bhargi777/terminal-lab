# Architecture

## Layers

```
cli/bhargi              thin dispatcher: parses argv[0], loads theme/config,
                         hands off to a module script or the menu
cli/lib/modules.zsh      module registry + exec-based dispatch
cli/lib/menu.zsh         interactive menu rendering + input loop
commands/<name>/*.zsh    one self-contained module per domain
shell/                   zsh integration sourced by .zshrc (aliases,
                         functions, prompt, config loader)
themes/                  color variable sets, selected via config
experiments/             standalone scripts, one concept each, never
                         imported by the CLI
learning/                notes, not code
```

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
`osascript`) are confined to `commands/*/*.zsh` and `shell/functions/macos.zsh`.
A future Linux or Windows implementation only needs equivalent scripts at
the same paths — the dispatcher, menu, and config system are already
platform-neutral shell/zsh.

## Configuration

`config.example` documents every setting with a safe default. A gitignored
`config` file overrides it. `shell/functions/config.zsh` sources both (example
first, then the real file) so the CLI always has a full set of variables
even before a user has customized anything.
