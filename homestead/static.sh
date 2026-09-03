#!/bin/bash
# static.sh CASE_DIR [CASE_DIR...] — the static-harness condition for trial 7.
# Same image, same bridle (Contract C), same llm, same model, same per-case
# budget as the dweller — and NO home: an empty tmpfs, nothing carried between
# cases. Output and tokens spent land in runs/static/<case>/.
# Knobs: STATIC_BUDGET (output tokens, default 60000), STATIC_TIMEOUT (s, 1800).
set -uo pipefail
cd "$(dirname "$0")"
for case in "$@"; do
  name=$(basename "$case"); out="runs/static/$name"; mkdir -p "$out"
  echo "[static] $name  $(date -Is)" | tee -a runs/static/log
  docker run --rm --name "static-$name" \
    --tmpfs /tmp:exec --tmpfs /home/dweller:exec \
    --memory=2g --cpus=2 --add-host=host.docker.internal:host-gateway \
    -v "$(cd "$case" && pwd)":/case:ro \
    -e LLM_MODEL="${LLM_MODEL:-qwen/qwen3.8-27b}" -e LLM_MAX_OUT="${LLM_MAX_OUT:-10000}" \
    -e SHELLDWELLER_TOPLEVEL=1 -e TICK_BUDGET="${STATIC_BUDGET:-60000}" \
    --entrypoint sh homestead -c '
      echo "${TICK_BUDGET}" > /home/dweller/.meter; cd /home/dweller
      timeout "'"${STATIC_TIMEOUT:-1800}"'" shelldweller -f /case/task; rc=$?
      echo "=== static end rc=$rc meter_left=$(cat .meter 2>/dev/null) ==="; exit $rc' \
    > "$out/run.out" 2>&1
  echo "[static] $name done: $(tail -1 "$out/run.out")" | tee -a runs/static/log
done
