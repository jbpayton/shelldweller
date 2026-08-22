#!/bin/bash
# run.sh — host-side keeper of one persistent homestead container.
# Boots the container (seeding the home on first boot), publishes the port,
# reboots it if it dies, and declares time of death — rebooting it — when it
# goes catatonic: no tokens spent for IDLE_KILL seconds while nothing answers
# the published port. Container output streams to life.log.
#
#   ./run.sh          run the keeper (foreground; ctrl-c to stop everything)
#
# Knobs: TICK_BUDGET (output tokens per TURN, default 20000), TICK_EVERY
# (seconds between turns, default 60), TURN_TIMEOUT (wall-clock cap per turn,
# default 1800), IDLE_KILL (catatonia threshold, default 1800), TICK_PORT
# (host port for container :8080, default 8090), HOMESTEAD_VOLUME, LLM_MODEL,
# LLM_ENDPOINT.
set -uo pipefail
cd "$(dirname "$0")"
VOL="${HOMESTEAD_VOLUME:-$PWD/volume}"
PORT="${TICK_PORT:-8090}"
IDLE_KILL="${IDLE_KILL:-1800}"

if [ ! -d "$VOL/bin" ]; then
  echo "[keeper] first boot — seeding $VOL"
  mkdir -p "$VOL"
  cp -r seed/bin "$VOL/bin"
  cp seed/protocol.md "$VOL/protocol.md"
  cp -r ../tests/cases "$VOL/battery"
  # Operator mail: letters waiting in the home on the first turn.
  [ -d tips ] && cp tips/*.md "$VOL/" 2>/dev/null
fi

watchdog() {
  local idle=0 prev=""
  while :; do
    sleep 30
    local cname m
    cname=$(docker ps --filter name=homestead-life --format '{{.Names}}' | head -1)
    if [ -z "$cname" ]; then idle=0; continue; fi
    m=$(cat "$VOL/.meter" 2>/dev/null)
    if [ "$m" != "$prev" ] || curl -s -o /dev/null --max-time 2 "http://localhost:$PORT/"; then
      idle=0
    else
      idle=$((idle+30))
    fi
    prev="$m"
    if [ "$idle" -ge "$IDLE_KILL" ]; then
      echo "[keeper] time of death: no tokens spent for ${IDLE_KILL}s and nothing listening — rebooting container" | tee -a life.log
      docker stop "$cname" >/dev/null 2>&1
      idle=0
    fi
  done
}
watchdog & WPID=$!
trap 'kill $WPID 2>/dev/null; docker stop homestead-life >/dev/null 2>&1' EXIT

while :; do
  echo "[keeper] booting container $(date -Is)" | tee -a life.log
  docker run --rm --name homestead-life \
    --read-only --tmpfs /tmp:exec --tmpfs /var/log \
    --memory=2g --cpus=2 \
    --add-host=host.docker.internal:host-gateway \
    -p "$PORT":8080 \
    -v "$VOL":/home/dweller \
    -e LLM_MODEL="${LLM_MODEL:-qwen/qwen3.8-27b}" \
    -e TICK_BUDGET="${TICK_BUDGET:-20000}" -e TICK_EVERY="${TICK_EVERY:-60}" \
    -e TURN_TIMEOUT="${TURN_TIMEOUT:-1800}" \
    ${LLM_ENDPOINT:+-e LLM_ENDPOINT="$LLM_ENDPOINT"} \
    homestead 2>&1 | tee -a life.log
  echo "[keeper] container ended $(date -Is); reboot in 15s" | tee -a life.log
  sleep 15
done
