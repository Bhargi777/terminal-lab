# reflog as a safety net

## What I wanted to understand

Whether `git reset --hard` actually destroys commits, or just makes them
harder to reach.

## What I tried

Built a throwaway repo, made three commits, ran `git reset --hard HEAD~2`,
then tried to get the "lost" commit back using `git reflog`. See
`experiments/git/reflog.sh`.

## Commands

```sh
git reset --hard HEAD~2
git reflog
git reset --hard <sha-from-reflog>
```

## What happened

`git log` after the reset showed only the first commit — the second and
third looked gone. `git reflog` still listed every HEAD movement, including
the SHA of the "third commit" before it was reset away. Resetting to that
SHA brought the full history back.

## What I learned

`termlab git cleanup` in this repo deliberately never runs `git reset --hard`
or `git clean -fd` itself — it only prints what *would* be affected — but
this experiment is why that caution is more about avoiding surprise than
avoiding true data loss: local reflog entries expire (default 90 days for
reachable, 30 for unreachable), so it's a safety net, not a permanent one.

## Things that surprised me

The reflog is entirely local — it's never pushed, never cloned, and
`git clone` of your own repo elsewhere won't have it. A "recoverable" reset
on a machine you're about to wipe is not actually recoverable.

## Further experiments

- `git fsck --unreachable` after the reflog itself expires.
- How `git gc` interacts with reflog expiry.
