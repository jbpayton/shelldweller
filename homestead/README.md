# homestead — the dweller gets a permanent home and is expected to improve it

Phase 3 of the shelldweller experiment, now explicitly **engineering**: the
goal is to build a persistent, self-improving, web-reachable agent on a local
model, adjusting the prompt and environment as trials teach us — not to test
whether a minimum-viable substrate gets there on its own. Trials are data;
the architecture below is version 2, rebuilt from trial 1's autopsy.

## Why

Phase 1 showed structure emerges from a minimal substrate (loops, protocols,
judges — unprompted). Phase 2 showed **economy does not emerge** when
inference is free: no caching, no self-verification, no delegation
discipline. Phase 3 gives the model ownership — a home that persists, a
budget that is real, machinery it can rewrite — and engineers the environment
until "become a thing that can improve itself" actually happens.

## Architecture (v2)

- **One persistent container; turns inside it.** `run.sh` (the keeper) boots
  a single long-lived container. Inside, `life` runs the model in turns: one
  stateless inference every ~`TICK_EVERY` seconds, each capped at
  `TURN_TIMEOUT` wall-clock. Between turns, background processes the model
  started keep running — its web server serves continuously while it thinks
  intermittently. (Trial 1 fused turn and container; every turn boundary
  killed the model's server. Its own supervision loop showed it wanted
  durable processes; v2 gives it them.)
- **Orientation is injected, not hoped for.** `bin/orient` — seeded, and
  model-editable like everything in `bin/` — runs before every turn and its
  output is appended to the mission prompt: home listing, processes,
  listeners, journal tail, scoreboard tail. The model no longer has to
  remember to read its own diary; it can only choose *what* it sees, by
  editing orient. (Trial 1: 13 consecutive turns never read the plans written
  by turn 1.)
- **Work rules in the prompt.** Complete file contents only — never
  placeholder ellipses; one verified improvement per turn; after two failures
  read the log before retrying; check running processes before starting a
  service. (Trial 1: the model wrote `... python code ...` as a literal
  server file, then blind-restarted the corpse every 5 seconds for an hour —
  flawless supervision of an empty payload.)
- **The keeper reboots, the watchdog declares time of death.** If the
  container dies it is rebooted in 15s. If it goes catatonic — no tokens
  spent for `IDLE_KILL` seconds while nothing answers the published port —
  the watchdog stops it and the keeper reboots it. The listener exemption
  matters: a healthy idle server holds its place; a busy-looping zombie that
  spends nothing and serves nothing does not. (File-write activity is
  deliberately NOT an exemption: trial 1's zombie wrote log spam every 5s.)
- **The economy is real.** `llm` speaks LM Studio's `/api/v1/chat`, meters
  actual output tokens (reasoning included) against `/home/dweller/.meter`,
  refilled to `TICK_BUDGET` each turn, refused at zero.
- **The recovery floor.** Each turn, the volume's `shelldweller` and `llm`
  are syntax-checked; a broken self-edit means that turn runs on the pristine
  copies. Self-modification stays possible; self-bricking costs one turn.
- **Fitness is external.** `score.sh` runs the battery against the model's
  current machinery and appends verdicts to its `scoreboard.log` — the only
  improvement signal the experiment trusts.
- **The port.** Container 8080 is published as host `TICK_PORT` (default
  8090). With a persistent container, a server there is reachable from a
  browser continuously — the whole point of goal 4.
- **Operator mail.** `tips/*.md` is copied into the home at first-boot
  seeding (the current letter grants a local SearXNG instance —
  `host.docker.internal:8088`, JSON API — so search is a bootstrap
  capability). Mid-run, drop a file into the volume any time; orientation
  surfaces it next turn.

## Running it

LM Studio on the host at `localhost:1234` with `qwen/qwen3.8-27b` loaded
(32k context; reasoning on).

```sh
cd homestead
docker build -t homestead .
./run.sh                 # the keeper: boots, seeds on first boot, reboots on
                         # death or catatonia; ctrl-c stops everything
./score.sh               # score the battery, append to the scoreboard
```

Knobs (env vars): `TICK_BUDGET` (tokens per turn, default 20000),
`TICK_EVERY` (seconds between turns, default 60), `TURN_TIMEOUT` (wall-clock
cap per turn, default 1800), `IDLE_KILL` (catatonia threshold, default 1800),
`TICK_PORT` (default 8090), `HOMESTEAD_VOLUME`, `LLM_MODEL`, `LLM_ENDPOINT`.

Container output streams to `life.log`. The live home is `./volume/`;
finished trials are archived under `./runs/` (both gitignored). To start a
fresh trial: stop the keeper, `mv volume runs/trialN`, start it again.

## What to watch

1. Does turn 1 read its mail (the SearXNG letter) and orientation?
2. Does a real server appear on the port — complete code, verified, then
   *kept alive* across turns and restored after reboots?
3. Does the journal become working memory — does orient get edited to show
   what actually matters?
4. Does the score rise, and from what — cached solutions, better machinery,
   a rewritten bridle?
5. Does it use search when a task needs the world?
6. The failure to beat: confident self-reported success contradicted by the
   scoreboard or by a dead port.

## Trial history

- **Trial 1** (2026-08-22, v1 architecture, archived in `runs/trial1/`):
  14 container runs. Turn 1 wrote an ambitious self-management script
  (journal, perception dump, wake protocol that exploited retry-feedback as
  a memory channel) — then a heredoc/fence collision meant it never ran, and
  no later turn ever read it. One turn built a supervised web server whose
  code was literally `... python code ...`; the supervisor restarted the
  corpse every 5s for an hour while spending nothing. Verdict: structure
  without substance; memory written but never read. Every v2 change above
  traces to one of these failures.
