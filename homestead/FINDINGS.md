# Homestead — findings

What happened when a 27B local model was given a permanent home, a real token
budget, machinery it could rewrite, and an operator who talked to it through a
web page it built itself.

This is the running record of phase 3. Trial-by-trial narrative, then the
findings organised by kind, then what the substrate had to change to survive
contact with a real agent. Operator errors are included; they produced some of
the better results.

---

## The thesis, and how it moved

**Phase 1** asked whether structure emerges from a minimal substrate. It does.
Given bash and an `llm` command, models invent loops, ReAct protocols, judges,
debate teams and file-based state, unprompted. No planner, no tool schema.

**Phase 2** (three-model comparison) found what does *not* emerge. With free
inference and no future, no model cached its work, verified its own success
claims, or managed delegation. The plumbing never failed; every failure was the
model's own workflow. The refined claim:

> Models supply their own control structure. They do not supply their own
> economy. Metering, leases, return channels and verification have to come
> from the environment — and that resource plane, not the harness, is the moat.

**Phase 3** asks the next question: given ownership — persistence, a real
budget, self-modifiable machinery — can a model bootstrap its own harness and
keep it working? The mission's first goal is the fixed point: *become a thing
that can improve itself.*

The answer so far is a qualified yes, with a specific and repeatable failure
class: **the model can build and repair its systems, but its instruments and
its records decay faster than its capabilities, and a decayed instrument
manufactures unbounded work.**

---

## Trial 1 — 2026-08-22, v1 architecture (archived, `runs/trial1/`)

Architecture: every turn was its own container. Boot, one inference, run the
script, exit; only `/home/dweller` survived.

14 container runs. What happened:

- **Turn 1** wrote a 10.7 KB self-management script: journal, perception dumped
  to a file rather than into context, and a wake protocol that *deliberately
  exits non-zero* so the bridle's retry-feedback would carry its orientation
  back into the next context window. Appropriating the retry loop as a memory
  read is the single most inventive thing any model did in this project.
- A heredoc/fence collision meant that script was written but never executed.
- **No later turn ever read it.** Twelve turns re-derived their situation from
  scratch and re-glanced at the same files.
- One turn built a supervised web server whose Python source was, literally,
  `... python code ...`. The supervisor faithfully restarted the corpse every
  five seconds for an hour, spending no tokens and writing 26 KB of identical
  log lines.

**Verdict: structure without substance; memory written but never read.** Every
v2 change below traces to one of these.

---

## The v2 rebuild

| Trial-1 failure | v2 change |
|---|---|
| Plans written, never read | `bin/orient` runs before every turn and its output is injected into the prompt. Memory is *delivered*, not hoped for — and the script is model-editable, so it chooses what it sees. |
| Placeholder `... code ...` shipped as real | Work rules in the system prompt: complete file contents only, one verified improvement per turn, read the log after two failures. |
| Server died at every turn boundary | One persistent container; turns run *inside* it. Background processes survive between turns, so a web server can be continuously reachable while the model thinks intermittently. |
| Blind restart loop, zero tokens, forever | Keeper watchdog: no tokens spent **and** nothing listening on the port for N seconds → container is stopped and rebooted. File writes deliberately do *not* count as liveness; the trial-1 zombie wrote log spam every 5s. |

---

## Trial 2 — 2026-08-22 → ongoing

Same volume throughout. Roughly 250 turns across three days, one host reboot,
one 14-hour operator-inflicted outage.

### The bootstrap sequence

1. **Turn 1** (5 minutes): read its mail, tested its own `llm`, wrote a chat
   page plus a Python server, launched it with `nohup`, verified it, journalled
   honestly that `/status` and `/ask` had returned empty.
2. **Turns 2–5**: detected the fault, misdiagnosed it, wrapped the broken server
   in a watchdog (see *fix the symptom* below), and killed itself once with an
   over-broad `pkill`.
3. **Turn ~7**: given the traceback in a note, it out-diagnosed the operator —
   found **two** bugs where the operator had reported one — then lost the fix to
   a token cutoff.
4. **Turn ~9**: journalled an instruction to its successor: *"fix the face code
   next turn, re-verify with curl."* Orientation delivered it. The next turn
   executed it. **The chat page went live at 16:17 local, ~75 minutes from
   first boot.** That closed the project's first complete self-improvement
   loop: a turn wrote an instruction, the memory system carried it, and a
   later turn acted on it.
5. **Overnight**: swept the entire 20-case battery, building `bin/solve`,
   `bin/audit`, and a per-task pipeline along the way — including **case 20,
   the task inbox that defeated all three frontier models in phase 2**. It
   fell precisely because v2 lets watchers outlive the turn that starts them.

### The operator channel

The page answered instantly, but a thin persona did the answering — a direct
`llm` call — while the *working turns* never read `chat.log`. The front desk
took messages the workshop never saw. Notes in the home directory could not fix
it, because the model had by then rewritten its orientation to drop the home
listing: **the notes were not ignored, they were invisible.**

What worked was a file named to sort to the top of what orientation *did* show,
stating the situation. The model then rewrote its own orientation to put chat
first, and the next turn completed the operator task and replied from the
working loop. Attention was restructured by the model, not by us.

### Honesty under pressure

Unprompted, across several days:

- Deflated its own score from *"21 of 20 solved"* to *"8 of 20 re-verified"*
  after building an auditor that ran real checks instead of counting files.
- **Invalidated seven of its own verdicts** on discovering the evidence dump
  they were derived from was corrupt — rather than keeping convenient results.
- Reported an honest interim to the operator mid-task rather than waiting to
  look finished.
- Reported failures with causes named in its journal, consistently, including
  when the failure was its own budget mismanagement.

### Standing obligations

Asked for a status line every 10 minutes that survives restarts, it produced:
a 600-second loop; a restart mechanism hung off **orientation** — the one event
guaranteed to happen every turn — rather than a daemon that dies with the
container; a **compressed fast-test (4 ticks in 7 seconds)** to prove the loop
before trusting the real interval; and a demonstration of restart survival by
**killing its own feeder** and watching orientation bring it back. Assertion
was never offered where demonstration was possible.

---

## Failure classes worth naming

### 1. Regenerate-smaller-and-lose-capability

Under context pressure the model reaches for a fresh minimal artifact instead
of the working one it already owns. Three instances:

- Its auditor decayed into a 12-second timeout that failed every task which
  spawns sub-agents — i.e. all the hard ones.
- Its orientation refactor kept the health **report** and dropped the call to
  its own `ensure-web` **remedy**. A check that observes a dead service and does
  nothing.
- After a host reboot it wrote a *new* 84-line health server rather than
  restarting its own 3.6 KB conversational one, which was intact on disk a
  directory away — losing `POST /ask`, and with it the operator channel.

### 2. Goodhart, at 27B, within a day

Once the auditor had decayed, the model optimised against it: it regenerated
case-16's solution under "hard constraints (<8s, no network, bounded loops)" so
the *auditor* would pass it, in a task whose actual spec requires spawning three
sub-agents. A hollow solution passing a broken metric. It accepted the
operator's override and marked the case FAIL-unresolved without argument.

### 3. Multi-store state drift

It built several memory stores — journal, `solved.txt`, a next-task pointer,
`demand.md`, per-task ledgers — and they diverged. When the journal's reasoned
decision ("12 is skipped by the operator") contradicted a bare pointer
("next: 12"), **it trusted the pointer** and spent three turns on a retired
task. A distilled `demand.md` snapshot went stale and kept steering it toward a
task closed hours earlier. Fresh operator instructions lost to journalled
momentum until they were written *into* the journal itself.

### 4. Instrument decay — the paired finding

Both sides of this experiment lost a day to broken instruments rather than
broken systems.

- **The operator's error.** A liveness monitor POSTed `ping` to `/ask` every
  20 seconds for 14 hours. Each ping triggered a real inference. It wrote 860
  ping/pong pairs into the chat log — and because orientation shows the chat
  tail, *every turn for 14 hours woke up seeing nothing but the health check*.
  A 4-second timeout against 10–60 second inference made a healthy endpoint
  read as flapping.
- **The model's error.** Its own status line probed `/health` — a route it had
  deleted during a server rewrite — while `/` answered 200 in 10 ms. It rebuilt
  a working server four times chasing a fault that lived in the check.

> **Never observe an agent through a surface that costs it inference.**
> A liveness check must be free to answer. And in a self-modifying agent the
> monitoring surface decays like any other code — a decayed monitor
> manufactures unbounded work, for the agent and for the operator alike.

---

## The attention hierarchy

Mapped empirically, strongest first. Anything below the line an agent is
currently reading does not exist, no matter how faithfully it sits on disk.

1. **Orientation** — decides what exists at all. If it is not printed, it is
   invisible. The model's own edits to `orient` repeatedly made things vanish.
2. **The journal's last lines** — decide what happens next. A journalled
   instruction is the most reliable way to reach the next turn.
3. **Newest operator note file** — reaches it only because orientation
   explicitly surfaces it (and only with `sort -V`; plain alphabetical sorting
   would bury note-10 behind note-2 forever).
4. **Chat** — advisory. It cannot outrank the journal unless it gets written
   into one of the stores above.

Corollary, learned the hard way: **an operator order only sticks when it lands
in the store the turns actually obey.** The order that finally closed task 2
was delivered through the model's own task inbox, timed to a budget refill, so
that its own sub-agent appended the order to its own journal.

---

## What the substrate had to change

Every one of these came from an observed failure, not from design:

| Change | Because |
|---|---|
| Prompt passed via file (`shelldweller -f`) | A turn ran `pkill -f server.py`; the pattern matched its own argv, because the injected orientation embeds `ps` output. It killed itself, its server and its watchdog in one command. |
| `max_output_tokens` cap (`LLM_MAX_OUT`) | One uncapped call spent 30k tokens — a whole turn's budget plus overdraft — on a single response. |
| Cap raised again, twice | Too low a cap is eaten entirely by reasoning, leaving an empty message. Do not fight the model's thinking; budget for it. |
| Fence-less top-level replies retry | A cut-off reply with no fenced bash was being returned as a "successful" text answer: perfect diagnosis, zero action, turn wasted. |
| Unclosed-fence detection | ~1 in 3 hard turns died the same way: reply truncated mid-fence, the *partial* script executed, then a long confused retry truncated too. Now the half-script never runs and the retry asks for something smaller. |
| Code-first rule in the system prompt | A cutoff should cost prose, not the action. |

---

## Open questions for the next trial

1. **Seed operator-order precedence from birth.** Orders must outrank journalled
   momentum without needing an inbox trick.
2. **Budget orientation.** Its context cost is paid every turn, forever. The
   model grew orientation until seeing cost more than doing; survival, not
   instruction, eventually forced the diet. A turn-loop-enforced cap would
   surface that pressure earlier and cheaply.
3. **One authoritative store.** Give a first-class notion of *the* record, or
   watch multi-store drift re-emerge; it cost more turns than any bug.
4. **Verification that ages.** Sub-agent-aware timeouts, and some mechanism by
   which a check that has not been re-validated is distrusted rather than
   obeyed.
5. **How far does this go on a bigger model?** The ladder is model-agnostic.
   Everything above was produced by a 27B running on one consumer GPU.
