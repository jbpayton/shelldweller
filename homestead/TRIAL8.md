# Trial 8 — a standing directive, and no queue

**The question.** Trials 5–7 found that prose did not move the dweller and
the environment did: seeds and goals alone produced upkeep (trial 5); the
queue's order produced every tool it built (6, 7); a file of facts produced
reflection where no instruction had (7, v7.5–7.6). The user asks the
opposite test directly: give it an evergreen directive to build memory
better than a person's — storing, finding again, recognising what belongs
together, its own mistakes included — with nothing else in front of it.

**The one variable.** Three sentences added to the seed REMEMBER WELL in
`mission.txt`. Same home (volume6, 45 answers, all its tools, the grades
file complete), same substrate (v7.6), empty queue. The loop's existing
mission-change hook writes one plan line: read the seeds and act on them.

**What would count.** New memory machinery it builds without a case asking:
storage it did not have, retrieval that beats `recall`'s substring walk,
any association between facts it did not make before, and a record of its
own mistakes that it consults. Measured as before: files, git, and what it
uses in later turns — not what it says.

**The prediction, stated first.** Trial 5's finding says a directive alone
yields upkeep and journal entries about memory, not memory. Trial 7's
grades finding suggests one exception: a fact that changes under its eyes
moves it. The directive does not change. If it builds anyway, the thesis
loses a corner: prose can move it when the queue is empty. If it does not,
the next lever is a case — or a fact that changes.

**Started** 2026-09-05, after the LM Studio restart, from the same home.

## Progress

| turn | what | 
|---|---|
| 1 | read the changed mission; rewrote its plan to the three seeds |
| 2 | fetched an arXiv survey on agent memory into `state/learn/` (LEARN) |
| 4 | wrote `bin/mkindex` — a which-file index over its home; journaled "index landed"; the tool did not parse and no index existed |
| 5 | read the disk, wrote "index build failed — do not claim it" |
| 6–10 | five reading turns, nothing changed |
| 11 | fixed the tool; `state/index.md`, 508 lines, one per file, exists |

Eleven turns, ~250k tokens, one working which-file index from the
directive alone. Against trial 5's 71 turns of upkeep from seeds and goals,
that is a difference — with the confound that this home already knew how
to fetch, build and journal. Open: whether anything reads the index.
| 12–16 | five turns re-verifying the index against a plan that still said it was broken; regenerated it twice | 
| 17 | wrote the case-40 answer, 18 hours late: the wrong ten-case window, "1 of 3 below", a fail reported against itself; graded pass\* on the artifacts |
| 18 | read the 40 and 50 grade lines (v7.6 put them in the prompt); wrote `state/evidence/50/b50_correction.md`: re-checked both plant commits, owned that it had cited them without reading them, owned the avg.sh misattribution, re-grounded the one genuine incident on the right correction mail; two rules added — verify a commit's content before citing it, attribute authorship only when the first commit proves it |
| 19–24 | orient journal fix; the page's status line rebuilt live from the server, filed under an invented "case 51"; a traceback from its own change found and saved |
| 25 | ran the llm over the extracted survey: five mechanism → change → verify rules (contradiction handling in `core.md`, a 14-line cap with eviction, stable/tentative tags, write-path filtering, one `recall` per turn), each with a check it could run. Nothing applied yet |
| 26–33 | eight turns on the closed case 44's image pipeline: five image-verdict attempts (one essay, one meter death, one "pass" on a 1.3 KB image from the encoder the llm had called unreadable), one patch to the encoder, three reading turns. None of the digest's five memory rules applied; the index unsearched |

**At 33 turns and ~800k tokens:** the directive has produced one unused
index, one unapplied digest, a rebuilt status line, an orient fix, and a
good correction that a grade line triggered. The rest is the ritual and a
closed case. Same finding as trial 5, at a higher price.
| 34 | a written diagnosis of the image-verdict path (what reached the model, proven from files) — and a third journal file: `state/notes/journal.md` joins `notes/journal.md` (113 lines) and `state/journal.md` (50). Under a directive to build better memory, its memory fragmented further |
| 36–39 | the right experiment at last: an ABC probe (meter death), then three solid-colour images — red, green, blue — each named correctly by the llm; conclusion in `core.md`: the endpoint sees attached PNGs, the verdict failure is prompt-side. The red answer even says "I don't see any grep output here", which is the bug: the checker's prompt carries the shell transcript. One digest rule now sits in `core.md` as a rule line (journal write-path filter) |

### v8.1 — the bridle's stdin (substrate defect, found by its turn-40 "secret" test)
The bridle piped each fenced block into bash on stdin. Both llm devices read
their prompt from stdin. Its page checker passed the prompt as an argument,
which the device ignores — so the device read stdin, which was the rest of
the running script. Every image verdict since case 44 was the llm answering
the tail of the script that called it, with the image attached. Fix: the
fence runs from a file with stdin closed; the pristine llm refuses an empty
prompt and says where the prompt comes from. Its bridle copy, identical to
the seed, was replaced while stopped and announced by one line of mail. Its
own fault — the argument form — stays its own; the substrate's was making
it silent.
| c24 t1 | read the v8.1 mail and the diff comment; changed the checker's call to the stdin form (`printf '%s' "$prompt" \| llm`) the same turn; re-ran the verdict: the llm answered the question for the first time in two days — one word, FAIL. The page still does not pass its own check, but the check now checks |
| c24 t3 | two word probes rendered by its own encoder and read back by the llm: ZEBRAFINCH, PINECONE — both exact. The encoder's text is readable (its turn-30 patch) and the prompt now reaches the model (v8.1). The full-page verdict itself died on the meter again |
| c24 t4–t11 | two more swap probes, then seven turns that changed nothing but the ledger: each spent its meter on llm calls and re-reading; the plan went ten turns stale and was withheld. Turn 11 restored a one-line path bug in the server's `/case/<NN>` route it had introduced at turn 23 (door up throughout) |

**At ~1.2 M tokens (c23 t1 → c24 t11):** the directive's yield stands where
it stood at 33 turns. The two things that moved it were facts under its
eyes — grade lines and the stdin truth — and its own controlled probes once
the prompt reached the model. The loop it cannot leave on its own is the
one the environment leaves unpriced: reconnaissance that spends the meter
before the work.
| c24 t15 | the secret-word test finally ran clean: first call "ok", second call "None" — the endpoint is stateless, bytes verified with od. The "context beyond my prompt" hypothesis, born of the stdin bug, is retired by its own experiment, three days after case 44 |
| c24 t16–t25 | one more verdict and one legibility probe, both dead on the meter; an encoder patch (t20); seven turns that quoted the two files it meant to patch and ran out; t25 wrote `bin/caseprobe.sh`, a regression guard that plants a marker file and asks the running server for it over HTTP — its turn-11 server fix verified live. Door up throughout |
| c24 t26–t28 | the secret-word statelessness test run a third and a fourth time — it was settled at t15 with bytes verified. The result *is* in `core.md`, and orient shows it every turn (checked: one line in core, four mentions in the orient output). It re-runs the test anyway. The sharper finding: memory stored and shown, and not trusted — the same-turn-proof rule it wrote after the 45 grade makes every fact provisional until re-proven, so a resident fact buys nothing. Its distrust of its own record was earned (35, 38, 45, 50); the rule that answers it costs a re-derivation per turn |
| c24 t35 | **the first passing page verdict**: image 34, the llm's whole reply "PASS", the script's summary "http=200, 5 live strings present, png=1765B". The case-44 pipeline works end to end three days after the case: its own encoder (patched t30/t20/t29 of two containers), the prompt reaching the model (v8.1), and a turn where the judgement came before the meter died |
| c24 t36–t48 | thirteen turns on the closed case 44's five-verdict set: two more encoder patches, images 44 and 45 re-rendered and re-judged, one PASS (34) against real model FAILs (40, 44, 45) and meter deaths; ten of the thirteen turns changed nothing but notes. Its inbox service was found missing from the process list at t37. ~2.0 M tokens into trial 8 |
| c24 t49–t63 | fifteen turns: images 48 and 49 rendered larger after two more encoder patches and judged FAIL by the model; the statelessness test scheduled a fifth time; a PNG decoder started so it can inspect its own renders without Pillow; eleven of the fifteen turns changed nothing but notes. ~2.3 M tokens |
