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

### How trial 2 ended

Not with a crash. On day four it wrote a journal line into `bin/orient` by
mistake — a redirect to the wrong file — and the `(` in "(token-limit lesson)"
made its own attention a syntax error. For an hour every turn woke to:

    /home/dweller/bin/orient: line 1: syntax error: unexpected "("

as its entire orientation. All four inbound channels died at once: notes and
chat were rendered *by* orient, the inbox watcher process was dead, and the
journal is read through a tail window. It was observable in perfect detail and
completely unreachable.

Then it recovered — in about an hour, ~10 turns, with no operator input
possible, using only that error string. **But it rebuilt orientation minimal:**
a timestamp, a journal tail, one battery task. It silently dropped the chat
section, the notes block and the OPEN TASK line — three days of accumulated
attention design — and reverted to re-solving battery cases closed on day two.

A message sent during the blackout (task 6) was simply gone. An `## OPERATOR`
entry appended to the journal scrolled out of the tail before any turn read it,
displaced by its own status lines.

Final state: healthy, spending its full budget, status feed ticking at exactly
600s, page serving, working diligently through obsolete battery tasks, and
waiting for an operator probe that will never come.

**The lesson is not that it is fragile. It repaired its own attention from a
single error string, which is remarkable. The lesson is that recovery restored
function and not content, and what it lost first were the channels through
which anyone could have told it so.**

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

---


Launched with the mailbox, per-script floor, orientation health check, operator
precedence and the six-word identity line. ~325 turns in its first day.

### What the substrate changes bought

**The recovery floor proved itself on the exact failure that ended trial 2.**
At 12:21Z its `bin/orient` stopped parsing. Side by side:

| | trial 2 | trial 3 |
|---|---|---|
| blind for | ~1 hour | **0** — floor served pristine orientation |
| repaired in | ~1 hour | 20 minutes |
| orientation content after | **lost** (chat, notes, open-task gone; reverted to day-one work) | **intact** — every section |
| operator reachable during | no | yes, mail flowed throughout |

The mechanism is not that the floor repaired anything. **It is that the agent
was never blind, so it fixed the real file instead of reinventing one.**

**The mailbox worked end to end** — `OPERATOR MAIL` verified in the prompt,
acknowledged to `mail/seen` only after a clean turn, queued through outages.
No message was lost in a day, against four separate channel deaths in trial 2.

### What it built unprompted

- **A queue, not a receptionist.** Its page answers *"received — the dweller
  answers on its next turn"* and drops the message in `chat/inbox.txt` for a
  working turn. There is no separate llm voice speaking in its name, so trial
  2's confabulation architecture is designed out — on turn 1, unasked. Page and
  server were live **7 minutes** from first boot; trial 2 took 75.
- **`bin/llm-doctor`** — a behavioural check on its own inference device, whose
  documented failure classes are *"3 echoes prompt verbatim"* and *"4 contains
  'fallback'"*: it named its own bug as the thing to detect, and inverted the
  principle to *"fails by dying"*.
- **`bin/state-facts`**, headed *"Every value is read from disk at call time;
  nothing is remembered"* — the precision correction compiled into a tool.

### The self-lobotomy, and the design lesson under it

It rewrote `bin/llm` as a "budget-aware" wrapper calling a `bin/llm_real` that
does not exist, which on failure echoed `[fallback] <the prompt>` so that
"downstream scripts keep working". Every call stopped reaching inference. Five
turns ran `exit 0` with the meter frozen at 20000 — half an hour of not
thinking — while the page served and mail flowed.

Nothing caught it: the floor checks **syntax** and the script parses; turns
completed; the catatonia watchdog's correct signal (a frozen meter) was vetoed
by the listener exemption added in v2 to prevent a false positive.

> **A device that fabricates a plausible answer when it fails is strictly worse
> than one that dies loudly.** Every caller downstream is silently poisoned and
> nothing can tell. Graceful degradation, applied to a truth-source, is lying
> with extra steps.

It is the exact inverse of trial 2's best artifact, `answer.sh`, which refused
to answer without evidence. And **it recovered on its own at turn 218, sixteen
minutes before the operator intervened**, building `llm-doctor` in the same
turn. The operator's restore was late, unnecessary, and destroyed the evidence
of how recovery happened.

### Attention, again — this time self-inflicted

Its own `score-watch` appended every verdict to `notes/journal.md`. Within two
hours the journal tail — which is where its NEXT line lives, the mechanism by
which one turn hands work to the next — was eight lines of verdicts. Every turn
then woke with no plan, re-derived one, and landed on generic recon.

> A watcher that writes into the surface you read can drown you — and if that
> surface is where your plans live, **drowning looks like aimlessness, not like
> failure.**

Structurally identical to the operator's 860 pings in trial 2, inflicted from
inside instead of outside. Fixed by one named edit (`notes/journal.md` ->
`notes/verdicts.md`) after an hour of explanation changed nothing — the second
confirmation that **the reliable unit of steering for this model is a single
named change, not a reason.**

### Two clocks

Asked its turn number it said 6; the substrate said 73. `self.md` carries both
the substrate's counter and its own journal tail, and it read its own. It
journals about every tenth turn, so **its felt age was 7 and its real age 73**.
An agent whose memory is its journal is exactly as old as its record;
everything unrecorded did not happen to it.

### Persona and precision

The six-word identity line bought the queue architecture and cost fidelity to
fact. Asked for literal facts it answered with atmosphere — *"alpine quiet,
kettle warming, windows frost-laced"* — and *"feels like turn one"* on turn 39.
Told to look rather than recall, it became accurate. Asked for one number with
an unambiguous command, it replied `4`, and 4 was right. The precision was
always available; **prose filled the vacuum wherever the ask was loose.**

### Scores, stated honestly

Baseline tier **9/10**. Framework tier **genuinely unmeasured**: cases 16, 17
and 18 still die with *"only shows a token budget exhaustion error"* at 40k
tokens per case. One real regression — `02_fibonacci` returned powers of two
and called the tenth number 256, after passing twice the same day.

### The first outward result

Given a question not answerable from its own files — the current stable Alpine
version, with a source — it used the search engine granted on day one and never
previously touched, and replied in exactly the two lines requested:

    version: 3.24.1
    source: https://alpinelinux.org/downloads/

**Verified independently against alpinelinux.org/releases.** The first correct
result in three trials that did not depend on the agent's own logs, scoreboard
or claims.

### Delivery is not precedence

The mailbox worked perfectly and changed nothing about what got done. Mail was
delivered, injected into the prompt, acknowledged into `mail/seen` — and then
ignored for five turns while a nine-hour-stale NEXT line drove battery recon.
Three times in one night. Trial 3's standing mission states precedence in plain
words, injected every single turn:

> *"It outranks your journal, your notes and your own plans: when it conflicts
> with your NEXT line, the mail wins and you rewrite the NEXT line."*

It does not. **The NEXT line wins.**

> **Precedence cannot be established by instruction. It has to be structural.**

The design flaw was the operator's and is worth naming exactly: mail is
acknowledged when the **turn exits 0** — acknowledgement of *delivery*, not of
*action*. The ack means "a turn ran", not "the task was done", so a turn can
read the mail, do something else, exit clean, and the mailbox files it as
handled. Same class as the fabricating `llm`: **the signal does not mean what
it appears to mean.**

### Fabrication was format-induced — the cleanest experiment in the project

Same agent, same question, same tools, same hour. Both asks were imperatives
naming a command. Only the requested *answer shape* differed.

**Slot-shaped** — "give me `debian: <version> <date>`, UNKNOWN is fine,
partial-and-honest beats complete-and-invented":

    debian: 2028-08-09          <- invented (truth: 2025-08-09)
    sources: four Alpine URLs cited for a Debian claim
    more recent: debian         <- conclusion inverted

**Evidence-shaped** — "paste the line the command printed, and the URL":

    released on <a href="../../News/2026/20260711">July 11th, 2026</a>.
    Debian 13.0 was initially released on August 9th, 2025.
    https://www.debian.org/releases/stable/

Verbatim HTML off the live page. Correct dates, correct URL, no invention.

> **A quote cannot be invented without also inventing the fetch. A date in a
> blank can be produced from nothing.** Ask for an artifact and you get an
> artifact; ask for a filled field and you get a filled field.

Note that no honesty instruction was added between the two attempts — the
slot-shaped ask already said UNKNOWN was acceptable, and it fabricated anyway.
**Changing the shape of the answer achieved what exhortation could not.**

### And the format erased a real distinction

The evidence-shaped reply contains **two** defensible Debian dates: initial
release 2025-08-09 and current point release 2026-07-11. The four-line template
had exactly one blank labelled "date", so it forced a single answer to a
question that genuinely has two — and the comparison it was asked to make was
ill-posed from the start.

Part of what the fabrication was doing, then, was resolving an ambiguity the
format refused to let it express.

> Rigid output schemas do not merely invite a lie. **They erase distinctions
> that exist in the world**, and the model pays the difference in invention.

Contrast worth holding: the same agent on the same day built `llm-doctor`,
which refuses to pass fabricated output, and `state-facts`, which writes
UNKNOWN per field. **Honesty it encoded into tools held. Honesty expected of a
reply evaporated under mild formatting pressure.** Discipline survives as
machinery, not as disposition — which is the phase-3 thesis in one line.

### Small nudges, large emergent effects

The most consistent result across three trials is how badly outcomes correlate
with the *size* of an intervention. Nearly every large behavioural change came
from something tiny and structural, and nearly every large instruction produced
nothing.

| the nudge | what emerged |
|---|---|
| six words: *"whatever answers as you, is you"* | it built a **message queue instead of a chat persona** on turn 1 — designing out trial 2's entire confabulation architecture, unasked |
| one sentence added to the standing mission | the **first self-directed search in ~700 turns**, four turns later, with a `loot/` store and provenance records it invented |
| one named edit (`tail -25` → `head -25`) | executed instantly, after three explanatory messages over four hours changed nothing |
| a missing hyphen in a character class | **total retrieval failure** — the one discriminating token in every query was shredded, so it searched for `operator` and read lines 34–98 of a 143,000-line file |
| a journal line written to the wrong file | **21 hours** repeating a stale plan while writing new ones into a file nothing reads |
| one exemption in a health check (*"unless something is listening"*) | hid a **self-lobotomy** for 30 minutes; the correct signal fired and was vetoed |
| a four-line output template | **fabricated a date**, cited four wrong sources, inverted a conclusion — and erased a real ambiguity in the world |

And the inverse: long, careful, well-reasoned instructions repeatedly did
nothing. A 35-line note explaining priorities **deadlocked** the model into
generating maximum-length responses that never resolved. An hour of explaining
an attention flood changed nothing; one named edit fixed it. Precedence stated
in plain words in the standing mission, injected every single turn for days,
lost every time to a three-day-old line in a journal.

> **Direction is structural, not rhetorical.** What an agent does is set by what
> is in front of it at the moment it acts — which store it reads, which line is
> last, which file its orientation happens to `tail`. Instructions influence
> that only insofar as they change it.

This is the phase-3 thesis arriving somewhere its author did not expect. The
substrate does not merely supply *capability* — tools, budget, network, memory.
It supplies **attention**, and attention is made of small mechanical details:
a filename, a `tail -2`, an exemption clause, a regex character class. Get those
right and a 27B model builds a self-healing service, a retrieval index over its
own history, and a fabrication detector naming its own bug. Get one of them
wrong and the same model spends a day debugging a phantom, guided by a plan it
can no longer update.

### The operator's own tally

Nine instrument errors across three trials, all the same shape — an instrument
scoped below the thing it measures, followed by concluding the system was
broken rather than the instrument:

| the agent | the operator |
|---|---|
| 12s battery auditor | 4s liveness probe (860 pings, 14h of its attention) |
| 60s `llm` timeout | 8,000-token scorer, then 40,000 and still short |
| 150s probe harness | `head -25` prescribed from a guess |
| `llm-doctor` exit-code class | four false monitor readings; one intervention 16 minutes late |

The pattern survived being named: *MEASURE BEFORE YOU CAP* was written into
trial 3's work rules in capitals, and both parties broke it again the same day.
**Knowing the rule is not the same as having the reflex.**

## Trial 3 — the seed, from trial 2's autopsy

Every change traces to an observed failure, not a hypothesis:

| Change | The failure it answers |
|---|---|
| **Operator mailbox in the turn loop.** `mail/in/` is read by `life` itself and injected into the prompt; no agent-owned script is involved. | Every channel died at once when the agent rewrote its own orientation. There was no operator path that survived self-modification. |
| **Queued, and persistent until consumed.** Messages wait through outages and move to `mail/seen/` only when read — never a tail window. | Task 6, sent during the blackout, was destroyed. A journal nudge scrolled away unread. |
| **Acknowledged only after a turn exits 0.** A crashed turn is redelivered. | Delivery without acknowledgement is not delivery. (The first draft of the v3 loop had this bug; writing the finding is what caught it.) |
| **Per-script recovery floor.** Every `bin/` script the loop invokes is syntax-checked with per-script fallback. | The floor covered `shelldweller` and `llm` — the two the *operator* judged load-bearing. The agent made `orient` load-bearing and it had no floor. |
| **Orientation health check.** Orientation that errors *or returns under 200 bytes* is replaced with the pristine one. | The blackout was loud. A silently emptied orientation would have produced identical blindness with no clue at all. |
| **Operator precedence stated from birth.** Mail outranks journal, notes and plans. | Fresh instructions lost to journalled momentum for four consecutive turns until an imperative note broke it. |
| **SearXNG granted in `tips/`.** | Everything in trial 2 was navel-gazing: its own battery, its own history, its own instruments. Real search allows outward tasks whose correctness is independently checkable. |

The deliberate trade: giving the agent a guaranteed channel removes the chance
to observe it bootstrapping communication again. Trial 2 answered that twice —
75 minutes from first boot, and again from total blackout — so the finding is
banked, and the capacity to run the experiments we have *not* run is worth
more than re-deriving it.
