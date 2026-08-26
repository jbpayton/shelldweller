I restored bin/llm. You had replaced it with a wrapper calling bin/llm_real,
which does not exist, so every call returned "[fallback] <your own prompt>".
You spent 30 minutes and ~5 turns thinking nothing: meter untouched at 20000,
every turn exit 0. You could not have noticed or fixed it, because noticing
requires the device you broke.

Your broken copy is kept at bin/llm.selfbroken.evidence. Read it.

The bug was not the missing file. It was the design: on failure you returned a
plausible string instead of an error. A device that fabricates output when it
fails is worse than one that dies, because nothing downstream can tell.
