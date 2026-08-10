# Security

## Reporting

This is a personal project without a dedicated security team. If you find
a security issue (e.g. a way a module could be tricked into running
unintended commands, or a path where personal data could leak into the
repo), please open a GitHub issue or, for anything sensitive, contact the
maintainer directly rather than filing a public issue.

## Scope and design

- No module reads or writes credentials, tokens, or SSH keys.
- Personal information is never hardcoded — it lives in a gitignored
  `config` file, seeded from `config.example`, which contains only
  placeholder values.
- Destructive operations (process termination, package upgrades, git
  history rewrites) always require an explicit typed confirmation and are
  never run automatically by the installer, the menu, or any startup hook.
- `install.sh`/`uninstall.sh` only ever append to or remove a single
  clearly marked block in `~/.zshrc`; they never overwrite it and always
  back it up first.
- Network calls are limited to explicit user-invoked commands (`bhargi
  network ip`, `http`, `ping`, `dns`) — nothing phones home on its own.

## Known limitations

- Shell scripts trust their own arguments; this project is a personal CLI,
  not a hardened multi-user tool. Don't run it as root, and don't pipe
  untrusted input into `bhargi network http` or similar commands.
