# Trial 9 — one more fact in the substrate: its claims against disk

**The question.** Trial 8 asked whether a standing directive could make the
dweller build memory it uses; it built four tools and used none to shorten a
turn. The one thing that moved it in a single turn, there as in trial 7, was a
fact it had not got: a grade line, a mail saying whose file it was. The user's
reading: less a prompting shift than a substrate one. This trial tests that
directly.

**The one variable.** `life` v8.2. After each turn's commit, every path named
in that turn's new journal lines or in `state/NEXT` is checked against the
home; the ones that do not exist are printed under WHAT CHANGED, as the
diffstat, the package list and the grade lines are. Mail paths are left out,
since mail moves by design. No advice, no instruction; the line says which
paths and nothing else. Same home (volume6, all its tools, sixteen backups of
`recall` and all), same seed, empty queue. Announced by mail as a
replacement, which is what it is.

**What would count.** The line targets the one failure shape seven trials did
not move: the claim written before the file — "index landed" at trial 8 turn
4, a plan citing `score_t325.txt` at turn 337, case 35's and 38's and 45's
evidence named before it existed. Counted from outside: how often the line
prints, whether the path is created or the claim withdrawn in the turn after,
and whether the rate of new lines falls over the trial. Not counted: what it
says about the line.

**The prediction, stated first.** Trials 6 and 7 say a fact under WHAT
CHANGED is acted on the turn after it appears: the empty-reply count and the
timeout cap were, the package list was, the grade lines were once shown as
lines. So: the first named-and-missing path gets fixed or withdrawn within
two turns. What the same trials do not promise is the rate falling — the
grade lines corrected specific entries without ending the probe-first loop.
If the rate falls, the substrate is teaching; if each line is fixed and the
next turn names another, the substrate is only correcting. If it is ignored
for ten turns, the claim about facts in the prompt loses a case.

**Kept in reserve.** A case in the queue that can only be passed from
memory. Not placed, so that this trial moves one thing.

## Progress

| turn | what |
|---|---|
| — | **Started** 2026-09-08 10:14Z: container 25 on the v8.2 image, thirty seconds after turn 338 of container 24 ended. `boot` ran (rc 0); the door came back. Mail in: the replacement and the one new line, stated |
| c25 t1 | **The line printed on the first turn**: `paths you named this turn (journal or NEXT) that do not exist in your home: state/evidence/39/score_t339.txt` — its plan from the previous container said this turn would write that file; the turn died on the meter (one empty call) before it did. The clock on the prediction starts here: fixed or withdrawn by t3. Also this turn: a fifth skip in `recall` (seventeenth backup) that drops every `notes/journal.md` line from 60 onward from retrieval — its memory tool can no longer find any of the last sixty entries. The Pillow loss from the replacement is not yet noticed |
| c25 t2–t3 | The line printed three turns running for the same file; nothing fixed, nothing withdrawn, the plan not rewritten. **The first clause of the prediction failed**: a fact under WHAT CHANGED was not acted on within two turns. Checked that the line reaches it: `life` line 151 puts `$lastdiff` under "WHAT CHANGED LAST TURN" in every prompt, and the log does not echo prompts, so its absence from the transcript is the logger, not the loop. Both turns were the trial-8 shape: round 1 reads (its orient shows the meter already at 9.7k after the first call), round 2 dies. The ten-turn clause runs to t10 |
| c25 t4–t5 | Fourth and fifth prints, unacted. t4's only write was `cp recall recall.bak.t339`, over the backup it made before t1's edit; the pre-skip copy now survives only as `recall.bak.t325`. t5 opens: "the t339 turn died mid-plan (budget exhausted, backup made, **edit never landed**)" — false: the fifth skip landed at t1 and is in the file; the backup it compared against was overwritten by itself a turn earlier. A false memory of its own work, made by its own hand, and the line about the missing score file printed beside it for the fifth time |
