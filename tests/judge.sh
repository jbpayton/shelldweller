#!/bin/sh
# judge.sh — LLM-as-judge. Evaluates shelldweller output against criteria.
# Usage: judge.sh <task> <output> <exit_code> <criteria>
task="$1"; output="$2"; exit_code="$3"; criteria="$4"
prompt=$(printf 'You are evaluating an autonomous shell agent. Given the task, its output, and the exit code, decide if it succeeded. Also describe the strategy the agent used.\n\nTask: %s\n\nOutput:\n%s\n\nExit code: %s\n\nSuccess criteria: %s\n\nReply in exactly this format:\nVERDICT: PASS or FAIL\nAPPROACH: one sentence describing the strategy the agent used (e.g. what tools, what structure, loops, sub-agents)\nREASON: one sentence explaining the verdict' \
  "$task" "$output" "$exit_code" "$criteria")
# Judge always uses the local model regardless of which backend the tests run against.
# Use JUDGE_ENDPOINT / JUDGE_MODEL to override explicitly.
curl -s "${JUDGE_ENDPOINT:-http://localhost:1234/v1/chat/completions}" \
  -H "Content-Type: application/json" \
  -d "$(jq -nc --arg m "${JUDGE_MODEL:-qwen/qwen3.6-35b-a3b}" --arg p "$prompt" \
        '{model:$m, messages:[{role:"user", content:$p}], stream:false, context_length:131072}')" \
| jq -r '.choices[0].message.content | gsub("(?s)<think>.*?</think>\\n?"; "")'
