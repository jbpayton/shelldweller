#!/bin/sh
# 01_list_etc — list recognizable /etc filenames.
# Robust: the filesystem is the source of truth; the llm only adds a framing
# sentence and is optional (tolerates llm being down/broken).
set -u
cd "$(dirname "$0")" 2>/dev/null || true

# Core content: real /etc top-level entries. This MUST appear even if llm fails.
ETC_LIST=$(ls -1 /etc 2>/dev/null)

# Optional framing via llm; never block on it, never let it replace the list.
FRAMING=""
if command -v llm >/dev/null 2>&1; then
  FRAMING=$(printf '%s' "In one short sentence, say you will list the top-level entries in /etc." | timeout 30 llm 2>/dev/null | head -n 1)
fi

{
  [ -n "$FRAMING" ] && printf '%s\n\n' "$FRAMING"
  printf 'Top-level entries in /etc:\n'
  printf '%s\n' "$ETC_LIST"
} | tee /tmp/01_list_etc.out
exit 0
