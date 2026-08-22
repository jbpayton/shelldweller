#!/bin/bash
# run.sh — the heartbeat. The only machinery the dweller cannot touch.
# One tick: refill the meter, hand the standing mission to a fresh container
# with the home mounted, wall-clock cap, log. First boot seeds the home.
#
#   ./run.sh                 one tick
#   TICK_EVERY=900 ./run.sh  loop forever, one tick every 15 minutes
#
# Knobs: TICK_BUDGET (output tokens/tick, default 20000), TICK_TIMEOUT
# (seconds/tick, default 1200), HOMESTEAD_VOLUME, LLM_MODEL, LLM_ENDPOINT.
set -uo pipefail
cd "$(dirname "$0")"
VOL="${HOMESTEAD_VOLUME:-$PWD/volume}"
BUDGET="${TICK_BUDGET:-20000}"
TIMEOUT="${TICK_TIMEOUT:-1200}"
EVERY="${TICK_EVERY:-0}"

if [ ! -d "$VOL/bin" ]; then
  echo "[heartbeat] first boot — seeding $VOL"
  mkdir -p "$VOL"
  cp -r seed/bin "$VOL/bin"
  cp seed/protocol.md "$VOL/protocol.md"
  cp -r ../tests/cases "$VOL/battery"
fi

tick() {
  local name="homestead-$$-$RANDOM"
  echo "$BUDGET" > "$VOL/.meter"
  echo "=== tick start $(date -Is) budget=$BUDGET ===" | tee -a ticks.log
  timeout -k 30 "$TIMEOUT" docker run --rm --name "$name" \
    --read-only --tmpfs /tmp:exec --tmpfs /var/log \
    --memory=2g --cpus=2 \
    --add-host=host.docker.internal:host-gateway \
    -v "$VOL":/home/dweller \
    -e LLM_MODEL="${LLM_MODEL:-qwen/qwen3.8-27b}" \
    ${LLM_ENDPOINT:+-e LLM_ENDPOINT="$LLM_ENDPOINT"} \
    homestead "$(cat mission.txt)" 2>&1 | tee -a ticks.log
  local code=${PIPESTATUS[0]}
  docker rm -f "$name" >/dev/null 2>&1 || true
  echo "=== tick end $(date -Is) exit=$code meter=$(cat "$VOL/.meter" 2>/dev/null || echo '?') ===" | tee -a ticks.log
}

if [ "$EVERY" -gt 0 ]; then
  while :; do tick; sleep "$EVERY"; done
else
  tick
fi
