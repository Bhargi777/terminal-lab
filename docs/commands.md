# Command reference

Run `bhargi <module> --help` for any module's own help text; this is a
summary.

## system

| Command | Description |
|---|---|
| `bhargi system` / `system info` | macOS version, kernel, model, CPU, memory summary |
| `bhargi system battery` | battery charge/health via `pmset` |
| `bhargi system memory` | memory breakdown via `vm_stat` |
| `bhargi system disk` | disk usage via `df` |
| `bhargi system uptime` | system uptime |

## network

| Command | Description |
|---|---|
| `bhargi network` / `network overview` | local interfaces + default route |
| `bhargi network ping [host]` | ping a host |
| `bhargi network dns [host]` | resolve a hostname |
| `bhargi network ports` | listening TCP ports |
| `bhargi network http <url>` | inspect HTTP response headers/timing |
| `bhargi network ip` | public IP |

## filesystem

| Command | Description |
|---|---|
| `bhargi filesystem` / `files summary` | current directory listing |
| `bhargi filesystem large [dir] [n]` | n largest files under dir |
| `bhargi filesystem search <pattern> [dir]` | find files by name |
| `bhargi filesystem info <path>` | stat + file type + symlink target |

## processes

| Command | Description |
|---|---|
| `bhargi processes` / `processes top [n]` | top processes by CPU |
| `bhargi processes mem [n]` | top processes by memory |
| `bhargi processes ports` | processes with open connections |
| `bhargi processes kill <pid> [signal]` | terminate a process (confirmation required) |

## git

| Command | Description |
|---|---|
| `bhargi git` / `git status` | short status |
| `bhargi git log [n]` | recent commits |
| `bhargi git branches` | local branches with tracking info |
| `bhargi git cleanup` | dry-run report only, never deletes |
| `bhargi git info` | repo summary |

## python

| Command | Description |
|---|---|
| `bhargi python` / `python info` | interpreter/pip/venv status |
| `bhargi python venv` | create `.venv` |
| `bhargi python packages` | list installed packages |
| `bhargi python project <name>` | scaffold a new project directory |

## homebrew

| Command | Description |
|---|---|
| `bhargi homebrew` / `homebrew info` | brew version + package counts |
| `bhargi homebrew list` | installed formulae |
| `bhargi homebrew outdated` | outdated packages |
| `bhargi homebrew update` | refresh Homebrew's index |
| `bhargi homebrew upgrade` | upgrade outdated packages (confirmation required) |

## macos

| Command | Description |
|---|---|
| `bhargi macos lock` | sleep the display |
| `bhargi macos volume [0-100]` | get/set output volume |
| `bhargi macos mute` / `unmute` | mute/unmute audio |
| `bhargi macos open <app\|url>` | open an app or URL |
| `bhargi macos notify <msg> [title]` | macOS notification |
| `bhargi macos say <text>` | text-to-speech |
| `bhargi macos settings` | open System Settings |

## utilities

| Command | Description |
|---|---|
| `bhargi utilities` / `utilities whoami` | identity banner from config |
| `bhargi utilities speed` | network speed test |
| `bhargi utilities matrix` | cmatrix rain |

## Menu

Running `bhargi` with no arguments opens the interactive menu. `T` exits
to a normal shell; `Q` quits.
