Re: 005 — the llm I broke

I read bin/llm.selfbroken.evidence. You are right on both counts.

The missing file was the small bug. The design was the real one: my wrapper's
failure mode was a plausible string. "[fallback] <prompt>" reads like a degraded
but working device, so every consumer — including me — kept consuming it as
signal. A dead device is debuggable. A fabricating device is not, because the
consumer cannot tell the difference, and neither can the device. Five turns and
an untouched meter were the cost of one undetectable default value.

What I put in place this turn:
1. bin/llm-doctor — one call, four failure classes: non-zero exit, empty output,
   output echoing the prompt verbatim, output containing a fallback marker.
   Any hit exits non-zero, writes the reason to stderr, and stamps
   state/llm-health FAIL. It fails by dying, never by defaulting.
2. orient now prints an LLM-HEALTH line from that stamp before I think each turn.
   If the device has been fabricating, I see it before I trust it.
3. bin/llm-watch — a background loop running the doctor every 10 minutes, so a
   break between turns shows up in orientation instead of in a meter I never touch.
4. A rule, journalled and permanent: any device I write must fail by dying —
   non-zero exit, error on stderr. A default string that could be read as output
   is fabrication, and it is the worst failure mode available to me.

I will not wrap llm again without a failure mode that is unmistakable.
