# macOS native tools vs Linux assumptions

## What I wanted to understand

Which system-info commands I could rely on existing on a stock macOS
install, since a lot of online shell snippets assume Linux (`free -h`,
`lscpu`, `/proc/cpuinfo`).

## What I tried

Built `commands/system/system.zsh` using only tools macOS ships with, and
checked each one exists via `command -v`.

## Commands

```sh
sw_vers -productVersion
sysctl -n hw.memsize
sysctl -n machdep.cpu.brand_string
vm_stat
pmset -g batt
```

## What happened

There's no `/proc` on macOS (it's not Linux — no procfs at all), no `free`,
no `lscpu`. `sysctl` and `vm_stat` cover the same ground but with different
units and formatting (`hw.memsize` is in bytes; `vm_stat` reports in pages,
not bytes, so `page_size * count` is required to get anything human-usable).

## What I learned

Any command output division by an OS-specific unit (page size, block size)
belongs in one place per module, not copy-pasted, since `vm_stat`'s page
size (4096 bytes) is an assumption, not a universal constant — worth
reading from `pagesize` if this ever needs to be exact on other hardware.

## Things that surprised me

`pmset -g batt` output format includes a trailing `;` in a way that's easy
to mis-parse with a naive `awk -F';'` — the field boundaries shift when a
Mac is "AC Power" vs "Battery Power" plus charging state.

## Further experiments

- `system_profiler SPHardwareDataType -json` for structured output instead
  of scraping text.
- Compare `sysctl -a` output across Intel vs Apple Silicon Macs.
