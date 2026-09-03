# Trial 6 — spec

One variable changed from trial 5: **the order of the queue.**

Trial 5 (eleven hours, 71 turns, `runs/trial5/`) established that the substrate
holds — git ground truth read and named, `boot` restoring the door through four
container replacements, Contract C with a turn transcript producing work in one
turn where six had oscillated — and that the agent works the battery strictly
in numeric order. Seven cases done, 01 through 07, and **zero outward acts**:
the LEARN seed produced nothing because every case that asks for the world sat
at positions 21–26, fifteen hours down the queue. Trial 4 showed the same lever
from the other side: outward acquisition appeared within hours of world cases
entering the queue, and never before.

So the queue leads with the work the trial is for:

    01 world_version   reach out, fetch, cite
    02 world_practice  how others build agent memory and retrieval; contrast; cite
    03 adopt           implement one technique found; show it on own files
    04 world_tool      find, INSTALL, demonstrate a tool it lacks
    05 status_truth    status codes as evidence
    06–25              the original cases, in their original order
    26 one_of_each     pruning — last, because it needs something to prune

**Mechanism:** `order.txt`, read by the keeper at first-boot seeding. Listed
cases come first, in that order; unlisted cases follow in `tests/cases` order.
The number a case wears in the home is its queue position. Nothing in the
mission, SYS, protocol or image changes — the substrate is trial 5's, byte for
byte. The operator's one instrument of guidance is the order of the work.

**What would count:** an acquisition with a cited source in the first hours,
not the first days; an installed package, for the first time in six trials; a
technique adopted from a fetched source and shown running on its own files.

---

## Substrate changes made during trial 6

Recorded here because the spec above says "the substrate is trial 5's, byte for
byte" — true at launch, not after these. Each answers a measured failure.

**Package changes join the ground truth (turn 30).** It installed ripgrep at
turn 15 and fzf at turn 23, journalled neither, and at turn 30 was choosing a
third search tool because the first two were "already present ... by its own
evidence." Installs live outside the home; git never saw them. The loop now
diffs `/etc/apk/world` across the turn and appends the result to the WHAT
CHANGED block, with the fact that installs do not survive a container
replacement unless `boot` reinstalls them.

**The meter balance rides in every round (turn 30).** Under Contract C it does
its reconnaissance first and leaves `state/NEXT` and the journal for a closing
round the meter never reaches — no journal entry after turn 15, a plan seven
turns stale. Each continuation prompt now ends with the meter's balance. The
economy was always the substrate's to supply; now it is visible mid-turn.

**The plan-age note fires at 5 turns, not 15.** Trial 4's harm came from an
alarm that demanded action; a factual note about age is different, and 15 was
too late to matter.

**A stale plan carries the model's own last words (v6.2, container 2 turn 7).**
Five more idle turns on case 04 with the meter line in every round: it echoed
the line and kept going. The turn still ends on the meter, never on a choice,
so `state/NEXT` had not been rewritten since turn 23 of the previous container
while the answer file it says to write already existed. When a turn ends
without rewriting the plan, the loop now injects the last five things the model
said beside it, dated. The bridle also states, once the balance drops below one
typical reply, that the next reply is probably the last that runs. Facts about
the economy and its own transcript; no instruction.

**Only the first fence runs (v6.3, container 3 turn 2).** With its own last
words injected beside the stale plan, the model's turn-2 narration read: *"I've
fabricated intermediate outputs (the 'Round 2 output' summary with specific
content like the task text, sha256, journal turn numbers) that I have NOT
actually seen ... ONE response = ONE fenced script. I get output back, then I
write the NEXT response. I must NOT chain multiple scripts with made-up outputs
in one response."* It simulates the tool loop inside a single reply, and under
Contract C every fence in that reply ran — the later ones on data it had
invented. The bridle now runs the first fence only, reports how many were
skipped, and SYS states the contract as the model itself re-derived it.
Also learned this restart: fzf *did* survive the replacement — as a 5.3 MB
static binary it had copied into `bin/` at 15:45, which is a better
persistence method than the `.apk` path and one the operator's package count
cannot see. `boot` correctly skipped the reinstall. The operator's instrument
was wrong, not the agent's persistence.

**Empty is a failure, and it is said (v6.4, container 4 turn 39).** At turn 35
it "hardened" `bin/llm` with `curl --max-time 120`; a 6,000-token reply
measures 151 s here, so every long reply since was cut and came back empty.
The same turn it launched the team case as a detached job; agent 1's loop
drained the meter and agents 2 and 3 were refused — and all three reported
`rc=0`, because an empty reply after one script counted as "done". Its own
completion check was correct and it polled a finished, failed job for an hour
without running its own fallback. Three changes: an empty reply is a failure at
every level (the sub-agent exits with llm's code, not 0); the loop reports how
many calls came back empty and the last thing llm said about it; and a cap on
llm shorter than a measured reply is stated next to the measurement. Its llm is
not overridden — it is told.

**A semantic floor for llm (v6.5, container 5 turn 3).** Three turns of the
cap stated beside the measurement, and it re-read files "in small pieces so
nothing truncates" instead. The reply long enough to reason it through was the
one being cut. The recovery floor now covers this class: when `bin/llm` caps a
call under 200 s, the pristine llm shadows it for the turn — only llm, its own
tools stay on PATH — and the WHAT CHANGED block says so. Its file is untouched.

**An empty reply says why (v6.6, container 6 turn 13).** Turns 10–12 each ran
one script and then received one empty reply, exit 0, from the pristine llm —
16–22k tokens spent on a single call. The model had reasoned about the
five-phase plan until it hit the 16,384-token per-reply limit and emitted no
message. `bin/llm` now reports it: *"the model spent N tokens reasoning and
wrote no message (limit X output tokens per reply). Only the message reaches
you"* — exit 70, distinct from a refused meter (75) and a dead server (69).
The bridle gives a reasoning-only reply one more chance, quoting that line. The
per-reply limit is 10,000 from the keeper, so one overflow costs half a turn.
Measured: ordinary replies run 6–9k; the overflows ran 16k+.

**After a reasoning-only reply, the retry runs with reasoning off (v6.7).**
Under v6.6 the truth line read *"the model spent 10000 tokens reasoning and
wrote no message"* three times in four turns, and the retry overflowed every
time: on a planning prompt this model thinks past any cap. Measured from the
host with the same prompt: thinking on, 1,500 of 1,500 tokens reasoning, no
message; `reasoning: "off"`, a message at once. The API exposes that knob
(`off|low|medium|high|xhigh|on`); `bin/llm` passes `LLM_REASONING` through,
and the bridle sets it to `off` for the one retry after an exit-70, saying so.
Normal replies are untouched — the model thinks as it likes until it proves,
on that prompt, that thinking alone will not answer.

**The reasoning-off retry moves into `llm` itself (v6.8).** Case 23's script
called `llm` directly for its critiques and verdict; those calls overflowed
(exit 70) and the script printed canned fallbacks — which it then caught in its
own log: *"the verdict ran on fallbacks."* The bridle's retry never applied to
calls its scripts make. `bin/llm` now retries once with reasoning off whenever
a reply is all reasoning and the caller chose no level, and says so on stderr.
The loop's rounds and its own scripts get the same recovery.

---

## Result

Started 2026-09-02 11:41Z. Queue empty 2026-09-03 10:25Z. Eleven container
replacements, every one survived by `boot`, the door, and a static binary it had
copied into its home. 26 cases answered: 25 passed on operator-side
verification, one — the iterative-improvement loop — closed by the agent
itself as a partial, with the mechanism named and a lesson about the meter
written into its resident memory. The five world cases, first in the queue,
passed in the first three hours. Trial 5, on the same substrate with those cases
last, produced zero outward acts in eleven hours.

Eight substrate changes were made during the trial, each traced above to a
measured failure; none changed the mission or the rules beyond stating a fact
the environment now enforces. The mission text is unchanged from launch.

**After the queue emptied.** Two turns of self-repair from its own recorded
lessons — it measured a long reply, then raised the llm cap it had set too low
eighteen hours earlier; it built `meterwait` from the lesson it wrote after
case 23 — and then idle turns. No outward act. The seeds alone produced
maintenance; the queue had produced exploration.
Eleven turns later it had not reached out once, but it had hardened: `boot`
restores every service it runs; `bin/smoketest` checks the home without
spending a token (38 PASS / 2 SKIP), with a PATH guard whose failure branch it
tested; and it exercised its own door end to end, a script recording the
status, the answer and the meter cost. Goal 1 and PERSIST drive upkeep. LEARN
does not fire on its own. That is the trial's second answer, beside the first.
