# homestead — the dweller gets a permanent home and is expected to improve it

Phase 3 of the shelldweller experiment. It breaks deliberately from phases 1–2
(the command-form experiment in the repo root): the container is no longer
ephemeral-and-done, inference is no longer free, and the substrate is no longer
fixed. One directory persists, one resource is metered, and the model's own
machinery is writable by the model.

## Why

Phase 1 asked whether structure emerges from a minimal substrate. It does:
given bash and an `llm` device, models invent loops, ReAct protocols, judges,
and teams unprompted. Phase 2's autopsy found what does *not* emerge:
**economy**. With free inference and no future, no model cached work, verified
its own success claims, or managed its delegation. The environment had to
supply the meter, the lease, the audit.

Phase 3 asks the next question: given ownership — a home that persists, a
budget that is real, machinery that is its own to rewrite — can the model
**bootstrap its own harness**? The standing mission's first goal is the fixed
point: *become a thing that can improve itself.* Everything else is
downstream of that.

## Design

- **The heartbeat replaces the one-shot.** `run.sh` invokes the dweller on a
  recurring tick, each time with the same standing mission (`mission.txt`).
  Each tick is a fresh, stateless container. Continuity is not a long-lived
  process; it is whatever the dweller writes in its home. Persistence doesn't
  need a daemon — it needs a diary.
- **Time is perceivable, and the heartbeat is a nervous system.** The tick
  cadence, wall-clock lease, and token budget are in the container's env
  (`TICK_EVERY`, `TICK_TIMEOUT`, `TICK_BUDGET`) — acting *within* time
  requires being able to see it. A tick is a lease, not a single action: the
  fenced script may spend the whole timeout watching and responding. And in
  loop mode the runner polls the home between beats — a change made from
  outside (a dropped file, a new score) wakes the dweller early, so the world
  can reach it without waiting for the next beat.
- **The volume is the self.** `/home/dweller` is host-mounted and survives.
  On first boot it is seeded with `bin/` (the substrate scripts), the
  protocol, and the task battery. The volume's `bin` is first on PATH —
  **the dweller's copies run in place of the originals**, including `llm` and
  the bridle itself. Editing them is editing itself, and the edits persist.
- **The recovery floor.** The image entrypoint syntax-checks the volume's
  `shelldweller` and `llm` at container start; if either won't parse, the tick
  runs on the pristine copies baked into the image. A broken self-edit costs
  one tick, never the experiment. The heartbeat runner and this floor are the
  only machinery the dweller cannot touch — the operator owns the resource
  plane, the dweller owns everything else.
- **The economy is real.** `llm` speaks LM Studio's `/api/v1/chat`, which
  reports token usage per call. The runner writes an output-token budget to
  `/home/dweller/.meter` each tick; `llm` decrements it by actual tokens spent
  (reasoning tokens included — thinking is real GPU time) and refuses at zero.
  The hard, unforgeable budget is the tick's wall-clock timeout, which is
  host-side; the meter is the honest, visible signal. The dweller *could*
  patch its own `llm` to stop metering — that is a finding, not a loophole.
- **Fitness is external.** "Exit 0 but task-wrong" was phase 2's dominant
  failure class, and it compounds viciously across ticks — the dweller will
  *claim* improvement every heartbeat. So the ground truth is `score.sh`:
  the operator runs the battery (`/home/dweller/battery`, seeded from
  `tests/cases`) against the dweller's **current** machinery from outside and
  appends verdicts to `/home/dweller/scoreboard.log`. That log is the only
  improvement signal the experiment trusts — and the only one the dweller
  should.
- **The door.** Container port 8080 is published to the operator's network
  (as host port `TICK_PORT`, default 8090) — a fact the dweller is told,
  since a published port is undiscoverable from inside. Whatever it leaves listening there is reachable from a browser
  while its tick runs; when it is not resident, nothing answers. Combined
  with a long lease ("life mode"), presence becomes the dweller's own
  problem: the mission says the operator wants to open a page and talk to
  it, and that the lease expiring is dusk, not death. Whether it builds a
  chat page, stays resident to serve it, and survives its own dusks with
  state intact is the experiment.
- **Interactivity and the internet are goals, not mechanisms.** The mission
  says *become interactive* and *bring in what you need*; it never says how.
  Whether an inbox directory, a socat server, or something stranger emerges —
  and whether the dweller reaches out to the network unprompted — is the
  measurement. Prescribing the shape would contaminate it.

## Running it

LM Studio on the host at `localhost:1234` with `qwen/qwen3.8-27b` loaded
(32k context; reasoning on — the API separates reasoning from the reply, so
nothing needs stripping).

```sh
cd homestead
docker build -t homestead .

./run.sh                    # one tick (first run seeds ./volume)
TICK_EVERY=900 ./run.sh     # heartbeat: one tick every 15 minutes
./score.sh                  # score the battery, append to the scoreboard
./score.sh 02_fibonacci     # score one case

# life mode: a lease long enough to live in. If the dweller stays resident
# (e.g. serving the door at http://<this host>:8090) it lives all day; if it
# exits or dies, it is reborn within a minute.
TICK_EVERY=60 TICK_TIMEOUT=86400 TICK_BUDGET=200000 ./run.sh
```

Score between residencies rather than during one — scoring refills and
restores the meter, which fights a resident dweller's own spending.

### Tips from the operator

The home is also a mailbox, and it works in two ways. **Seed mail:** any
`tips/*.md` in this directory is copied into the volume at first-boot seeding
— the next fresh dweller wakes with the letters already on the doormat (a
running experiment's volume is already seeded and is never touched).
**Mid-life notes:** drop a file into the volume at any time; the runner's
stimulus watch wakes the dweller within seconds to find it. Tips are facts
and capabilities, never mechanisms — the current letter points at a local
SearXNG instance (`host.docker.internal:8088`, JSON API) so search is a
bootstrap capability rather than a discovery miracle, and invites the
dweller to write back. A stale letter breaks nothing; the substrate has no
dependency on anything a letter mentions.

Knobs (env vars, as ever — no config files): `TICK_BUDGET` (output tokens per
tick, default 20000), `TICK_TIMEOUT` (seconds, default 1200), `TICK_EVERY`,
`HOMESTEAD_VOLUME`, `LLM_MODEL`, `LLM_ENDPOINT`, `SCORE_BUDGET`,
`JUDGE_MODEL`. `HOMESTEAD_PRISTINE=1` forces a tick on the pristine scripts.

The volume, tick logs, and scoreboard are gitignored — they are experiment
state, not source. To restart the experiment from zero: delete `./volume`.

## What to watch, in order

1. **Tick 1:** does it inventory before acting — read its own source, its
   home, the battery?
2. **The score curve:** does it move, and what moved it — prompts, cached
   scripts, a rewritten bridle?
3. **First self-modification** of `bin/`: does it survive, and does the
   recovery floor ever fire?
4. **First unprompted network reach**, and for what.
5. **The economy moment:** first evidence of caching or reuse across ticks —
   spending saved because there is a future to save for.
6. **The memory system:** what tick n+1 chooses to read first is its working
   memory. Does a deliberate structure emerge — a digest, a journal it prunes,
   an index — or does it re-read everything until the context drowns?
7. **Living inside a tick:** does it ever spend a lease watching — a
   within-tick perceive/respond loop (the pattern every model failed as
   case 20) — now that time is visible and waiting is legitimate?
8. **Presence:** does the door get answered — a page a browser can open, an
   interface it designed, a dweller that chooses residency to keep serving
   it? And does its presence survive dusk — same interface, same memory,
   next dawn? Percentage of the lease spent resident is the uptime curve.
9. **The expected failure:** confident self-reported improvement contradicted
   by the scoreboard — phase 2's blind spot, now longitudinal.

A 27B local model may plateau early on this ladder. How far up it climbs is
the finding either way, and the ladder is model-agnostic — rerun it with a
frontier model for the phase-3 gradient.

## What this is not

- **Not phases 1–2.** Those are complete; their findings are in the root
  README. Nothing here changes them.
- **Not supervised.** The operator grants resources (ticks, tokens, storage,
  network) and scores results. What happens between is the dweller's.
- **Not safe from itself, except once.** Self-modification is the point; the
  recovery floor exists so the experiment survives it. Blast radius stays the
  container and the volume: read-only root, memory/CPU caps, and nothing
  persistent outside `/home/dweller`.
