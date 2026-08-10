# Platform abstraction: capability != platform

## What I wanted to understand

Whether "which OS am I on" is actually the right question for a CLI
module to ask before running a feature.

## What I tried

Building `cli/lib/capabilities.zsh` on top of the existing
`cli/lib/platform.zsh`, and wiring both into `termlab platform`. Before
this, modules only ever checked `$TERMLAB_PLATFORM` (macos/linux/wsl)
and picked a code branch. I added a second, narrower check per feature:
is the *tool* this feature needs actually present on *this* machine.

## Commands

```sh
termlab platform
```

which now prints both the OS facts (`uname`, `sw_vers`/`/etc/os-release`)
and, separately, a capability table computed by actually probing for
`pmset`, `osascript`, `notify-send`, `pactl`/`amixer`, `loginctl`, a
package manager, etc. with `command -v`.

## What happened

On this development machine (macOS, no Homebrew-adjacent gaps), every
capability reports `supported`. But writing the Linux branches exposed a
real distinction I'd been collapsing: `commands/linux/linux.zsh`
implements `notify` via `notify-send`, `lock` via `loginctl`, and so on
— but a minimal/headless Linux box (like a CI runner) has *none* of
those installed even though the platform is unambiguously "linux" and
the adapter unambiguously exists. Reporting that as the same kind of
failure as "Windows has no `pactl` at all" would be wrong — one is
"install the tool," the other is "this will never work here."

## What I learned

Two axes, not one:

- **Platform** answers "which adapter code should run" (an architecture
  question, decided once at dispatch time).
- **Capability status** answers "will this specific action work right
  now" (an environment question, decided per-invocation, per-machine).

Conflating them means either false negatives (claiming Linux "doesn't
support notifications" when it's really just `notify-send` not being
installed on one particular box) or false positives (claiming something
"works on Linux" because the adapter file exists, without ever checking
the tool is there). `docs/platforms.md`'s Supported/Partial/Experimental
levels exist for the same reason at the documentation layer: "an adapter
exists" and "this was actually run and verified" are different claims,
and only the CLI's own `command -v` checks (not good intentions) get to
decide which is true.

## Things that surprised me

Windows needed a *third* axis I hadn't planned for: not "platform
adapter missing" or "tool missing," but "adapter exists, was written and
reviewed, and has literally never been executed against a real runtime
in this environment" (no `pwsh` available while building this). That's
why `docs/platforms.md` uses three levels instead of two — a boolean
supported/unsupported can't represent "implemented but unverified"
honestly, and claiming Windows support without ever running the code
would have been exactly the kind of false claim this project is trying
not to make.

## Further experiments

- Cache capability results per session instead of re-probing every
  `termlab platform` call, once probing gets expensive (e.g. package
  manager `--version` calls that shell out).
- Extend capability status to the Windows PowerShell CLI, which
  currently only has platform detection (`Get-TermlabPlatform`), not the
  three-state capability layer the zsh side has.
