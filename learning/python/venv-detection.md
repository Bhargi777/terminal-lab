# Detecting an active virtualenv from a script

## What I wanted to understand

How a shell script (not Python itself) can tell whether it's currently
running inside an activated virtualenv.

## What I tried

Compared `$VIRTUAL_ENV` presence against just checking for a `.venv`
directory in the current path. See `commands/python/python.zsh`'s `info`
subcommand.

## Commands

```sh
python3 -m venv .venv
source .venv/bin/activate
echo "$VIRTUAL_ENV"
```

## What happened

Activating a venv exports `VIRTUAL_ENV` pointing at the venv's root
directory — that's the only reliable signal from outside Python itself.
A `.venv` directory existing on disk says nothing about whether it's
*active* in the current shell.

## What I learned

`bhargi python info` checks `$VIRTUAL_ENV` first (active), then falls back
to checking for a `.venv` directory (present but inactive), rather than
assuming one implies the other.

## Things that surprised me

Activating a venv doesn't change `python3`'s resolved path in a *subshell*
that doesn't inherit the exported `PATH` change correctly if `activate` was
sourced with the wrong shell (`bash` script sourced from `zsh` mostly works,
but `activate.fish` very much does not).

## Further experiments

- `pyenv`-managed versions vs `venv`-managed environments stacking.
- What `deactivate` actually unsets.
