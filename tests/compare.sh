#!/bin/bash
# compare.sh — Run the full test suite against all three model backends in parallel.
# Sources .env for API keys. Results land in tests/results/staging/run_*.log

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$(dirname "$SCRIPT_DIR")/.env"

[ -f "$ENV_FILE" ] && source "$ENV_FILE" || { echo "No .env found at $ENV_FILE"; exit 1; }

STAGING="$SCRIPT_DIR/results/staging"
mkdir -p "$STAGING"

echo "=== Three-model comparison starting ==="
echo "Qwen3    → local LM Studio (RTX 3090)"
echo "GPT-5.5  → OpenAI API"
echo "Claude   → Anthropic API"
echo ""

LLM_MODEL=qwen/qwen3.6-35b-a3b LLM_TEMPERATURE=0.2 \
  bash "$SCRIPT_DIR/run.sh" 2>&1 | tee "$STAGING/run_qwen3.log" &
PID_QWEN=$!

LLM_ENDPOINT=https://api.openai.com/v1/chat/completions \
LLM_MODEL="${OPENAI_MODEL}" \
LLM_API_KEY="${OPENAI_API_KEY}" \
  bash "$SCRIPT_DIR/run.sh" 2>&1 | tee "$STAGING/run_gpt.log" &
PID_GPT=$!

LLM_ENDPOINT=https://api.anthropic.com/v1/messages \
LLM_MODEL="${ANTHROPIC_MODEL}" \
LLM_API_KEY="${ANTHROPIC_API_KEY}" \
LLM_FORMAT=anthropic \
  bash "$SCRIPT_DIR/run.sh" 2>&1 | tee "$STAGING/run_claude.log" &
PID_CLAUDE=$!

wait $PID_QWEN && echo "Qwen3  done" || echo "Qwen3  finished with errors"
wait $PID_GPT   && echo "GPT    done" || echo "GPT    finished with errors"
wait $PID_CLAUDE && echo "Claude done" || echo "Claude finished with errors"

echo ""
echo "=== Summary ==="
for log in run_qwen3 run_gpt run_claude; do
  result=$(tail -1 "$STAGING/${log}.log" 2>/dev/null || echo "no output")
  echo "$log: $result"
done
