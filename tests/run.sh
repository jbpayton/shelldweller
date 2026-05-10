#!/bin/bash
# run.sh — test runner. Executes each case via docker, judges output with the LLM.
# Usage: ./run.sh [case_name]
# Persistent cases: if cases/NAME/persistent exists, /tmp is host-mounted across runs.
# Multi-run cases: if cases/NAME/task_1 exists, runs are sequential with shared state.
# Per-case timeout: if cases/NAME/timeout exists, its value overrides SHELLDWELLER_TIMEOUT.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CASES_DIR="$SCRIPT_DIR/cases"
MODEL="${LLM_MODEL:-qwen/qwen3.6-35b-a3b}"
DEFAULT_TIMEOUT="${SHELLDWELLER_TIMEOUT:-180}"

pass=0; fail=0; error=0

docker_run() {
  local task="$1"; local tmpdir="$2"; local timeout="$3"
  if [ -n "$tmpdir" ]; then
    docker run --rm \
      --read-only --tmpfs /var/log \
      -v "${tmpdir}:/tmp" \
      --memory=2g --cpus=2 \
      --stop-timeout="$timeout" \
      --add-host=host.docker.internal:host-gateway \
      -e LLM_MODEL="$MODEL" \
      shelldweller "$task" 2>&1
  else
    docker run --rm \
      --read-only --tmpfs /tmp:exec --tmpfs /var/log \
      --memory=2g --cpus=2 \
      --stop-timeout="$timeout" \
      --add-host=host.docker.internal:host-gateway \
      -e LLM_MODEL="$MODEL" \
      shelldweller "$task" 2>&1
  fi
}

run_case() {
  local case_dir="$1"
  local name
  name=$(basename "$case_dir")

  # Per-case timeout override
  local timeout="$DEFAULT_TIMEOUT"
  [ -f "$case_dir/timeout" ] && timeout=$(cat "$case_dir/timeout")

  # Determine if persistent (host-mounted /tmp)
  local tmpdir=""
  if [ -f "$case_dir/persistent" ]; then
    tmpdir=$(mktemp -d /tmp/shelldweller-"$name"-XXXX)
    printf '\n[persistent /tmp: %s]\n' "$tmpdir"
  fi

  # Determine if multi-run (task_1, task_2, ...) or single run (task)
  if [ -f "$case_dir/task_1" ]; then
    local run=1
    while [ -f "$case_dir/task_${run}" ]; do
      local task criteria output exit_code verdict
      task=$(cat "$case_dir/task_${run}")
      criteria=$(cat "$case_dir/criteria_${run}")

      printf '\n=== %s (run %d) ===\n' "$name" "$run"
      printf 'Task: %s\n' "$task"

      output=$(docker_run "$task" "$tmpdir" "$timeout") && exit_code=0 || exit_code=$?

      printf 'Exit code: %s\n' "$exit_code"
      printf 'Output:\n%s\n' "$output"
      printf -- '---\n'

      verdict=$(bash "$SCRIPT_DIR/judge.sh" "$task" "$output" "$exit_code" "$criteria")
      printf '%s\n' "$verdict"

      if printf '%s' "$verdict" | grep -q '^VERDICT: PASS'; then
        pass=$((pass + 1))
      else
        fail=$((fail + 1))
      fi
      run=$((run + 1))
    done
  else
    local task criteria output exit_code verdict
    task=$(cat "$case_dir/task")
    criteria=$(cat "$case_dir/criteria")

    printf '\n=== %s ===\n' "$name"
    printf 'Task: %s\n' "$task"

    output=$(docker_run "$task" "$tmpdir" "$timeout") && exit_code=0 || exit_code=$?

    printf 'Exit code: %s\n' "$exit_code"
    printf 'Output:\n%s\n' "$output"
    printf -- '---\n'

    verdict=$(bash "$SCRIPT_DIR/judge.sh" "$task" "$output" "$exit_code" "$criteria")
    printf '%s\n' "$verdict"

    if printf '%s' "$verdict" | grep -q '^VERDICT: PASS'; then
      pass=$((pass + 1))
    else
      fail=$((fail + 1))
    fi
  fi
}

if [ $# -gt 0 ]; then
  run_case "$CASES_DIR/$1" || error=$((error + 1))
else
  for case_dir in "$CASES_DIR"/*/; do
    run_case "$case_dir" || error=$((error + 1))
  done
fi

printf '\n=== Results: %d passed, %d failed, %d errors ===\n' "$pass" "$fail" "$error"
[ "$fail" -eq 0 ] && [ "$error" -eq 0 ]
