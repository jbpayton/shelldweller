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
