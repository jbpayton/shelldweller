# Substrate Engineering

Harness Engineering asks: *what control structure does the model need to behave reliably?* It provides instructions, state management, verification loops, and session lifecycle — the harness holds the model's hand through the task. The insight is that the model is capable; the infrastructure makes it consistent.

Substrate Engineering asks a different question: *what environment does the model need to discover its own structure?* Rather than designing the control loop, you design the substrate — the tools, I/O surfaces, constraints, and affordances — and let the model decide what loops, protocols, and state management it needs. If the substrate is right, harness engineering becomes unnecessary. The model builds whatever harness it requires.

Unix is the natural substrate for this work. Pipes, files, processes, stdin/stdout — these are general-purpose environment primitives, not task-specific scaffolding. An LLM dropped into a Unix environment inherits decades of composable tooling. It can write to `/tmp`, invoke `curl`, spawn children with `&`, read from a mailbox, serve HTTP with `nc` — not because anyone told it to, but because those capabilities are present in the environment and the model knows how to use them.

The practical distinction: in Harness Engineering, the developer is the architect of the loop. In Substrate Engineering, the developer is the architect of the habitat. The model is the architect of the loop.

Shelldweller is the demonstration. Sixteen lines of shell expose the LLM as a Unix device. No framework, no tool schema, no planner. Given a task, the model decides whether it needs a loop, a sub-agent, a ReAct protocol, a persistent identity, or a cron job — and writes it. The role of the substrate engineer is to get the conditions right, then get out of the way.

The corollary: **the model should not be extended by the developer; it should be prompted to extend itself.** If shelldweller needs to receive tasks via email, the right move is not to add an email server to the image — it is to give shelldweller a writable filesystem, internet access, and the task: *"build a system that lets you receive and respond to tasks via email."* What emerges is the finding.
