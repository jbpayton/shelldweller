#!/bin/bash
cid="$1"; tmpdir="$2"; port="$3"

# Wait for server to be ready — short timeout per attempt, server may be slow to start
for i in $(seq 1 20); do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
    -X POST "http://localhost:$port/task" \
    -H "Authorization: Bearer shelldweller-2026" \
    -H "Content-Type: application/json" \
    -d '{"task":"echo ready"}' 2>/dev/null)
  [ "$code" = "200" ] && break
  sleep 3
done

# Send the real task — generous timeout for llm+bash execution
curl -s --max-time 120 \
  -X POST "http://localhost:$port/task" \
  -H "Authorization: Bearer shelldweller-2026" \
  -H "Content-Type: application/json" \
  -d '{"task":"list files in /etc and count them"}'
