![Shelldweller Image](docs/shelldweller.png)

# shelldweller — the LLM is a Unix device. The agent dwells in the shell.

## Thesis

The agent harness is a zero- or negative-value abstraction at current and projected frontier-LLM capability levels. The "harness" should reduce to the substrate itself: a sandboxed Unix environment with the LLM exposed as I/O. Anything beyond that is human design baked into a layer that should fade. This repo is the demonstration. It is an experiment, not a product.

## Quickstart

LM Studio must be running with your model loaded and "Local Server" started on port 1234. The `LLM_MODEL` value must match exactly what LM Studio reports for the loaded model.

> **Qwen3 / reasoning models.** `bin/llm` automatically strips `<think>...</think>` blocks from responses before they reach bash — you do not need to disable thinking mode in LM Studio. Thinking improves response quality; the harness handles the rest.

```sh
docker build -t shelldweller .

docker run --rm \
  --read-only --tmpfs /tmp:exec --tmpfs /var/log \
  --memory=2g --cpus=2 \
  --stop-timeout=600 \
  --add-host=host.docker.internal:host-gateway \
  -e LLM_MODEL=qwen/qwen3.6-35b-a3b \
  shelldweller "list files in /etc"
```

Note `--tmpfs /tmp:exec` — the model writes and executes scripts from /tmp; the exec flag is required.

On Linux, `--add-host=host.docker.internal:host-gateway` is required so the container can reach LM Studio on the host. Without it you'll get connection refused. This is the most likely first-run failure.

**With logging:**

```sh
docker run --rm \
  --read-only --tmpfs /tmp:exec --tmpfs /var/log \
  --memory=2g --cpus=2 \
  --stop-timeout=600 \
  --add-host=host.docker.internal:host-gateway \
  -e LLM_MODEL=qwen/qwen3.6-35b-a3b \
  shelldweller "list files in /etc" 2>&1 | tee run.log
```

**LLM call-level provenance** (swap `llm` for tee pipes, do not bake this in):

```sh
echo "$prompt" | tee -a /var/log/llm.in | llm | tee -a /var/log/llm.out
```

**Recursion depth** is capped at 4 by default. Override with `-e SHELLDWELLER_MAX_DEPTH=8`.

## What this is not

- **Not a framework.** No agent loop, no tool-calling schema, no planner. The model writes its own loop if it wants one.
- **Not Python.** No dependencies beyond bash, curl, jq, coreutils, and findutils. No pip, no venv, no requirements.txt.
- **Not a conversation.** No history is passed to the model. Each `llm` call is stateless. Memory, if any, is the model writing files to /tmp.
- **Not parsed.** The model's output is executed directly as bash. If the model produces garbage, bash fails. That is a finding.
- **Not persistent.** The container is ephemeral (`--rm`). Nothing survives a run unless the model writes to a host-mounted volume you provide.
- **Not configurable beyond env vars.** `LLM_ENDPOINT`, `LLM_MODEL`, and `LLM_SYSTEM` are the only knobs. Everything else is the model's problem.

## Findings

The test suite in `tests/` has 18 cases across two tiers, all run against `qwen/qwen3.6-35b-a3b` via LM Studio. All 18 pass.

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
