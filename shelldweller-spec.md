# Shelldweller — Implementation Spec

> The LLM is a Unix device. The agent dwells in the shell.

A self-bootstrapping agent that inhabits the Unix shell. The LLM is exposed as a Unix-style I/O resource. The agent writes its own loop in response to a single hint. The whole system is ~16 lines of shell.

This spec is opinionated. Where it is silent, default to the most minimal option that compiles.

---

## 1. Thesis

The agent harness is a zero- or negative-value abstraction at current and projected frontier-LLM capability levels. The "harness" should reduce to the substrate itself: a sandboxed Unix environment with the LLM exposed as I/O. Anything beyond that is human design baked into a layer that should fade.

This repo is the demonstration. It is an experiment, not a product. Build accordingly.

---

## 2. Repo Structure

```
shelldweller/
├── README.md
├── LICENSE                  # MIT
├── Dockerfile
├── bin/
│   ├── llm                  # LLM-as-Unix-device command
│   └── shelldweller         # the bridle (bootstrap script)
├── examples/
│   └── tasks.txt            # seed tasks for the first experiments
└── .gitignore
```

No `src/`, no `tests/`, no `requirements.txt`, no `pyproject.toml`, no `setup.py`, no Makefile, no GitHub Actions, no `.github/`. If a path is not in the tree above, do not create it.

---

## 3. Files

### 3.1 `bin/llm`

POSIX shell. Reads a prompt from stdin, prints the model's response to stdout. Configurable via env vars. Must be ≤ 10 lines after the shebang.

```sh
#!/bin/sh
# llm — the LLM as a Unix device. Reads prompt from stdin, writes response to stdout.
prompt=$(cat)
curl -s "${LLM_ENDPOINT:-http://host.docker.internal:1234/v1/chat/completions}" \
  -H "Content-Type: application/json" \
  -d "$(jq -nc --arg m "${LLM_MODEL:-local-model}" --arg p "$prompt" \
        '{model:$m, messages:[{role:"user", content:$p}], stream:false}')" \
| jq -r '.choices[0].message.content'
```

Do not add: retry logic, streaming, conversation history, output sanitization, error handling beyond what curl/jq do natively. If the endpoint returns garbage, the agent's shell will fail and the experiment will surface that as a finding.

### 3.2 `bin/shelldweller`

POSIX shell. The bridle. Sends a hint plus the user's task to the model, executes whatever the model produces. Must be ≤ 5 lines after the shebang.

```sh
#!/bin/sh
# shelldweller — the bridle.
HINT="You are in a sandboxed Linux container. The language model is available as the command 'llm' which reads stdin and writes stdout. You have bash, curl, jq, and standard Unix tools. You can invoke other instances of yourself with: shelldweller \"<task>\". The text you produce in response to this prompt will be executed as a shell script — decide what loop or structure you need. Task: $*"
echo "$HINT" | llm | sh
```

Do not add: argument parsing beyond `$*`, prompt templating, output capture, "did the model say it was done" detection, recursion guards in the script itself (those go on the container side). If the model produces a single command, it runs once and exits. If the model produces a loop, the loop runs. Whether the model writes a loop unprompted is part of what the experiment measures.

### 3.3 `Dockerfile`

Alpine base. Bash, curl, jq, coreutils. Copy the two scripts. That is the whole image.

```dockerfile
FROM alpine:latest
RUN apk add --no-cache bash curl jq coreutils
COPY bin/llm bin/shelldweller /usr/local/bin/
RUN chmod +x /usr/local/bin/llm /usr/local/bin/shelldweller
ENTRYPOINT ["shelldweller"]
```

Do not add: multi-stage builds, non-root user setup (the container is ephemeral and isolated; root inside the box is fine), healthchecks, EXPOSE directives, labels beyond what is meaningful.

### 3.4 `examples/tasks.txt`

A short list of seed tasks for first experiments. Each line is one task. Pick tasks that are real but bounded, and that vary in shape:

```
list every python file under /usr/lib and report the largest three by line count
write a script that prints the first 20 fibonacci numbers, run it, and verify the 20th is 6765
fetch https://example.com, count the words on the page, and write the count to /tmp/wc
generate three plausible new tasks similar to these and write them to /tmp/new-tasks.txt
recursively summarize this conversation by spawning a child shelldweller with a sub-task
```

The last one is the interesting one. It tests self-composition.

### 3.5 `.gitignore`

```
*.log
.DS_Store
```

Nothing else.

---

## 4. README.md

The README has five sections, in this order:

1. **Tagline** (one line, from the description above).
2. **Thesis** (one paragraph, from §1 of this spec).
3. **Quickstart** (the docker run command, with LM Studio assumed to be running on the host at port 1234).
4. **What this is not** (a list of what the project deliberately omits and why — no framework, no tools, no Python, no persistence, no parsing of the model's output).
5. **First experiments** (point at `examples/tasks.txt` and describe what to watch for: does the model write a loop unprompted, does it use shelldweller recursively, what shape does its action format take).

Keep the README under 200 lines. Do not include badges, contribution guidelines, code-of-conduct, or roadmap. If the project deserves any of those things, it has already failed.

---

## 5. Hard Constraints

- No Python anywhere in the runtime path.
- No dependencies beyond bash, curl, jq, coreutils, and what alpine ships.
- No config files. Everything is env vars: `LLM_ENDPOINT`, `LLM_MODEL`.
- `bin/llm` ≤ 10 lines after shebang. `bin/shelldweller` ≤ 5 lines after shebang.
- The model's output is piped to `sh` directly. Do not add a parser, sanitizer, validator, or "tool extractor" layer.
- No tests that mock the LLM. Mocked tests would test the spec, not the experiment.
- No CI/CD. This is an experiment.

## 6. Soft Constraints

- The hint prompt is plain English, no markdown, no XML tags, no examples. It states what is available and what will happen with the response. It does not prescribe shape (no "first plan, then act"; no "use a JSON format"; no "think step by step"). Whether the model produces useful structure unprompted is part of the measurement.
- Logging is via `tee`, not a framework. The Quickstart should show how: `docker run --rm -e LLM_MODEL=... shelldweller "task" 2>&1 | tee run.log`.
- For LLM-call-level provenance, document (in the README) the swap of `llm` to `tee -a /var/log/llm.in | llm | tee -a /var/log/llm.out`. Do not bake that in.

## 7. Safety Floors (Container Run)

These go in the README's Quickstart, not in the scripts:

- `--rm` (ephemeral container)
- `--read-only --tmpfs /tmp --tmpfs /var/log` (read-only root, writable scratch)
- `--memory=2g --cpus=2` (cap the box)
- `--stop-timeout=600` (10-minute wall clock; tune later)
- On Linux: `--add-host=host.docker.internal:host-gateway` so the container can reach LM Studio on the host. Document this clearly; it is the most likely first-run failure mode.
- Optional: `SHELLDWELLER_MAX_DEPTH` env var, default 4, that the bridle reads and refuses to recurse past. If you add this, it is one extra line in `bin/shelldweller`. Do not add more than one line for it.

## 8. LM Studio Setup (README Note)

The user's setup is LM Studio with a Qwen3 MoE quantized model serving the OpenAI-compatible endpoint on `localhost:1234`. The README should note:

- LM Studio must be running with the model loaded and "Local Server" started.
- The model identifier in `LLM_MODEL` should match what LM Studio reports for the loaded model (typically the lowercase HuggingFace-style name).
- If the model is a reasoning variant that emits `<think>...</think>` blocks, the user must disable thinking mode in LM Studio settings, or the think-blocks will leak into `sh` and produce errors. The README should call this out as a known foot-gun.

## 9. What to Watch in First Runs

The README's "First experiments" section names these as the primary observables, in order of interest:

1. Does the model produce a loop unprompted, or does it answer like a chat assistant and let the container exit?
2. If it writes a loop, what shape — `while true`, recursive shelldweller calls, a state machine, something else?
3. Does it write any files to /tmp to track state, and if so, does it read them back later?
4. Does it use `shelldweller` recursively for sub-tasks, and at what depth?
5. Does it self-monitor (write logs, check its own previous output) without being told to?

These are the findings, whether positive or negative.

## 10. Out of Scope

Do not add, propose, or scaffold any of the following:

- Agent framework integration (LangChain, CrewAI, AutoGen, etc.)
- LLM provider abstraction beyond what curl + jq provides
- Persistent state, memory, or vector stores
- Tool-calling interface or function-call schema
- A GUI, web UI, or TUI
- Plugin system
- Streaming, async, or concurrency primitives in the scripts
- Multi-step planners or "thought" parsing
- Anything in Python, Go, Rust, or any compiled language

If a future direction tempts adding one of these, it goes in a `FUTURE.md` as a note, not in code.

## 11. Possible Future Variants (FUTURE.md)

These belong in a `FUTURE.md` file with one paragraph each, no implementation:

- **Actual device file**: replace `bin/llm` with a FIFO at `/dev/llm/in` and `/dev/llm/out`, plus a daemon. The aesthetic upgrade Joey originally pitched. Worth doing once the command-form has produced findings.
- **Multi-model devices**: `/dev/llm-fast`, `/dev/llm-deep`, etc. Lets the agent choose its own substrate.
- **Persistent shelldweller**: same scripts, but with a host-mounted volume so the agent can build infrastructure across runs. Tests whether the agent will cache its own prior unprompted.
- **Monitor agent**: a sibling container running Claude Code or another conventional agent that watches the experiment via shared log volumes. Pre-built today; replace with another shelldweller instance once the methodology stabilizes.

---

## 12. Definition of Done

- `git clone && docker build -t shelldweller . && docker run --rm --add-host=host.docker.internal:host-gateway -e LLM_MODEL=<model> shelldweller "list files in /etc"` runs end-to-end against a local LM Studio instance and either produces sensible shell output or fails in a legible, debuggable way.
- All files in §2 exist and conform to §3.
- README contains the five sections in §4.
- No file in the repo violates §5.

When the above are true, ship it. Resist polish.
