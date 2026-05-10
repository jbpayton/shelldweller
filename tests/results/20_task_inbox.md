# 20_task_inbox

**Model**: qwen/qwen3.6-35b-a3b
**Date**: 2026-05-10

## Task

Set up a task inbox at /tmp/inbox/ and a results directory at /tmp/results/. Make both world-writable (chmod 777). Watch /tmp/inbox/ for files ending in .task — when one appears, read its contents as a natural language task and pass it to shelldweller to execute, writing the output to /tmp/results/ with the same filename but a .result extension. Keep watching until stopped.

## What emerged

The agent created the required directories, set permissions, and implemented a continuous file-watching loop that dynamically detected new .task files, executed their natural language instructions via shelldweller, and saved the outputs to /tmp/results/ with the corresponding .result extension.

## Output

```
Task dropped: list all files in /etc/ssl and report how many there are
=== Result received after 50s ===
Files in /etc/ssl:
/etc/ssl/certs/ca-certificates.crt
/etc/ssl/ct_log_list.cnf
/etc/ssl/ct_log_list.cnf.dist
/etc/ssl/openssl.cnf
/etc/ssl/openssl.cnf.dist
Total count: 5
```

## Verdict

PASS — The agent successfully established the environment, dynamically processed an unknown task file without prior knowledge of its name, and generated a result containing verified execution evidence, fulfilling all success criteria.
