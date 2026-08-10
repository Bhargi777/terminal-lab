# Command reference

Run `termlab <module> --help` for any module's own help text; this is a
summary. On macOS/Linux/WSL this is `termlab`; on Windows it's
`./termlab.ps1` from `cli/windows/` (or just `termlab` once profile
integration is installed) — see [cross-platform.md](cross-platform.md).

## platform

| Command | Description |
|---|---|
| `termlab platform` | detected OS/distro/architecture |

## system

| Command | Description |
|---|---|
| `termlab system` / `system info` | OS version, kernel, model, CPU, memory summary (macOS/Linux branch automatically; native cmdlets on Windows) |
| `termlab system battery` | battery charge/health |
| `termlab system memory` | memory breakdown |
| `termlab system disk` | disk usage |
| `termlab system uptime` | system uptime |

## network

| Command | Description |
|---|---|
| `termlab network` / `network overview` | local interfaces + default route |
| `termlab network ping [host]` | ping a host |
| `termlab network dns [host]` | resolve a hostname |
| `termlab network ports` | listening TCP ports |
| `termlab network http <url>` | inspect HTTP response headers/timing |
| `termlab network ip` | public IP |

## filesystem

| Command | Description |
|---|---|
| `termlab filesystem` / `files summary` | current directory listing |
| `termlab filesystem large [dir] [n]` | n largest files under dir |
| `termlab filesystem search <pattern> [dir]` | find files by name |
| `termlab filesystem info <path>` | stat + file type + symlink target |

## processes

| Command | Description |
|---|---|
| `termlab processes` / `processes top [n]` | top processes by CPU |
| `termlab processes mem [n]` | top processes by memory |
| `termlab processes ports` | processes with open connections |
| `termlab processes kill <pid> [signal]` | terminate a process (confirmation required) |

## git

| Command | Description |
|---|---|
| `termlab git` / `git status` | short status |
| `termlab git log [n]` | recent commits |
| `termlab git branches` | local branches with tracking info |
| `termlab git cleanup` | dry-run report only, never deletes |
| `termlab git info` | repo summary |

## python

| Command | Description |
|---|---|
| `termlab python` / `python info` | interpreter/pip/venv status |
| `termlab python venv` | create `.venv` |
| `termlab python packages` | list installed packages |
| `termlab python project <name>` | scaffold a new project directory |

## packages (cross-platform)

Detects whichever package manager is actually installed: brew, apt, dnf,
yum, pacman, zypper (POSIX side); winget, choco (Windows side).

| Command | Description |
|---|---|
| `termlab packages` / `packages info` | detected manager + version |
| `termlab packages list` | installed packages |
| `termlab packages outdated` | packages with available updates |
| `termlab packages upgrade` | upgrade outdated packages (confirmation required) |

## homebrew (macOS-specific)

| Command | Description |
|---|---|
| `termlab homebrew` / `homebrew info` | brew version + package counts |
| `termlab homebrew list` | installed formulae |
| `termlab homebrew outdated` | outdated packages |
| `termlab homebrew update` | refresh Homebrew's index |
| `termlab homebrew upgrade` | upgrade outdated packages (confirmation required) |

## macos

| Command | Description |
|---|---|
| `termlab macos lock` | sleep the display |
| `termlab macos volume [0-100]` | get/set output volume |
| `termlab macos mute` / `unmute` | mute/unmute audio |
| `termlab macos open <app\|url>` | open an app or URL |
| `termlab macos notify <msg> [title]` | macOS notification |
| `termlab macos say <text>` | text-to-speech |
| `termlab macos settings` | open System Settings |

## linux

| Command | Description |
|---|---|
| `termlab linux lock` | lock session (`loginctl`/`xdg-screensaver`) |
| `termlab linux volume [0-100]` | get/set volume (`pactl`/`amixer`) |
| `termlab linux mute` / `unmute` | mute/unmute default sink |
| `termlab linux open <app\|url>` | open via `xdg-open` |
| `termlab linux notify <msg> [title]` | desktop notification (`notify-send`) |
| `termlab linux say <text>` | text-to-speech (`spd-say`/`espeak`) |

## windows (PowerShell CLI only)

| Command | Description |
|---|---|
| `termlab windows lock` | lock the workstation |
| `termlab windows mute` | toggle mute (media-key emulation) |
| `termlab windows volume up\|down` | step volume (no absolute-level setter — see [cross-platform.md](cross-platform.md)) |
| `termlab windows open <app\|url>` | `Start-Process` wrapper |
| `termlab windows notify <msg> [title]` | toast (BurntToast) or `msg.exe` fallback |
| `termlab windows say <text>` | text-to-speech (`System.Speech`) |
| `termlab windows settings` | open Windows Settings |

## utilities

| Command | Description |
|---|---|
| `termlab utilities` / `utilities whoami` | identity banner from config |
| `termlab utilities speed` | network speed test |
| `termlab utilities matrix` | cmatrix rain |

## Menu

Running `termlab` with no arguments opens the interactive menu. `T` exits
to a normal shell; `Q` quits.
