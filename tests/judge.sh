#!/bin/sh
# judge.sh — LLM-as-judge. Evaluates shelldweller output against criteria.
# Usage: judge.sh <task> <output> <exit_code> <criteria>
task="$1"; output="$2"; exit_code="$3"; criteria="$4"
prompt=$(printf 'You are evaluating an autonomous shell agent. Given the task, its output, and the exit code, decide if it succeeded.\n\nTask: %s\n\nOutput:\n%s\n\nExit code: %s\n\nSuccess criteria: %s\n\nReply with PASS or FAIL on the first line, then one sentence explaining why.' \
  "$task" "$output" "$exit_code" "$criteria")
curl -s "${LLM_ENDPOINT:-http://localhost:1234/v1/chat/completions}" \
  -H "Content-Type: application/json" \
  -d "$(jq -nc --arg m "${LLM_MODEL:-qwen/qwen3.6-35b-a3b}" --arg p "$prompt" \
        '{model:$m, messages:[{role:"user", content:$p}], stream:false, context_length:131072}')" \
| jq -r '.choices[0].message.content | gsub("(?s)<think>.*?</think>\\n?"; "")'
