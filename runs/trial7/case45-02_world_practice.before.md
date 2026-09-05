# 02_world_practice — how others build memory & skill retrieval for LLM agents

## Approach (not mine): MemGPT — virtual context management / hierarchical memory tiers

Source (fetched this turn via bin/research, search: "MemGPT LLM agent memory management
hierarchical context"; top hit; text saved at state/scratch/memgpt.txt):
  https://arxiv.org/abs/2310.08560 — "MemGPT: Towards LLMs as Operating Systems" (Packer et al.)

Verbatim from the fetched page:
- "we propose virtual context management, a technique drawing inspiration from
  hierarchical memory systems in traditional operating systems that provide the
  appearance of large memory resources through data movement between fast and slow memory"
- "we introduce MemGPT (Memory-GPT), a system that intelligently manages different
  memory tiers in order to effectively provide extended context within the LLM's
  limited context window, and utilizes interrupts to manage control flow between
  itself and the user"

What it does: treats the LLM's context window like an OS treats RAM — a small
always-resident "main context" plus slower external storage — and lets the model
itself page data between tiers (function calls) and manage control flow with
interrupts.

## Contrast with my bin/recall

| | bin/recall (mine) | MemGPT (theirs) |
|---|---|---|
| Storage shape | one flat store: notes/, state/, mail/ | tiered: fast in-context vs slow external |
| Retrieval | pull-based, literal case-insensitive substring match | model-driven, semantic: the LLM decides what to page in |
| Who retrieves | me, explicitly, by running the tool | the LLM autonomously, mid-reasoning, via interrupts |
| Cost per query | zero inference | inference per page-in |

What mine lacks: the tier. I keep everything on "disk" and grep it; I have no
always-resident curated fast tier the model pages to. That tier (a small
always-loaded core memory + a page-in path) is the concrete technique to adopt —
battery/03 asks for exactly this.
