# Unix permission bits

## What I wanted to understand

What `chmod +x` actually flips, and why `ls -l` shows ten characters like
`-rwxr-xr-x`.

## What I tried

Created a file, ran `ls -l` after each of several `chmod` calls (numeric
and symbolic forms). See `experiments/filesystem/permissions.sh`.

## Commands

```sh
chmod 600 file.txt
chmod +x file.txt
chmod u=rw,g=r,o= file.txt
stat -f '%Mp%Lp' file.txt
```

## What happened

- `600` → `-rw-------` (owner read/write, nobody else anything)
- `+x` on top of that → `-rwx--x--x` (execute added for *all three*
  classes, not just owner, because `+x` with no class prefix means "all")
- `u=rw,g=r,o=` → `-rw-r-----` (explicit, not additive — each class set
  exactly)

## What I learned

`chmod +x` is a trap for scripts meant to be owner-only executable —
`chmod u+x` is what I actually want in most of `install.sh`'s file
permission handling. Numeric mode (`755`, `644`) is unambiguous; symbolic
mode is more readable when only touching one class.

## Things that surprised me

The leading character in `ls -l` (`-`, `d`, `l`) isn't part of the
permission bits at all — it's the file type. `stat -f '%Mp%Lp'` gives the
type + octal mode without having to parse `ls` output.

## Further experiments

- setuid/setgid/sticky bits (the 4th octal digit).
- ACLs via `ls -le` on macOS, separate from POSIX permission bits.
