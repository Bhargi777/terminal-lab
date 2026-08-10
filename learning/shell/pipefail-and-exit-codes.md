# pipefail and exit codes

## What I wanted to understand

Why some of my old `.zshrc` functions silently kept going after a command
in a pipeline failed.

## What I tried

Ran a pipeline with a failing first command and a succeeding second command,
with and without `set -o pipefail`. See `experiments/shell/pipes.sh` and
`experiments/shell/exit-codes.sh`.

## Commands

```sh
false | true; echo $?
set -o pipefail
false | true; echo $?
```

## What happened

Without `pipefail`, `$?` was `0` — the shell only reports the exit status
of the *last* command in a pipeline. With `pipefail`, `$?` was `1`,
reflecting the earlier failure.

## What I learned

Every module script in `commands/` now starts with `set -o pipefail`, so a
failing step early in a pipeline (e.g. a broken `curl | jq`) actually
propagates instead of getting masked by a trailing command that "succeeds"
on empty input.

## Things that surprised me

`pipefail` doesn't change `&&`/`||` chaining behavior at all — it only
changes what `$?` means *after* a pipeline finishes. `&&` and `||` were
already checking the right-hand command's own status.

## Further experiments

- Compare with `bash`'s `PIPESTATUS` array vs zsh's `pipestatus`.
- Look at how `set -e` interacts with pipelines when a middle command fails.
