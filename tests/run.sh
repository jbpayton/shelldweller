#!/bin/bash
# run.sh — test runner. Executes each case via docker, judges output with the LLM.
# Usage: ./run.sh [case_name]   (no arg runs all cases)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CASES_DIR="$SCRIPT_DIR/cases"
MODEL="${LLM_MODEL:-qwen/qwen3.6-35b-a3b}"
TIMEOUT="${SHELLDWELLER_TIMEOUT:-120}"

pass=0; fail=0; error=0

run_case() {
  local case_dir="$1"
  local name
  name=$(basename "$case_dir")
  local task criteria output exit_code verdict

  task=$(cat "$case_dir/task")
  criteria=$(cat "$case_dir/criteria")

  printf '\n=== %s ===\n' "$name"
  printf 'Task: %s\n' "$task"

  output=$(docker run --rm \
    --read-only --tmpfs /tmp --tmpfs /var/log \
    --memory=2g --cpus=2 \
    --stop-timeout="$TIMEOUT" \
    --add-host=host.docker.internal:host-gateway \
    -e LLM_MODEL="$MODEL" \
    shelldweller "$task" 2>&1) && exit_code=0 || exit_code=$?

  printf 'Exit code: %s\n' "$exit_code"
  printf 'Output:\n%s\n' "$output"
  printf -- '---\n'

  verdict=$(bash "$SCRIPT_DIR/judge.sh" "$task" "$output" "$exit_code" "$criteria")
  printf 'Verdict: %s\n' "$verdict"

  if printf '%s' "$verdict" | grep -q '^PASS'; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
  fi
}

if [ $# -gt 0 ]; then
  run_case "$CASES_DIR/$1"
else
  for case_dir in "$CASES_DIR"/*/; do
    run_case "$case_dir" || { error=$((error + 1)); }
  done
fi

printf '\n=== Results: %d passed, %d failed, %d errors ===\n' "$pass" "$fail" "$error"
[ "$fail" -eq 0 ] && [ "$error" -eq 0 ]
