# Migration: `bhargi` → `termlab`

The CLI's original name (`bhargi`) was personal branding tied to the
original author. As of this milestone, the project's public identity is
**termlab** — a neutral, cross-platform name unrelated to any individual,
matching the repository name `terminal-lab`.

## Why `termlab`

- No personal name, initials, or username in it.
- Not tied to one OS (unlike, say, a Mac-flavored name).
- Short enough to type as a CLI command daily.
- Matches the repository (`terminal-lab`) so the two identities don't
  drift apart.
- Doesn't collide with an existing command on macOS/Linux/Windows.

## What changed

| Old | New |
|---|---|
| `bhargi` (CLI command) | `termlab` |
| `cli/bhargi` | `cli/termlab` |
| `cli/windows/bhargi.ps1` | `cli/windows/termlab.ps1` |
| `BHARGI_HOME`, `BHARGI_ACTIVE`, `BHARGI_PLATFORM`, ... | `TERMLAB_HOME`, `TERMLAB_ACTIVE`, `TERMLAB_PLATFORM`, ... |
| `bhargi_*` shell functions | `termlab_*` |
| `BHARGI TERMINAL` (menu banner) | `TERMLAB` |
| `~/.zshrc` block markers `# >>> terminal-lab >>>` | unchanged (already repo-scoped, not personal) |

Nothing about *what* the tool does changed — same modules, same
subcommands, same safety rules. Only the name.

## If you installed the old `bhargi` version

1. Pull the latest `main`.
2. Re-run the installer (`./install.sh` or `./install-windows.ps1`).
   It's idempotent: it won't duplicate the startup block, and it adds the
   `termlab` alias without touching anything else.
3. A deprecated `bhargi` compatibility shim remains for one release: it
   prints a one-line deprecation notice to stderr, then runs the same
   command through `termlab`. It will be removed in a future release —
   switch your muscle memory (and any of your own scripts/aliases) to
   `termlab` now.
4. Your gitignored `config` file's keys are unaffected by this rename —
   `BHARGI_STARTUP_ENABLED` and friends still work via the compatibility
   layer, but new installs should use `config.example`'s current
   `TERMLAB_*` keys.

## Author vs. brand

The software's name is neutral. The original author is still credited
where authorship belongs (`LICENSE`, `CONTRIBUTING.md`) — that's a
separate concern from what the *tool* is called, and this migration only
changes the latter.
