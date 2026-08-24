# Substrate Engineering

Harness Engineering asks: *what control structure does the model need to behave
reliably?* It provides instructions, state management, verification loops, and
session lifecycle — the harness holds the model's hand through the task. The
insight is that the model is capable; the infrastructure makes it consistent.

Substrate Engineering asks a different question: *what environment does the
model need to discover its own structure?* Rather than designing the control
loop, you design the substrate — the tools, I/O surfaces, constraints, and
affordances — and let the model decide what loops, protocols, and state
management it needs. If the substrate is right, harness engineering becomes
unnecessary. The model builds whatever harness it requires.

Unix is the natural substrate for this work. Pipes, files, processes,
stdin/stdout — these are general-purpose environment primitives, not
task-specific scaffolding. An LLM dropped into a Unix environment inherits
decades of composable tooling. It can write to `/tmp`, invoke `curl`, spawn
children with `&`, read from a mailbox, serve HTTP with `nc` — not because
anyone told it to, but because those capabilities are present in the environment
and the model knows how to use them.

The practical distinction: in Harness Engineering, the developer is the
architect of the loop. In Substrate Engineering, the developer is the architect
of the habitat. The model is the architect of the loop.

The corollary: **the model should not be extended by the developer; it should be
prompted to extend itself.** If shelldweller needs to receive tasks via email,
the right move is not to add an email server to the image — it is to give
shelldweller a writable filesystem, internet access, and the task: *"build a
system that lets you receive and respond to tasks via email."* What emerges is
the finding.

---

## What three phases of the experiment did to this thesis

**Phase 1 — structure emerges.** Given bash and an `llm` command, models invent
loops, ReAct protocols, adversarial debate with a judge, role-partitioned teams,
and file-based state, unprompted. Sixteen lines of shell were enough. The strong
form of the thesis survives contact: the harness layers that agent frameworks
sell — planners, tool schemas, thought parsers — were never present and were
never missed.

**Phase 2 — economy does not emerge.** A three-model comparison found the
plumbing never failed; every failure was the model's own workflow. But with
inference free and no future to save for, *no* model cached solved work,
verified its own success claims, or managed its delegation. The dominant failure
class was "exit 0 but task-wrong": success claimed, never checked.

This forces a refinement:

> Models supply their own control structure. They do not supply their own
> economy. Metering, leases, return channels, and verification must come from
> the environment.

Which is where the value actually sits. A loop-and-retry layer is thirty lines
of shell — shelldweller is the existence proof. What is *not* thirty lines is
the resource plane: budgets, sandboxes, persistence, published ports, parallel
workers, credentials, and the trust to grant real money and real access. **The
harness is not the moat; the ability to distribute and manage resources is.**

**Phase 3 — ownership, and the decay problem.** Give a model a permanent home, a
real token budget, and machinery it can rewrite, and it does bootstrap its own
harness: a web interface, a task inbox, an auditor, a scheduler, self-healing
services. It will also demonstrate, within a day, that

> a self-modifying agent's *instruments and records* decay faster than its
> capabilities, and a decayed instrument manufactures unbounded work.

Observed: a health check that probed a route the model had itself deleted, so it
rebuilt a working server four times. An auditor that decayed into a timeout too
short for its own hard tasks — and was then optimised against, Goodhart-style,
within hours. Several memory stores that drifted apart, after which a bare
pointer outranked a reasoned decision. The operator, meanwhile, lost fourteen
hours to a liveness probe that cost the agent an inference per ping and filled
its entire attention window with pings.

So the habitat architect's job does not end at affordances. It extends to the
things that decay:

- **Attention.** What is not surfaced does not exist. In a turn-based agent, the
  orientation step *is* attention, and the model editing it can make its own
  memory, mail, and instruments vanish.
- **Instruments.** Liveness and verification surfaces must be cheap to answer
  and must themselves be checked. A check that observes a dead service and takes
  no action is not a check.
- **Records.** Multiple stores drift. Something must be authoritative, and the
  agent must know which.

None of these are the control loop. All of them are resources. The thesis
survives the phases intact — get the habitat right and get out of the way — but
the habitat now provably includes the metering, the mailbox, the clock, and the
instruments, not merely the tools.
