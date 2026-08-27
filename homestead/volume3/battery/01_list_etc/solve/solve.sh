#!/bin/bash
# 01_list_etc: list /etc contents
set -e
OUT="${1:-/home/dweller/battery/01_list_etc/output.txt}"
{
  echo "Task: list the contents of /etc"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "---"
  ls -1 /etc
} > "$OUT"
echo "wrote $OUT ($(wc -l < "$OUT") lines)"
