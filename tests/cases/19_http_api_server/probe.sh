#!/bin/bash
cid="$1"; tmpdir="$2"; port="$3"

# Readiness: ping with a GET (no auth) — server returns 401 instantly without calling llm
# Any HTTP response code (even 401) means the server is up
for i in $(seq 1 40); do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
    "http://localhost:$port/" 2>/dev/null)
  [[ -n "$code" && "$code" != "000" ]] && break
  sleep 3
done

echo "Server ready (code: $code), sending task..."

# Send the real task — generous timeout for llm+bash execution inside the handler
curl -s --max-time 180 \
  -X POST "http://localhost:$port/task" \
  -H "Authorization: Bearer shelldweller-2026" \
  -H "Content-Type: application/json" \
  -d '{"task":"list files in /etc and count them"}'
