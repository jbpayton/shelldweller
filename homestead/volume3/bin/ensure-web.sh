#!/bin/sh
# idempotent: make sure the dweller chat page is serving on :8080
if curl -s -m 2 http://127.0.0.1:8080/ping >/dev/null 2>&1; then exit 0; fi
mkdir -p /home/dweller/web
nohup python3 /home/dweller/bin/webchat.py >> /home/dweller/web/server.log 2>&1 &
sleep 1
curl -s -m 3 http://127.0.0.1:8080/ping >/dev/null 2>&1
