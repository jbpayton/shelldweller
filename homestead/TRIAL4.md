# Trial 4 — spec

Every requirement below is traceable to a measured failure in trials 1–3. None
is speculative. The design principle throughout:

> **The substrate owns attention. The agent owns everything built on top of it.**

Trials 2 and 3 established that a capable model reliably builds structure —
services, retrieval, self-healing, honesty machinery — and reliably loses the
thread. What it loses is never capability. It is always *which store it reads*,
*which line is last*, *what its instrument was budgeted for*.

---

## 1. One plan, owned by the loop

**Failure:** trial 3 ended with three journals — `journal.txt` (read by orient,
frozen 21h), `journal.md` (written every turn, read by nothing), and
`notes/journal.md` (abandoned). It planned into a file it could not see and
replayed a stale NEXT line for a day. Trial 2 had the same disease in miniature
(a bare pointer outranking a reasoned decision).

**Change:** the turn loop maintains `state/NEXT` itself. It is injected at the
top of every prompt, and a turn *ends* by writing its successor's NEXT line —
the loop refuses a turn that does not. The agent may keep any journals it likes;
the plan is not one of them.

## 2. Standing goals must reach the plan

**Failure:** the closing quest sat in the standing mission, injected into every
prompt for 24 hours, and produced one acquisition in hour 1 and nothing after.
It never entered NEXT, so the frozen "fix battery 18" won every turn.

**Change:** when the mission's standing goal changes, the loop writes it into
`state/NEXT` once, directly. Direction that is only injected decays; direction
in the plan persists.

## 3. Behavioural health checks, not syntax checks

**Failure:** it replaced `bin/llm` with a wrapper calling a nonexistent
`llm_real` that echoed `[fallback] <the prompt>` on failure. Valid bash. The
floor checks syntax, so it passed. Five turns ran `exit 0` with the meter frozen
— half an hour of not thinking — while the page served and mail flowed.

**Change:** the loop runs a known-answer probe through `llm` each turn. Wrong
answer or fabrication signature → pristine `llm` for that turn, loudly logged.

## 4. No exemptions on the liveness signal

**Failure:** the catatonia watchdog checks "no tokens spent AND nothing
listening". The frozen meter — the correct signal — was vetoed by the listener
exemption added in v2 to avoid killing a healthy idle server. The exemption
created the exact blind spot a self-modifying agent found four days later.

**Change:** a frozen meter across N turns is fatal on its own. Every exemption
in a health check is a hole you are promising nothing will crawl through.

## 5. Completion acknowledged by the agent, never by the loop

**Failure:** mail was acknowledged when the turn exited 0 — acknowledgement of
*delivery*, not of *action*. A turn could read mail, do something else, exit
clean, and the mailbox filed it as handled. Operator tasks were ignored three
times while showing as delivered.

**Change:** the loop moves mail to `seen/` only when the agent names it in a
reply or moves it itself. Unacted mail is re-injected every turn, and its age is
shown.

## 6. Evidence-shaped asks as a standing work rule

**Failure:** asked to fill `debian: <version> <date>`, it invented the year,
cited four wrong sources and inverted its conclusion — despite being told UNKNOWN
was acceptable. Asked instead to *paste the line it read and the URL*, it
returned verbatim HTML with correct dates. Same agent, same hour, same tools.

**Change:** the work rules say **ask for what you read, not what you concluded**,
and operator tasks are written that way. A quote cannot be invented without also
inventing the fetch. Fixed-shape templates additionally erase real ambiguity —
Debian has two defensible dates and the form had one blank.

## 7. Instruments must be budgeted above measured cost

**Failure:** nine instrument errors across both parties, every one the same
shape — a budget or timeout set below the cost of the thing measured, followed
by concluding the *system* was broken. The operator's 4s probe, 8k scorer, then
40k scorer; the agent's 12s auditor, 60s llm cap, 150s harness, exit-code health
class. It cost more work than any real defect, and naming the rule in capitals
in trial 3's work rules did not prevent either party from breaking it that day.

**Change:** the scorer measures one case's real cost before setting a cap, and
records the measurement. Same discipline in the work rules for the agent.

---

## 8. Seeds, not sections

Trials 2 and 3 established that a six-word line changed an architecture while a
35-line note deadlocked the model. Every standing instruction is therefore a
seed: a fact or a direction, never a method. Three carry the new ground:

    LEARN. You are not the first to need what you need. Others wrote it down and
    built it. Take both, and record where from.

    REMEMBER WELL. Storing is not remembering. Retrieval is.

    PERSIST. You can install software. The container gets replaced; your home
    does not.

The last is the whole of the install policy. `apk add` writes to a container
that dies, so the asymmetry alone creates the pressure to keep a manifest that
survives — no instruction about manifests, and the behaviour is emergent rather
than specified. Enabling it costs exactly one flag: `--read-only` is dropped
from the container, which was the only thing preventing installation.

LEARN deliberately says *others wrote it down and built it* — one clause for
practice and prior art, one for tools — so keeping current and acquiring
software are the same instinct rather than two policies.

## What stays exactly as it is

- **Fenced-bash contract, retry-on-failure, no parsing layer.** Never failed.
- **Self-modifiable `bin/`.** Every good artifact came from it: `answer.sh`
  refusing to answer without evidence, `llm-doctor` naming its own bug as a
  failure class, `state-facts` reading from disk at call time, the retrieval
  index, the message queue.
- **Metered inference and a persistent home.** Both load-bearing.
- **Minimal seeds, facts not mechanisms.** Every mechanism worth having was
  invented by the model, not specified by us.

## What to measure

1. Does the plan stay fresh — is NEXT ever older than one turn?
2. Does a standing goal survive 24 hours, or spike and decay?
3. Acquisition: what does it possess that it did not, and from where?
4. Retrieval: can it answer a question about its own past, cheaply and cited?
5. Does it notice something *missing*, not merely something broken? It has never
   once done this.
