# curl's timing breakdown

## What I wanted to understand

Where time actually goes in an HTTP request — is it DNS, the TCP handshake,
TLS, or waiting on the server.

## What I tried

Used `curl -w` with its timing variables against a single URL instead of
guessing from total latency alone. See `experiments/networking/curl.sh`
and `commands/network/network.zsh`'s `http` subcommand.

## Commands

```sh
curl -sS -o /dev/null "$url" -w \
  'lookup: %{time_namelookup}s\nconnect: %{time_connect}s\ntls: %{time_appconnect}s\nttfb: %{time_starttransfer}s\ntotal: %{time_total}s\n'
```

## What happened

Each `time_*` variable is cumulative from request start, not a delta —
`time_total - time_starttransfer` is the actual body-transfer time, and
`time_starttransfer - time_appconnect` is server processing time (time to
first byte after the handshake finished).

## What I learned

`termlab network http` reports `time_total` and status code, which is
enough for a quick health check, but a real latency investigation needs
the full breakdown to tell "slow DNS" apart from "slow server."

## Things that surprised me

`time_appconnect` is `0` for plain HTTP (no TLS step to time) — easy to
misread as "TLS was instant" instead of "there was no TLS."

## Further experiments

- Compare cold vs warm DNS cache timing for the same host.
- HTTP/2 vs HTTP/1.1 connection reuse effects on repeated requests.
