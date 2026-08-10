# Contributing

This is primarily a personal project, but issues and PRs are welcome —
especially bug reports on macOS tool assumptions or ports to other
platforms.

## Ground rules

- Every `commands/<name>/<name>.zsh` module must default to a safe,
  read-only action and require typed `yes` confirmation before anything
  destructive.
- No personal data (names, emails, addresses, tokens, machine-specific
  paths) in committed files. Use `config`/`config.example` for anything
  user-specific.
- New shell scripts should pass `./tests/syntax-check.sh` and, if they
  add a CLI module, `./tests/cli-smoke-test.sh`.
- Prefer native macOS tools over assuming GNU/Linux utilities exist.
- Keep modules independent — the dispatcher should never need special-case
  logic for a specific module.

## Adding a module

1. `mkdir commands/<name>` and add `commands/<name>/<name>.zsh` (own
   shebang, `chmod +x`, a `case` over `${1:-default}`, its own `--help`).
2. Add `<name>` to `BHARGI_MODULES` in `cli/lib/modules.zsh`.
3. Add a menu entry in `cli/lib/menu.zsh` if it should be reachable from
   the interactive UI.
4. Document it in `docs/commands.md`.
5. Run both test scripts before committing.

## Adding a learning note

Use the template in any existing `learning/*/*.md` file. Notes should
describe something genuinely tried, not textbook summaries.

## Commit style

Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, `test:`, `ci:`).
Keep commits scoped to one coherent change.
