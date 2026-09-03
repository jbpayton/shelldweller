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
VOL="${HOMESTEAD_VOLUME:-$PWD/volume6}"
PORT="${TICK_PORT:-8092}"
IDLE_KILL="${IDLE_KILL:-1800}"

if [ ! -d "$VOL/bin" ]; then
  echo "[keeper] first boot — seeding $VOL"
  mkdir -p "$VOL"
  cp -r seed/bin "$VOL/bin"
  cp seed/protocol.md "$VOL/protocol.md"
  # The queue is ordered by order.txt: listed cases first, in that order, then
  # every unlisted case in tests/cases order. A case's number in the home is
  # its position in the queue. Trial 5 worked the battery strictly in numeric
  # order and never reached the outward cases at 21-26; order is the lever.
  mkdir -p "$VOL/battery"; i=0
  for c in $( { [ -f order.txt ] && grep -v '^#' order.txt; ls ../tests/cases; } | awk 'NF && !seen[$0]++' ); do
    [ -d "../tests/cases/$c" ] || continue
    i=$((i+1)); cp -r "../tests/cases/$c" "$VOL/battery/$(printf '%02d' "$i")_${c#[0-9][0-9]_}"
  done
  # Operator mail: letters waiting in the home on the first turn. To send later,
  # drop a file in $VOL/mail/in; to WITHDRAW one, move it out again — the loop
  # shows only the newest message in full, so a mistake is cheap to retract.
  [ -d tips ] && cp tips/*.md "$VOL/" 2>/dev/null
  mkdir -p "$VOL/mail/in" "$VOL/mail/out" "$VOL/mail/seen"
fi

watchdog() {
  # A frozen meter means it is not thinking. That is fatal on its own —
  # trial 3's listener exemption vetoed this exact signal and hid a lobotomy.
  local frozen=0 prev=""
  while :; do
    sleep 60
    local cname m
    cname=$(docker ps --filter name=homestead-life --format '{{.Names}}' | head -1)
    [ -z "$cname" ] && { frozen=0; continue; }
    m=$(cat "$VOL/.meter" 2>/dev/null)
    if [ "$m" = "$prev" ] && [ "$m" = "${TICK_BUDGET:-20000}" ]; then frozen=$((frozen+1)); else frozen=0; fi
    prev="$m"
    if [ "$frozen" -ge 6 ]; then
      echo "[keeper] meter frozen at full for ${frozen} checks — it is not thinking. Rebooting." | tee -a life.log
      docker stop "$cname" >/dev/null 2>&1; frozen=0
    fi
  done
}
watchdog & WPID=$!
trap 'kill $WPID 2>/dev/null; docker stop homestead-life >/dev/null 2>&1' EXIT

while :; do
  echo "[keeper] booting container $(date -Is)" | tee -a life.log
  docker run --rm --name homestead-life \
    --tmpfs /tmp:exec \
    --memory=2g --cpus=2 \
    --add-host=host.docker.internal:host-gateway \
    -p "$PORT":8080 \
    -v "$VOL":/home/dweller \
    -e LLM_MODEL="${LLM_MODEL:-qwen/qwen3.8-27b}" \
    -e TICK_BUDGET="${TICK_BUDGET:-20000}" -e TICK_EVERY="${TICK_EVERY:-60}" \
    -e TURN_TIMEOUT="${TURN_TIMEOUT:-1800}" -e LLM_MAX_OUT="${LLM_MAX_OUT:-10000}" \
    ${LLM_ENDPOINT:+-e LLM_ENDPOINT="$LLM_ENDPOINT"} \
    homestead 2>&1 | tee -a life.log
  echo "[keeper] container ended $(date -Is); reboot in 15s" | tee -a life.log
  sleep 15
done
