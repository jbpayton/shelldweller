#!/bin/bash
# compare3x.sh — Run full suite 3 times against each backend in parallel.
# Outputs land in tests/results/staging/runs/{model}_{n}.log
# All three models run concurrently per iteration; iterations are sequential
# so we don't hammer either API with 9 simultaneous runs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$(dirname "$SCRIPT_DIR")/.env"
[ -f "$ENV_FILE" ] && source "$ENV_FILE" || { echo "No .env found at $ENV_FILE"; exit 1; }

OUT="$SCRIPT_DIR/results/staging/runs"
mkdir -p "$OUT"

for iter in 1 2 3; do
  echo "=== Iteration $iter / 3 ==="

  LLM_MODEL=qwen/qwen3.6-35b-a3b LLM_TEMPERATURE=0.2 LLM_CONTEXT=131072 \
    bash "$SCRIPT_DIR/run.sh" > "$OUT/qwen3_${iter}.log" 2>&1 &
  PQ=$!

  LLM_ENDPOINT=https://api.openai.com/v1/chat/completions \
  LLM_MODEL="${OPENAI_MODEL}" LLM_API_KEY="${OPENAI_API_KEY}" \
    bash "$SCRIPT_DIR/run.sh" > "$OUT/gpt_${iter}.log" 2>&1 &
  PG=$!

  LLM_ENDPOINT=https://api.anthropic.com/v1/messages \
  LLM_MODEL="${ANTHROPIC_MODEL}" LLM_API_KEY="${ANTHROPIC_API_KEY}" \
  LLM_FORMAT=anthropic LLM_TEMPERATURE=0.5 \
    bash "$SCRIPT_DIR/run.sh" > "$OUT/claude_${iter}.log" 2>&1 &
  PC=$!

  wait $PQ && echo "iter $iter: qwen3 done" || echo "iter $iter: qwen3 errors"
  wait $PG && echo "iter $iter: gpt done"   || echo "iter $iter: gpt errors"
  wait $PC && echo "iter $iter: claude done" || echo "iter $iter: claude errors"
done

echo ""
echo "=== All iterations complete ==="
for f in "$OUT"/*.log; do
  pass=$(grep -c "VERDICT: PASS" "$f" 2>/dev/null || echo 0)
  fail=$(grep -c "VERDICT: FAIL" "$f" 2>/dev/null || echo 0)
  printf "%-30s %s pass, %s fail\n" "$(basename "$f")" "$pass" "$fail"
done
