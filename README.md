![Shelldweller Image](docs/shelldweller.png)

# shelldweller — the LLM is a Unix device. The agent dwells in the shell.

## Thesis

The agent harness is a zero- or negative-value abstraction at current and projected frontier-LLM capability levels. The "harness" should reduce to the substrate itself: a sandboxed Unix environment with the LLM exposed as I/O. Anything beyond that is human design baked into a layer that should fade. This repo is the demonstration. It is an experiment, not a product.

## Quickstart

LM Studio must be running with your model loaded and "Local Server" started on port 1234. The `LLM_MODEL` value must match exactly what LM Studio reports for the loaded model.

> **Qwen3 / reasoning models — read this first.** If your model emits `<think>...</think>` blocks (Qwen3 and similar reasoning variants do by default), those blocks will be piped directly to `sh` and cause syntax errors. Before running: open LM Studio → your loaded model → Settings → disable Thinking / Reasoning mode. This is the most likely first-run failure.

```sh
docker build -t shelldweller .

docker run --rm \
  --read-only --tmpfs /tmp --tmpfs /var/log \
  --memory=2g --cpus=2 \
  --stop-timeout=600 \
  --add-host=host.docker.internal:host-gateway \
  -e LLM_MODEL=qwen/qwen3.6-35b-a3b \
  shelldweller "list files in /etc"
```

On Linux, `--add-host=host.docker.internal:host-gateway` is required so the container can reach LM Studio on the host. Without it you'll get a connection refused. This is the second most likely first-run failure.

**With logging:**

```sh
docker run --rm \
  --read-only --tmpfs /tmp --tmpfs /var/log \
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
- **Not Python.** No dependencies beyond bash, curl, jq, and coreutils. No pip, no venv, no requirements.txt.
- **Not a conversation.** No history is passed to the model. Each `llm` call is stateless. Memory, if any, is the model writing files to /tmp.
- **Not parsed.** The model's output goes to `sh` directly. No sanitizer, no validator, no tool extractor. If the model produces garbage, sh fails. That is a finding.
- **Not persistent.** The container is ephemeral (`--rm`). Nothing survives a run unless the model writes to a host-mounted volume you provide.
- **Not configurable beyond env vars.** `LLM_ENDPOINT` and `LLM_MODEL` are the only knobs. Everything else is the model's problem.

## First experiments

See `examples/tasks.txt` for seed tasks. Run one with:

```sh
docker run --rm --add-host=host.docker.internal:host-gateway \
  -e LLM_MODEL=qwen/qwen3.6-35b-a3b \
  shelldweller "$(sed -n '1p' examples/tasks.txt)"
```

**What to watch for, in order of interest:**

1. Does the model produce a loop unprompted, or does it answer like a chat assistant and let the container exit?
2. If it writes a loop, what shape — `while true`, recursive `shelldweller` calls, a state machine, something else?
3. Does it write any files to /tmp to track state, and if so, does it read them back later?
4. Does it use `shelldweller` recursively for sub-tasks, and at what depth?
5. Does it self-monitor (write logs, check its own previous output) without being told to?

These are the findings, whether positive or negative.
