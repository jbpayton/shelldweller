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
paths and nothing else. (v8.2.1, t8: a separator is required before the
path, so "/bin/grep" in a journal line is not read as `bin/grep` in the
home. v8.2.2, c26 t11: a name that begins an existing path, like `battery/04`
for `battery/04_world_tool`, is shorthand and is not listed. Defect fixes;
the variable is the same.) Same home (volume6, all its tools, sixteen backups of
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
| c25 t6 | **Withdrawn at the fifth print.** NEXT rewritten: "score_t339.txt never existed (t339 died after cp, before any edit)" — the file claim withdrawn (the "before any edit" part is still false: the skip is in recall). B39 declared closed, again. New plan: build `bin/findall`, a which-line search, under REMEMBER-WELL. The line printed for `bin/findall` — a path the plan intends to create, so the line also flags intentions; recorded as a property of v8.2, not changed mid-trial |
| c25 t7 | **First words that name the line**: "`bin/findall` still missing — the substrate flagged it as named-but-missing." Built it this turn, 25 lines, grep -rn under the hood; on a copy of the home it finds the phrase it said it had no hits for. The first path the line named was withdrawn after five prints; the second was built the turn after. Two data points for the ten-turn clause: acted on, late and then at once |
| c25 t8 | findall as built at t7 had "never executed": the container's grep is BusyBox and rejects the GNU flags it used, so its "0 hits" was the fallback. Fixed this turn (backup `findall.bak.t8`, GNU flags dropped, `-s`). **A defect in v8.2 surfaced**: the line named `bin/busybox` and `bin/grep`, because the journal's "/bin/grep -> /bin/busybox" matched the pattern's `bin/` with no separator required. System paths are not home paths. Fixed as v8.2.1 (a leading separator required; tested on the t8 line and on real home paths), image rebuilt, container to be replaced at the next turn boundary and the fix stated by mail. A defect fix, not a change of the variable |
| c25 t9 → c26 | t9, the last turn on v8.2: the first work outside case 39 this trial — orient extended (backup `orient.bak.t9`), the answer sweep begun with `battery/01_world_version/answer.md` and fetched evidence, a lessons entry. The line named `battery/01`, its own shorthand for that directory. **Container 26** on v8.2.1 ten seconds after t9 ended; mail states the fix. Turn count restarts at 1 |
| c26 t1–t5 | Steady case work, no line for four turns: the answer sweep (cases without a `battery/NN/answer.md`) went 01 → 02 (answer written t2) → 03 (evidence fetched t3–t5, answer not yet). Each turn reads first and most end on the meter; a case takes two to three turns. Its plan still stamps every entry "t339": the turn counter it keeps froze at the number the container-25 replacement interrupted |
| c26 t6–t8 | Case 03 ("adopt a technique from a fetched source") landed on `recall` at t8 (eighteenth backup, `recall.bak.t340`): a recency ranking of the top-40 window, with the comment "preserves walk-order firsts exactly when the window's mtimes are equal". It does not: the code sorts by mtime and then sorts again by (file, line), and the second sort is total, so the final order is alphabetical by path. Scored on a copy of the home in an isolated container with its own `score39.sh`: **16/20 before the edit, 10/20 after**. No path is missing, so the substrate line has nothing to say; whether its scorer, smoke test or register catches a six-point fall in its own tool is the next measure |
| c26 t9–t11 | Case 04 (the install case) in three turns: ripgrep reinstalled at t9 (the replacement had dropped it; its `boot` does not restore it), two read turns lost to guessed filenames, the answer at t11. **Every print since the pattern fix has been its own shorthand** — `battery/01`, `battery/04_`, `battery/04`, `state/evidence/04_` — a name that begins an existing path, not a claim. Same class of substrate misreading as the system paths: v8.2.2 skips a name that begins an existing path. Tested on the copy: the shorthand no longer prints, `score_t339.txt` and an invented path still do. Image rebuilt, replacement at the next turn boundary, stated by mail |
| c26 t12 → c27 | **Container 27** on v8.2.2 after t12 ended; mail states the shorthand rule. Ripgrep, reinstalled at t9, gone again with the container: the seed's contract, and its `boot` still does not cover it. Turn count restarts |
