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
