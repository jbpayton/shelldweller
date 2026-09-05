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
