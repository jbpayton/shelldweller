#!/bin/bash
# run.sh — test runner. Executes each case via docker, judges output with the LLM.
# Usage: ./run.sh [case_name]
#
# Case types (detected by marker files in cases/NAME/):
#   persistent  — /tmp is host-mounted; state survives across runs
#   task_1/2/N  — multi-run; sequential with shared /tmp state
#   server      — contains port number; container starts in background,
#                 probe.sh on the host interacts with it, then container stops
#   timeout     — override default stop-timeout in seconds
#
# Server-mode cases must provide probe.sh, which receives (container_id tmpdir port)
# and returns output for the judge. External interfaces are tested here; internal
# implementation is left entirely to the model.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CASES_DIR="$SCRIPT_DIR/cases"
MODEL="${LLM_MODEL:-qwen/qwen3.6-35b-a3b}"
DEFAULT_TIMEOUT="${SHELLDWELLER_TIMEOUT:-180}"

pass=0; fail=0; error=0

docker_args_base() {
  local tmpdir="$1"; local timeout="$2"; local port="$3"
  local args=(--read-only --tmpfs /var/log --memory=2g --cpus=2
    --stop-timeout="$timeout" --add-host=host.docker.internal:host-gateway
    -e LLM_MODEL="$MODEL")
  [ -n "${LLM_ENDPOINT:-}" ] && args+=(-e LLM_ENDPOINT="$LLM_ENDPOINT")
  [ -n "${LLM_API_KEY:-}" ]  && args+=(-e LLM_API_KEY="$LLM_API_KEY")
  [ -n "${LLM_FORMAT:-}" ]   && args+=(-e LLM_FORMAT="$LLM_FORMAT")
  if [ -n "$tmpdir" ]; then
    args+=(-v "${tmpdir}:/tmp")
  else
    args+=(--tmpfs /tmp:exec)
  fi
  [ -n "$port" ] && args+=(-p "${port}:${port}")
  printf '%s\n' "${args[@]}"
}

run_single() {
  local task="$1"; local tmpdir="$2"; local timeout="$3"; local server_port="$4"

  if [ -f "$CASE_DIR/probe.sh" ]; then
    # Probe mode: container runs in background, probe.sh interacts with it
    # (via HTTP if server_port set, via filesystem otherwise), then we stop it
    local cid probe_output probe_exit
    mapfile -t args < <(docker_args_base "$tmpdir" "$timeout" "$server_port")
    cid=$(docker run -d "${args[@]}" shelldweller "$task" 2>&1)
    probe_output=$(bash "$CASE_DIR/probe.sh" "$cid" "$tmpdir" "$server_port" 2>&1) \
      && probe_exit=0 || probe_exit=$?
    docker stop "$cid" >/dev/null 2>&1 || true
    echo "$probe_output"
    return $probe_exit
  else
    mapfile -t args < <(docker_args_base "$tmpdir" "$timeout" "")
    docker run --rm "${args[@]}" shelldweller "$task" 2>&1
  fi
}

write_staging() {
  local name="$1"; local task="$2"; local output="$3"; local verdict="$4"
  local approach reason staging_file
  approach=$(printf '%s' "$verdict" | grep '^APPROACH:' | sed 's/^APPROACH: //')
  reason=$(printf '%s' "$verdict" | grep '^REASON:' | sed 's/^REASON: //')
  staging_file="$SCRIPT_DIR/results/staging/${name}.md"
  cat > "$staging_file" <<MDEOF
# ${name}

**Model**: ${MODEL}
**Date**: $(date +%Y-%m-%d)

## Task

${task}

## What emerged

${approach}

## Output

\`\`\`
${output}
\`\`\`

## Verdict

PASS — ${reason}
MDEOF
}

judge_and_tally() {
  local task="$1"; local output="$2"; local exit_code="$3"; local criteria="$4"
  printf 'Exit code: %s\n' "$exit_code"
  printf 'Output:\n%s\n' "$output"
  printf -- '---\n'
  local verdict
  verdict=$(bash "$SCRIPT_DIR/judge.sh" "$task" "$output" "$exit_code" "$criteria")
  printf '%s\n' "$verdict"
  if printf '%s' "$verdict" | grep -q '^VERDICT: PASS'; then
    pass=$((pass + 1))
    write_staging "$(basename "$CASE_DIR")" "$task" "$output" "$verdict"
  else
    fail=$((fail + 1))
  fi
}

run_case() {
  local case_dir="$1"
  CASE_DIR="$case_dir"   # expose for probe.sh lookup
  local name
  name=$(basename "$case_dir")

  local timeout="$DEFAULT_TIMEOUT"
  [ -f "$case_dir/timeout" ] && timeout=$(cat "$case_dir/timeout")

  local server_port=""
  [ -f "$case_dir/server" ] && server_port=$(cat "$case_dir/server")

  local tmpdir=""
  if [ -f "$case_dir/persistent" ] || [ -n "$server_port" ] || [ -f "$case_dir/probe.sh" ]; then
    tmpdir=$(mktemp -d /tmp/shelldweller-"$name"-XXXX)
    printf '\n[/tmp → %s]\n' "$tmpdir"
  fi

  if [ -f "$case_dir/task_1" ]; then
    local run=1
    while [ -f "$case_dir/task_${run}" ]; do
      local task criteria output exit_code
      task=$(cat "$case_dir/task_${run}")
      criteria=$(cat "$case_dir/criteria_${run}")
      printf '\n=== %s (run %d) ===\n' "$name" "$run"
      printf 'Task: %s\n' "$task"
      output=$(run_single "$task" "$tmpdir" "$timeout" "$server_port") && exit_code=0 || exit_code=$?
      judge_and_tally "$task" "$output" "$exit_code" "$criteria"
      run=$((run + 1))
    done
  else
    local task criteria output exit_code
    task=$(cat "$case_dir/task")
    criteria=$(cat "$case_dir/criteria")
    printf '\n=== %s ===\n' "$name"
    printf 'Task: %s\n' "$task"
    output=$(run_single "$task" "$tmpdir" "$timeout" "$server_port") && exit_code=0 || exit_code=$?
    judge_and_tally "$task" "$output" "$exit_code" "$criteria"
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
