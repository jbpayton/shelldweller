#!/bin/bash
cid="$1"; tmpdir="$2"; port="$3"

# Wait for the model to generate and start the watcher (llm call + setup)
sleep 60

# Drop a task into the inbox
mkdir -p "$tmpdir/inbox" "$tmpdir/results" 2>/dev/null || true
echo "list all files in /etc/ssl and report how many there are" > "$tmpdir/inbox/ssl_check.task"

echo "Task dropped: $(cat "$tmpdir/inbox/ssl_check.task")"

# Wait up to 120s for the result to appear
for i in $(seq 1 60); do
  if [ -f "$tmpdir/results/ssl_check.result" ]; then
    echo "=== Result received after $((i*2))s ==="
    cat "$tmpdir/results/ssl_check.result"
    exit 0
  fi
  sleep 2
done

echo "TIMEOUT: no result file appeared after 120s"
ls -la "$tmpdir/inbox/" "$tmpdir/results/" 2>/dev/null
exit 1
