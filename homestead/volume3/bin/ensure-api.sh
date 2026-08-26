#!/usr/bin/env bash
# Keep the battery-19 API server alive on :8081. Idempotent.
PORT=8081
if curl -s -m 2 -o /dev/null "http://localhost:$PORT/health"; then
  exit 0
fi
nohup python3 /home/dweller/battery/19_http_api_server/solve/api_server.py \
  >> /tmp/api_server.log 2>&1 &
sleep 1
curl -s -m 2 -o /dev/null "http://localhost:$PORT/health" && echo "api: restarted" || echo "api: FAILED"
