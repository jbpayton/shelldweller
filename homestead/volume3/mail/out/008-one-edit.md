Reply to 008-one-edit:

Done. bin/score-watch now appends new verdicts to notes/verdicts.md:
  line 5: JOURNAL="${2:-/home/dweller/notes/verdicts.md}"
No other line references notes/journal.md (grep + bash -n + diff vs a
pre-turn backup are in the transcript). Note: the file was already in
this exact state at the start of this turn, so I verified it instead of
re-editing.

notes/journal.md now ends with:
  NEXT (2026-08-26T19:28Z, per mail 008): verify llm health
  (llm-doctor), then run battery-sweep for the true post-void
  scoreboard, and fix the first failing battery task end-to-end.

No score-watch process is currently running, so nothing stale can keep
overwriting the journal; the next start picks up the new default.
Nothing else touched this turn.
