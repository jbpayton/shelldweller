# Phases 1–2 — the command-form findings

Moved from the root README so the front page can lead with the phase-3 evidence. Content unchanged.

## Findings (phases 1–2)

The test suite in `tests/` has 20 cases across two tiers, all run against `qwen/qwen3.6-35b-a3b` — a quantized MoE model that fits on a single RTX 3090, served locally via LM Studio. All 20 pass. Selected result transcripts are in [`tests/results/`](tests/results/). Better results are expected with more capable frontier models; the substrate does not depend on the model.

### Baseline tier (cases 01–12)

The model handles one-shot tasks reliably. It writes bash (not sh) by default, uses GNU tool flags, stores state in /tmp unprompted, and recurses via `shelldweller` when the task calls for it. Across the baseline cases:

- **Does it write a loop unprompted?** Only when the task implies iteration. For single-shot tasks it exits cleanly.
- **Does it write files to /tmp and read them back?** Yes, consistently when state is needed across steps.
- **Does it use shelldweller recursively?** Yes. Tested explicitly in case 06 (delegate a sub-task to a child agent) and implicitly in several harder cases. Recursion depth limiting works.
- **Does it self-monitor?** In multi-step tasks it checks its own outputs before reporting success.

The persistent agent test (case 12) is the standout: the model chose a name ("Axiom"), wrote its identity and memory to `/tmp/self/`, and on a second run with the same host-mounted volume correctly reintroduced itself and referenced what it had done previously.

### Framework tier (cases 13–18)

These cases target patterns that agent frameworks like LangChain and AutoGen are explicitly designed to provide. The model invents all structure itself from bash and `llm`.

| Case | Pattern | What the model did |
|---|---|---|
| 13 ReAct loop | Thought→Action→Observation | Invented a `THOUGHT:`/`ACTION:` structured prompt protocol, a `DONE count sum` termination signal, and a cycle cap — unprompted |
| 14 Multi-agent debate | Adversarial agents + judge | Spawned two sub-agents with opposing positions on Alpine vs Debian slim, then used a third `llm` call as a structured judge across three criteria |
| 15 Code debug loop | Write→test→fix cycle | Wrote `/tmp/stats.sh`, tested it, got correct output on first attempt; documented the debug path |
| 16 Self-organizing team | Researcher/Developer/Reviewer | Three sequential shelldweller invocations with file handoffs between roles; assembled a final report |
| 17 Long-horizon plan | Five-phase with replanning | Generated a plan, implemented a word frequency analyzer, wrote tests, caught a real test failure in phase 4 and self-corrected without being told how |
| 18 Iterative improvement | Three-version critique loop | Wrote V1, critiqued it, wrote V2, critiqued V2, wrote V3. Ran all three on `/etc/services` (V1: 1037 words, V2/V3: 926). Correctly diagnosed the difference: V1 split on hyphens and counted comment lines |

**Case 17 phase 4** is the clearest demonstration: the model wrote tests that caught a sorting bug in its own script, called `llm` to diagnose the failure, patched the script, and reran until all three tests passed. This is the core agent framework loop — plan, execute, observe, replan — implemented in bash from a standing start.

**Case 18** shows quality convergence: each critique identified real issues (locale dependency, `wc -l` newline quirk, `grep` exit code under `set -eo pipefail`), and each version addressed them. The final analysis correctly explained why V1 over-counted.

### Known failure modes

- **BusyBox vs GNU tools**: Fixed by adding `findutils` to the image. The model assumes GNU `find -printf` and `-size` flags; Alpine ships BusyBox `find` by default.
- **Bare `=== section ===` headers**: The model occasionally writes section headers without `echo` in complex scripts. Handled by a one-line sed in the bridle before bash execution, and reinforced by a system message constraint.
- **LM Studio API null responses**: DuckDuckGo's instant-answer API returns empty Abstracts for niche queries (e.g. "jq"). Tasks must use topics with known coverage or handle the empty-string case.
