# Future Variants

Directions worth exploring. Items that have since been built are marked and kept
for the record, because what they turned into is more interesting than what was
proposed.

## Done

- **Persistent shelldweller** — *built, phase 3.* Proposed as "same scripts, but
  with a host-mounted volume so the agent can accumulate infrastructure across
  runs." What it became is [`homestead/`](../homestead/): a persistent container
  with turns inside it, a metered token economy, a published port, and machinery
  the model rewrites. It does compound across runs — and the interesting failures
  are about decay, not accumulation. See
  [`homestead/FINDINGS.md`](../homestead/FINDINGS.md).

- **Monitor agent** — *built, in the crude form.* A sibling watcher was proposed.
  In practice the operator plus a passive liveness probe filled the role, and the
  attempt produced the sharpest finding of the project: an observer that costs the
  agent an inference per check will consume its whole attention window and send it
  chasing phantom faults. Any future monitor agent must read logs and files, never
  poll the agent's own expensive surfaces.

## Still open

## Actual device file

Replace `bin/llm` with a FIFO at `/dev/llm/in` and `/dev/llm/out`, plus a daemon
that reads from the input FIFO, calls the API, and writes to the output FIFO.
The model becomes a true Unix device: `echo "prompt" > /dev/llm/in && cat
/dev/llm/out`. This is the aesthetic upgrade the project was originally
conceived around; the command form has now produced plenty of findings, so the
main reason to do it is elegance plus one real question — whether a device that
can be `tee`'d and multiplexed changes how the model reasons about its own
inference.

## Multi-model devices

Extend the device-file variant to expose multiple endpoints: `/dev/llm-fast`,
`/dev/llm-deep`, `/dev/llm-code`, each backed by a different model. Phase 2's
finding — that economy does not emerge when goods are free — makes this sharper
than it looked originally: the interesting observable is not whether the agent
*can* route itself, but whether **visible price differences** make it route
itself. Pair it with the existing meter so cheap models cost less budget.

## A single authoritative record

Trial 2's most expensive recurring bug was multi-store drift: journal, pointer
file, distilled summary and per-task ledgers diverging, after which the agent
trusted the mechanical store over its own reasoned decision. Worth trying a
substrate that provides exactly one authoritative, append-only record with a
cheap query surface — and seeing whether the agent still builds shadow copies.

## Enforced orientation budget

The agent pays its orientation cost every turn, forever, and grows it until
seeing costs more than doing. Rather than asking it to economise, have the turn
loop truncate or bill orientation explicitly, and watch whether curation becomes
a first-class activity rather than an emergency measure.

## Trial 3 seeds

Carry forward from trial 2, from birth rather than by mid-run patch: operator
orders that outrank journalled momentum; sub-agent-aware verification timeouts;
and liveness surfaces that are free to answer.
