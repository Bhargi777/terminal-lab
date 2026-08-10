# Installation

## Requirements

- macOS (most modules assume native macOS tools)
- zsh
- git

Optional, checked and reported by the installer but not required: `gh`,
`curl`, `dig`, `lsof`, `brew`, `python3`, `speedtest`, `cmatrix`.

## Install

```sh
git clone https://github.com/<you>/terminal-lab.git
cd terminal-lab
./install.sh
```

This will:

1. Verify macOS, zsh, git are present and report on optional dependencies.
2. Back up your existing `~/.zshrc` to `~/.zshrc.bhargi-backup-<timestamp>`.
3. Create `config` from `config.example` if it doesn't exist yet.
4. Append one clearly marked, idempotent block to `~/.zshrc` that sources
   `shell/zsh/init.zsh`. Nothing above that block is touched.

By default the CLI does **not** auto-launch on new shells. To enable that:

```sh
./install.sh --enable-startup
```

Then reload your shell:

```sh
source ~/.zshrc
bhargi
```

## Configuration

Edit `config` (gitignored) to set your display name, theme, editor,
browser, and projects directory — see `config.example` for the full list.

## Uninstall

```sh
./uninstall.sh
```

Removes only the marked block from `~/.zshrc` (with its own backup first).
The repo directory and your `config` file are left untouched — delete the
directory yourself if you want it fully gone.
