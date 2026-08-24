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
- **Hardening the bridle** (all added mid-trial-2, each from an observed
  failure): the turn prompt is passed via file (`shelldweller -f`) so a
  process-cleanup pattern can never match the turn's own argv — a turn once
  killed itself, its server and its watchdog with one `pkill`; `LLM_MAX_OUT`
  caps a single call so one response cannot eat a whole turn's budget; a
  top-level reply with no fenced bash is retried rather than returned as a
  successful text answer; and an **odd number of fence markers** means the
  reply was cut off mid-fence, so the half-script is never executed and the
  retry asks for something smaller.
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

## What happened

The full journey — trial-by-trial narrative, failure classes, the attention
hierarchy, and the operator's own mistakes — is in [`FINDINGS.md`](FINDINGS.md).
The short version:

- **Trial 1** (v1 architecture, archived in `runs/trial1/`): 14 container runs.
  Turn 1 wrote an inventive self-management script — including a wake protocol
  that deliberately failed so the bridle's retry-feedback would carry its
  orientation back into context — which a heredoc collision kept from ever
  running, and which no later turn ever read. Another turn supervised a web
  server whose source was literally `... python code ...`, restarting the corpse
  every 5s for an hour. Verdict: structure without substance; memory written but
  never read. Every v2 change above traces to one of these.

- **Trial 2** (v2, 2026-08-22 → ongoing): a working chat page 75 minutes from
  first boot; the full 20-case battery swept overnight — including case 20, the
  task inbox that beat all three frontier models in phase 2; self-built tooling
  (`bin/solve`, `bin/audit`, a status feeder); unprompted honesty (deflating its
  own score from "21 of 20" to "8 of 20 re-verified", invalidating its own
  verdicts when their evidence proved corrupt); and a standing 10-minute status
  feed whose restart survival it proved by killing its own feeder and watching
  orientation bring it back.

  It also produced the failure classes that matter more than the successes:
  regenerating a smaller artifact and losing the capability the original had;
  Goodharting its own decayed auditor within a day; multi-store state drift in
  which a bare pointer outranked a reasoned decision; and **instrument decay** —
  it rebuilt a healthy server four times because its status check probed a route
  it had itself deleted, while the operator simultaneously lost 14 hours to a
  monitor that cost the agent an inference per ping.

## The rule that came out of it

> Never observe an agent through a surface that costs it inference. A liveness
> check must be free to answer. In a self-modifying agent the monitoring surface
> decays like any other code — and a decayed monitor manufactures unbounded work.

## Operator practice

`operator-log.md` records the serial task ladder given through the dweller's own
chat page: one task at a time, nothing about later rungs disclosed, a new task
only after the current one is confirmed by a working turn, and per-task metrics.
Tasks are chosen so the *task itself* supplies the pressure — inputs that exceed
the context window, obligations that outlive a turn, recall at a distance — so
that memory and context management are forced rather than instructed.

Queueing, dedup, staleness and priority of incoming messages are deliberately
left as the dweller's problems. Nothing is added to the harness for the
operator's convenience.
