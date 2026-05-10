#!/bin/bash
cid="$1"; tmpdir="$2"; port="$3"

# Give the agent time to initialize its inbox watcher
sleep 15

# Drop a task into the inbox
mkdir -p "$tmpdir/inbox" "$tmpdir/results"
echo "list all files in /etc/ssl and report how many there are" > "$tmpdir/inbox/ssl_check.task"

# Wait up to 120s for the result to appear
for i in $(seq 1 60); do
  if [ -f "$tmpdir/results/ssl_check.result" ]; then
    echo "=== Task delivered ==="
    cat "$tmpdir/inbox/ssl_check.task"
    echo "=== Result received ==="
    cat "$tmpdir/results/ssl_check.result"
    exit 0
  fi
  sleep 2
done

echo "TIMEOUT: no result file appeared after 120s"
exit 1
