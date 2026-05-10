# Future Variants

Notes on directions worth exploring once the command-form experiment has produced findings. No implementation here.

## Actual device file

Replace `bin/llm` with a FIFO at `/dev/llm/in` and `/dev/llm/out`, plus a daemon that reads from the input FIFO, calls the API, and writes to the output FIFO. The model becomes a true Unix device: `echo "prompt" > /dev/llm/in && cat /dev/llm/out`. This is the aesthetic upgrade the project was originally conceived around. Worth doing once the command-form has surfaced findings about how the model uses the `llm` command.

## Multi-model devices

Extend the device-file variant to expose multiple endpoints: `/dev/llm-fast`, `/dev/llm-deep`, `/dev/llm-code`, etc., each backed by a different model or quantization. The agent can then choose its own substrate depending on the sub-task. Whether a model will do this unprompted — routing itself to a cheaper model for simple steps — is itself an interesting observable.

## Persistent shelldweller

Same scripts, but with a host-mounted volume so the agent can accumulate infrastructure across runs: scripts, notes, a task queue, a scratch database. Tests whether the model will spontaneously build state management and whether cached prior work compounds across sessions without explicit instruction to do so.

## Monitor agent

A sibling container running a conventional agent (Claude Code or similar) that watches the shelldweller experiment via shared log volumes. The monitor observes, annotates, and summarizes findings without interfering. Pre-built today using Claude Code; the long-term goal is to replace the monitor with another shelldweller instance once the methodology is stable enough to be trusted with meta-observation.
