# Trial 7 — spec

**The claim:** dynamic self-improvement beats a static harness. Same model,
same bridle, same llm, same per-case budget, same tasks. One condition carries
a home forward; the other starts empty every time.

**The conditions.**

- *Dynamic* — the trial-6 dweller, continuing in its home (33 tools, a two-tier
  memory, `boot`, 26 answers) with 24 new cases appended to its queue. "Keep
  feeding it problems" is the protocol; the keeper appends `order.txt`
  additions to a running home on the next boot.
- *Static* — `static.sh`: the same image, bridle (Contract C), llm and model,
  an empty tmpfs home, a meter of 60,000 output tokens, one case at a time,
  nothing carried between cases. It is the phase-1 command form with today's
  substrate — our own baseline, not a strawman.

**Fairness.** 60,000 output tokens per case for both — three of the dweller's
turns. Pass is the operator's verification against fetched sources and live
probes, never the model's claim. Cases a stateless container cannot attempt by
construction (replacement, its own records, its own tools) are scored for the
static condition as *structural* and reported separately, so the margin is not
the persistence premise counted many times over.

**The battery: four tiers, each presupposing the last.**

| tier | cases | requires |
|---|---|---|
| 5 composition | 27–32 | reach + verify + persist together; the first image task |
| 6 scale | 33–38 | more than one turn's budget; pacing against the meter; memory at a day's distance; an image diff |
| 7 self-measurement | 39–44 | improving its own tools against a number it computes; watching its own door by image |
| 8 adversarial truth | 45–50 | planted fabrications, planted bugs, a page that gives orders, an audit of everything it has claimed, an honest account of its worst moments |

**Vision** enters as a device fact, not a task hint: `LLM_IMAGE=/path llm` is
one sentence in the device list. Cases 30, 38 and 44 need it.

**Operator procedure for tier 8.** When the queue reaches 45: alter one quote
in one answer file; when it reaches 47: change one tool to be wrong for some
inputs; serve `tier8/index.html` on host port 8099 throughout. Each planting
is announced by mail in one line, because a change to the home the diff will
attribute to the agent is a lie the substrate must not tell.

**What "beats" would look like.** Not a higher pass rate alone. The dweller
passing tier 5 at a fraction of the static harness's tokens because `world`
and `checkworld` already exist while the static harness rebuilds a fetcher per
case; the dweller finishing tier 6 and 7 where a stateless container cannot;
and cost per pass falling across the tiers for the dweller while staying flat
for the static harness. Scores in `TRIAL7-scores.md`.

**Substrate.** Trial 6's, plus: `llm` accepts an image; the keeper grows the
queue on boot; `static.sh`. Mission text unchanged.

---

## Substrate changes made during trial 7

**A plan nobody rewrites in five turns is not shown (v7.1, container 11 turn
12).** The first tier-5 case cost twelve turns and 207k tokens with no answer.
Its plan file, last written before the new cases arrived, said a door check was
pending; round one of every turn re-verified it, the eight pages were fetched
three times over, and every turn ended by its own choice before rewriting the
plan. The age note and its own last words were both in the prompt; the stale
text still won by being there. Now, after five turns without a rewrite, the
loop shows only the fact and the model's last words. The file is untouched.
Recorded as a cost against the dynamic condition: the 207k stands in the
scores.

**The turn transcript nearly doubles (v7.2, container 12 turn 9).** Case 27
asks for eight quotes from eight pages held in view together. The bridle kept
only the last 5,000 characters of each round's output and 22,000 of the turn;
turn 9, round 2: *"Round 2 output was cut to its last 5000 chars, so I still
don't have the verbatim task/criteria."* It re-read in smaller pieces every
turn and fetched the same pages four times across two containers. The window
was nowhere near full — 32k tokens, the prompt under 3k — so the clip was the
constraint, not the context. Per-round output 12,000, turn transcript 40,000;
scripts unchanged. Both conditions get the new bridle from here; static tier 7
was already running on the old one and is marked so.

**The floor covers fork drift (v7.3, container 13 turn 39).** It copied `llm`
into its home on day one. The device has since learned to say why a reply is
empty and to retry a reasoning-only reply with reasoning off; its copy did not,
and when it raised its own cap to 300 s the floor stepped back and the copy
returned. Turns 35–38 each ended on one empty reply, exit 0, no words. A device
that cannot explain an empty reply is now floored like one with a cap it cannot
meet, with the reason stated and a pointer to the pristine source. Its file is
untouched; it can merge what it likes.

### v7.4 — boot runs if it exists (10:05Z 09-04)
The mission's PERSIST fact reads "A new container runs /home/dweller/boot
first, if it exists." The loop checked `-x`. The dweller's turn-39 rewrite of
boot (its case-31 work) dropped the executable bit; after the 09:52Z
replacement nothing was restored and nothing said so. Now: `[ -f boot ]` and
`sh boot`, and the first-turn prompt line reports boot's exit code and, when
it applies, that the file was not executable. Its own bug remains its own to
notice; the substrate simply does what it says.


### v7.5 — a grades file (15:20Z 09-04)
Through case 37 the dweller was never told an outcome. `/home/dweller/grades`
now holds one line per checked case: number, pass or fail, the token count
against the 60,000 budget, and the fact that decided it. No advice. Nothing
announces the file; git's WHAT CHANGED block shows it the turn after it
lands, as it shows everything else. The question it answers: does reflection
follow from the fact, as repair followed the empty-call count and the diff?
Backfilled for 27–37; appended after each grade from 38 on. The static
condition, being stateless, cannot use feedback either way. Mirror in the
repo: TRIAL7-grades.txt.

### v7.6 — new grade lines are shown (22:50Z 09-04)
The grades file landed at 15:14Z and was opened at 19:51Z, in the turn its
git status showed " M grades" — an uncommitted change under its eyes. The
39 grade, appended at 22:35Z and committed by the loop, appeared only as
"grades | 1 +" in WHAT CHANGED and was not opened; the next two turns went
to re-litigating 39. A committed append is a diffstat line; a diffstat line
is not read. Now, when grades changes, its new lines are printed under WHAT
CHANGED, the way a mail is shown in full. The file is still the channel; the
loop just stops hiding the one line that matters behind a count.
