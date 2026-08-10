# Installation

terminal-lab supports macOS, Linux (including WSL), and Windows. See
[cross-platform.md](cross-platform.md) for the architecture behind that;
this page is the practical setup steps per OS.

## macOS

### Requirements

- macOS
- zsh (ships with macOS)
- git

Optional, checked and reported by the installer but not required: `gh`,
`curl`, `dig`, `lsof`, `brew`, `python3`, `speedtest`, `cmatrix`.

### Install

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

### Uninstall

```sh
./uninstall.sh
```

## Linux

### Requirements

- zsh (`apt install zsh`, `dnf install zsh`, `pacman -S zsh`, ...)
- git

`install.sh` and `shell/zsh/init.zsh` are the same scripts used on
macOS — they're POSIX/zsh, not macOS-specific, and `commands/system/system.zsh`,
`network.zsh`, and `processes.zsh` already branch to Linux-appropriate
tools internally (`/proc`, `ip`/`ss` over `ifconfig`/`netstat`, GNU `ps`
sort flags). Optional tools checked at install time: `curl`, `dig`,
`brew` (Linuxbrew, if you use it), `python3`. `commands/linux/linux.zsh`
additionally uses `loginctl`/`xdg-screensaver` (lock), `pactl`/`amixer`
(volume), `xdg-open` (open), `notify-send` (notify), and `spd-say`/`espeak`
(text-to-speech) where installed — each checked individually, with a
clear message if missing rather than a silent failure.

### Install

```sh
git clone https://github.com/<you>/terminal-lab.git
cd terminal-lab
./install.sh
```

Same behavior as macOS: backs up `~/.zshrc`, creates `config`, appends
one marked block. `./install.sh --enable-startup` to auto-launch on new
shells; `./uninstall.sh` to remove the integration.

## Windows

### Requirements

- PowerShell 7+ (`pwsh`) — [aka.ms/powershell](https://aka.ms/powershell)
- git for Windows

Windows uses a **separate, native implementation**
(`cli/windows/bhargi.ps1`), not the zsh CLI through WSL, so no WSL
installation is required. If you do have WSL, `bhargi platform` (the zsh
version, run inside WSL) reports it as `wsl`, and the Linux install steps
above apply inside that WSL distro.

### Install

```powershell
git clone https://github.com/<you>/terminal-lab.git
cd terminal-lab
./install-windows.ps1
```

This will:

1. Report the PowerShell version and check for `git`, `winget`, `choco`,
   `python`/`py`.
2. Back up your existing `$PROFILE` to `$PROFILE.bhargi-backup-<timestamp>`.
3. Create `config` from `config.example` if it doesn't exist yet.
4. Append one clearly marked, idempotent block to `$PROFILE` that
   dot-sources `shell/windows/init.ps1`.

Enable auto-launch on new PowerShell sessions:

```powershell
./install-windows.ps1 -EnableStartup
```

Then reload your profile:

```powershell
. $PROFILE
bhargi
```

### Uninstall

```powershell
./uninstall-windows.ps1
```

Removes only the marked block from `$PROFILE`, with its own backup first.

### Windows Terminal

No special configuration is required — `bhargi.ps1` and the profile
integration work in both Windows Terminal and the legacy `conhost`
console. `Get-BhargiPlatform` reports whether the current session is
running inside Windows Terminal (`$env:WT_SESSION`), shown in the
interactive menu header.

## Configuration (all platforms)

Edit `config` (gitignored) to set your display name, theme, editor,
browser, and projects directory, and to toggle `BHARGI_STARTUP_ENABLED` —
see `config.example` for the full list. The file format is identical on
every OS; both `shell/functions/config.zsh` and `commands/utilities/utilities.ps1`
/ `shell/windows/init.ps1` read the same `KEY=value` lines.

## Startup integration: how it differs per OS, and how to disable it

| | macOS / Linux | Windows |
|---|---|---|
| Hook file | `~/.zshrc` | `$PROFILE` |
| Marked block sourced | `shell/zsh/init.zsh` | `shell/windows/init.ps1` |
| Enable | `./install.sh --enable-startup` | `./install-windows.ps1 -EnableStartup` |
| Disable (keep installed) | set `BHARGI_STARTUP_ENABLED=0` in `config` | same — `config` is shared |
| Remove entirely | `./uninstall.sh` | `./uninstall-windows.ps1` |
| Recursion guard | `$BHARGI_ACTIVE` (zsh env var) | `$env:BHARGI_ACTIVE` |

On every platform, startup integration is opt-in, guarded against
relaunching itself, and reversible without touching anything outside the
one marked block each installer adds.
