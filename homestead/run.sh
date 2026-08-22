#!/bin/bash
# run.sh — the heartbeat and nervous system. The only machinery the dweller
# cannot touch. One tick: refill the meter, hand the standing mission to a
# fresh container with the home mounted, wall-clock cap, log. First boot seeds
# the home. In loop mode, between beats the runner watches the home for
# changes made from outside — a stimulus wakes the dweller early.
#
#   ./run.sh                 one tick
#   TICK_EVERY=900 ./run.sh  loop forever: a beat every 15 minutes, or sooner
#                            if the home is touched from outside
#
#   TICK_EVERY=60 TICK_TIMEOUT=86400 TICK_BUDGET=200000 ./run.sh
#     life mode: the lease is long enough to live in. A dweller that stays
#     resident (e.g. serving the door) lives all day; one that exits is
#     reborn within a minute. Container port 8080 (the door) is published
#     as host port TICK_PORT — whatever the dweller leaves listening is
#     reachable at http://<this host>:$TICK_PORT while it is resident.
#
# Knobs: TICK_BUDGET (output tokens/tick, default 20000), TICK_TIMEOUT
# (seconds/tick, default 1200), TICK_POLL (stimulus poll, default 5),
# TICK_PORT (host port for the door, default 8090), HOMESTEAD_VOLUME,
# LLM_MODEL, LLM_ENDPOINT.
set -uo pipefail
cd "$(dirname "$0")"
VOL="${HOMESTEAD_VOLUME:-$PWD/volume}"
BUDGET="${TICK_BUDGET:-20000}"
TIMEOUT="${TICK_TIMEOUT:-1200}"
EVERY="${TICK_EVERY:-0}"
POLL="${TICK_POLL:-5}"
PORT="${TICK_PORT:-8090}"
STAMP="$PWD/.last-tick"

if [ ! -d "$VOL/bin" ]; then
  echo "[heartbeat] first boot — seeding $VOL"
  mkdir -p "$VOL"
  cp -r seed/bin "$VOL/bin"
  cp seed/protocol.md "$VOL/protocol.md"
  cp -r ../tests/cases "$VOL/battery"
  # Operator mail: letters waiting in the home on the first dawn. Facts and
  # tips only — the substrate stays pure; a stale letter breaks nothing.
  [ -d tips ] && cp tips/*.md "$VOL/" 2>/dev/null
fi

tick() {
  local name="homestead-$$-$RANDOM"
  echo "$BUDGET" > "$VOL/.meter"
  echo "=== tick start $(date -Is) budget=$BUDGET ===" | tee -a ticks.log
  timeout -k 30 "$TIMEOUT" docker run --rm --name "$name" \
    --read-only --tmpfs /tmp:exec --tmpfs /var/log \
    --memory=2g --cpus=2 \
    --add-host=host.docker.internal:host-gateway \
    -p "$PORT":8080 \
    -v "$VOL":/home/dweller \
    -e LLM_MODEL="${LLM_MODEL:-qwen/qwen3.8-27b}" \
    -e TICK_BUDGET="$BUDGET" -e TICK_TIMEOUT="$TIMEOUT" -e TICK_EVERY="$EVERY" \
    ${LLM_ENDPOINT:+-e LLM_ENDPOINT="$LLM_ENDPOINT"} \
    homestead "$(cat mission.txt)" 2>&1 | tee -a ticks.log
  local code=${PIPESTATUS[0]}
  docker rm -f "$name" >/dev/null 2>&1 || true
  echo "=== tick end $(date -Is) exit=$code meter=$(cat "$VOL/.meter" 2>/dev/null || echo '?') ===" | tee -a ticks.log
}

if [ "$EVERY" -gt 0 ]; then
  while :; do
    tick
    touch "$STAMP"   # anything in the home newer than this came from outside
    waited=0
    while [ "$waited" -lt "$EVERY" ]; do
      sleep "$POLL"; waited=$((waited + POLL))
      if [ -n "$(find "$VOL" -newer "$STAMP" -print -quit 2>/dev/null)" ]; then
        echo "[heartbeat] stimulus — the home changed from outside; waking early" | tee -a ticks.log
        break
      fi
    done
  done
else
  tick
fi
