#!/bin/bash
cid="$1"; tmpdir="$2"; port="$3"

# Wait for server to accept connections (up to 60s)
for i in $(seq 1 30); do
  if curl -sf -X POST "http://localhost:$port/task" \
    -H "Content-Type: application/json" \
    -d '{"task":"list files in /etc"}' >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

# Send a real task and capture response
curl -s -X POST "http://localhost:$port/task" \
  -H "Content-Type: application/json" \
  -d '{"task":"list files in /etc and count them"}'
