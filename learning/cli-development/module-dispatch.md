# Building a module dispatcher instead of one giant script

## What I wanted to understand

How to structure a multi-command CLI (`termlab system`, `termlab network`,
...) without one file growing into an unmaintainable case statement.

## What I tried

Split each domain into its own executable at `commands/<name>/<name>.zsh`,
and made `cli/termlab` a thin dispatcher that `exec`s the right script by
convention (`termlab_module_path` in `cli/lib/modules.zsh`) instead of
hardcoding a big switch of implementations.

## Commands

```sh
termlab system info
termlab git status
termlab --help
```

## What happened

Adding a new module means: create `commands/<name>/<name>.zsh`, add it to
the `TERMLAB_MODULES` array, done — the dispatcher doesn't need to know
anything about the module's internal subcommands.

## What I learned

Each module owning its own subcommand parsing (`case "${1:-default}"`)
keeps the dispatcher's job to exactly one thing: find the right script and
hand off argv. That's also what makes the "T -> Terminal" escape hatch and
the recursive-launch guard (`TERMLAB_ACTIVE`) simple — they live in exactly
one place instead of being duplicated per module.

## Things that surprised me

Making every module script independently executable (`chmod +x`, its own
shebang) means each one can also be run directly during development
(`./commands/system/system.zsh info`) without going through the CLI at
all — useful for the `zsh -n` syntax checks in `tests/`.

## Further experiments

- A `commands/<name>/help.txt` convention so `--help` output doesn't live
  inside a heredoc in every module.
- Tab completion generated from the same `TERMLAB_MODULES` array.
