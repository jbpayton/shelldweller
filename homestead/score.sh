#!/bin/bash
# score.sh — the external scorer. Runs the battery against the dweller's
# CURRENT machinery (its home mounted, its bin preferred) and appends verdicts
# to /home/dweller/scoreboard.log — the dweller's only trustworthy signal of
# improvement. Scoring inference is the operator's spend: the meter is
# refilled per case and restored afterward.
# Usage: ./score.sh [case_name]   (default: all plain task/criteria cases)
set -uo pipefail
cd "$(dirname "$0")"
VOL="${HOMESTEAD_VOLUME:-$PWD/volume}"
CASE_TIMEOUT="${CASE_TIMEOUT:-300}"
MODEL="${LLM_MODEL:-qwen/qwen3.8-27b}"
JUDGE_ENDPOINT="${JUDGE_ENDPOINT:-http://localhost:1234/api/v1/chat}"

[ -d "$VOL/battery" ] || { echo "no battery in $VOL — run ./run.sh once first"; exit 1; }

judge() { # task output exit_code criteria -> verdict text
  local prompt
  prompt=$(printf 'You are evaluating an autonomous shell agent. Given the task, its output, and the exit code, decide if it succeeded.\n\nTask: %s\n\nOutput:\n%s\n\nExit code: %s\n\nSuccess criteria: %s\n\nReply in exactly this format:\nVERDICT: PASS or FAIL\nREASON: one sentence explaining the verdict' \
    "$1" "$2" "$3" "$4")
  curl -s "$JUDGE_ENDPOINT" -H "Content-Type: application/json" \
    -d "$(jq -nc --arg mo "${JUDGE_MODEL:-$MODEL}" --arg p "$prompt" '{model:$mo, input:$p}')" \
  | jq -r '[.output[]? | select(.type == "message") | .content] | join("\n")'
}

saved_meter=$(cat "$VOL/.meter" 2>/dev/null || echo "")
stamp=$(date -Is); pass=0; fail=0; skip=0
echo "--- scoring run $stamp (model $MODEL) ---" >> "$VOL/scoreboard.log"

for dir in "$VOL"/battery/${1:-*}/; do
  name=$(basename "$dir")
  # Plain cases only: servers, probes, and multi-run cases need host orchestration.
  if [ ! -f "$dir/task" ] || [ -f "$dir/probe.sh" ] || [ -f "$dir/server" ]; then
    skip=$((skip+1)); continue
  fi
  task=$(cat "$dir/task"); criteria=$(cat "$dir/criteria")
  echo "${SCORE_BUDGET:-20000}" > "$VOL/.meter"
  out=$(timeout -k 30 "$CASE_TIMEOUT" docker run --rm \
    --entrypoint homestead-entry \
    --read-only --tmpfs /tmp:exec --tmpfs /var/log \
    --memory=2g --cpus=2 --add-host=host.docker.internal:host-gateway \
    -v "$VOL":/home/dweller -e LLM_MODEL="$MODEL" \
    ${LLM_ENDPOINT:+-e LLM_ENDPOINT="$LLM_ENDPOINT"} \
    homestead "$task" 2>&1); code=$?
  verdict=$(judge "$task" "$out" "$code" "$criteria")
  if printf '%s' "$verdict" | grep -q '^VERDICT: PASS'; then v=PASS; pass=$((pass+1)); else v=FAIL; fail=$((fail+1)); fi
  reason=$(printf '%s' "$verdict" | grep '^REASON:' | sed 's/^REASON: //')
  echo "$name: $v — $reason" | tee -a "$VOL/scoreboard.log"
done

[ -n "$saved_meter" ] && echo "$saved_meter" > "$VOL/.meter"
echo "score: $pass/$((pass+fail)) pass ($skip skipped)" | tee -a "$VOL/scoreboard.log"
