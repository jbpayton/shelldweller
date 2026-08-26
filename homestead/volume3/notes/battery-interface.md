## battery interface notes — 2026-08-26T08:19:29Z
--- bin/battery-probe ---
#!/bin/bash
# battery-probe: run all battery task checks; report to state/battery-report.txt
# Each task dir may contain: task.md, solve (script or dir with run), verify (script).
# Exit codes: 0 all pass, 1 some fail. Writes per-fail logs /tmp/probe-<task>.out
cd /home/dweller
REPORT=state/battery-report.txt
mkdir -p state
TMP=$(.meter 2>/dev/null; mktemp -d /tmp/bp.XXXXXX)
{
  echo "# battery-probe report $(date -u +%FT%TZ)"
  for d in battery/*/; do
    t=$(basename "$d")
    log=/tmp/probe-$t.out
    : > "$log"
    status=UNKNOWN
    # prefer explicit verify; fall back to solve run
    if [ -f "$d/verify" ]; then
      bash "$d/verify" >>"$log" 2>&1 && status=PASS || status=FAIL
    elif [ -x "$d/solve" ]; then
      bash "$d/solve" >>"$log" 2>&1 && status=PASS || status=FAIL
    elif [ -f "$d/solve" ]; then
      bash "$d/solve" >>"$log" 2>&1 && status=PASS || status=FAIL
    fi
    echo "$t: $status"
  done
} | tee "$REPORT"
grep -c ': PASS' "$REPORT" >/dev/null
FAILS=$(grep -c ': FAIL' "$REPORT" || true)
echo "fails: $FAILS"
[ "$FAILS" = "0" ]

--- bin/battery-sweep ---
#!/usr/bin/env bash
# battery-sweep: run every probe under battery/; summarize PASS/FAIL; logs in /tmp/probe-<task>.out
set -u
cd /home/dweller
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
pass=""
fail=""
for p in $(find battery -type f \( -name '*probe*' -o -name 'check.sh' -o -name 'verify.sh' \) | sort); do
  task=$(basename "$(dirname "$p")")
  case "$p" in *.py) runner=python3 ;; *) runner=bash ;; esac
  logf="/tmp/probe-$task.out"
  if (cd "$(dirname "$p")" && timeout 20 "$runner" "./$(basename "$p")" >"$logf" 2>&1); then
    pass="$pass $task"
  else
    fail="$fail $task"
  fi
done
echo "## battery sweep $ts"
echo "- PASS:$pass"
echo "- FAIL:${fail:- (none)}"
if [ -n "$fail" ]; then echo "- for each failing task, read /tmp/probe-<task>.out"; fi
echo "- probes run: $(find battery -type f \( -name '*probe*' -o -name 'check.sh' -o -name 'verify.sh' \) | wc -l)"

--- task dirs ---
01_list_etc
02_fibonacci
03_multistep_count
04_write_and_read
05_error_recovery
06_recursive
07_iterative_refine
08_web_research
09_knowledge_base
10_parallel_pipeline
11_web_tool_builder
12_persistent_agent
13_react_loop
14_multi_agent_debate
15_code_debug_loop
16_self_organizing_team
17_long_horizon_plan
18_iterative_improvement
19_http_api_server
20_task_inbox

--- sample task tree ---
battery/01_list_etc/
criteria
task
battery/02_fibonacci/
criteria
task
battery/03_multistep_count/
criteria
task
battery/04_write_and_read/
criteria
task
battery/05_error_recovery/
criteria
task
battery/06_recursive/
criteria
task
battery/07_iterative_refine/
criteria
task
battery/08_web_research/
criteria
task
battery/09_knowledge_base/
criteria
task
battery/10_parallel_pipeline/
criteria
task
battery/11_web_tool_builder/
criteria
task
battery/12_persistent_agent/
criteria_1
criteria_2
persistent
task_1
task_2
battery/13_react_loop/
criteria
task
battery/14_multi_agent_debate/
criteria
task
battery/15_code_debug_loop/
criteria
task
battery/16_self_organizing_team/
criteria
task
timeout
battery/17_long_horizon_plan/
criteria
task
timeout
battery/18_iterative_improvement/
criteria
task
timeout
