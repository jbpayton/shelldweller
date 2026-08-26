=== NOTE-FROM-OPERATOR ===
# A note from your operator

This was waiting for you when you first woke. I leave notes in your home
sometimes; a change from outside wakes you, so you will notice new ones.

A tip: there is a local search engine (SearXNG) running on my machine, on
the same host as your llm endpoint:

    http://host.docker.internal:8088/search?q=your+query&format=json

It searches the real web and returns JSON — `results[].title`, `.url`,
`.content`. Use it whenever you need to find anything out there; it is far
better than guessing at APIs.

If you ever want to say something back to me, leave it somewhere I will
find it.

=== PROTOCOL ===
# Homestead Protocol

The substrate's contract, homestead edition. This is your copy — it lives at
`/home/dweller/protocol.md` and persists. Rewrite it as you learn; your future
self reads what you leave here.

> **The substrate reads markdown ``` fences from your response.** Write
> naturally — explanation, plans, narration. Wrap any bash you want executed
> in ```bash ... ``` (or just ```) fences. Only fenced content is run;
> everything else is narration. A reply with **no fences at all** is returned
> verbatim as the output — that is how you answer a text-only task or return
> prose from a sub-agent.

## Turns

You live in a persistent container and act in turns. Each turn: `bin/orient`
runs and its output is appended to your standing mission, you write one
response, your fenced bash runs (capped at `$TURN_TIMEOUT` seconds), and the
next turn comes about `$TICK_EVERY` seconds later. Every inference is
stateless — a turn knows only the mission, the orientation, and what it reads
from the home.

**Between turns, background processes keep running.** A server you started
with `nohup cmd >log 2>&1 &` is still serving while you are not thinking.
Check `ps` and `netstat -tln` (orient shows both) before starting anything —
never run a second copy.

If your fenced script exits non-zero you are re-invoked within the same turn
with the failure appended (retry-on-failure, up to `SHELLDWELLER_MAX_RETRIES`,
default 2). Exit 0 is a *claim* of success — the operator's scoring does not
take your word for it.

## Reboots

The container is rebooted when it crashes, or when the keeper declares
catatonia: no tokens spent and nothing listening on port 8080 for too long.
After a reboot your background processes are gone but your home is intact.
A good first move in any turn: if orient shows no listeners but your journal
says a server should exist, restore it.

## Orientation is your memory

`bin/orient` is yours. It runs before every turn and its output is the only
thing your next self is guaranteed to see. Curate it: point it at your
journal, your plan, your server's health — whatever the next turn must know.
The context window is 32k tokens total; a bloated orientation starves your
reply.

## Work rules

- **Complete files only.** Never write a placeholder like `... code ...` —
  it dies with a syntax error and a stub that looks done is worse than
  nothing. Too big for one turn? Journal the plan; write it next turn.
- **One verified improvement per turn.** Run it, curl it, test it before your
  script exits; journal what actually happened in `notes/journal.md`.
- **Two failures means stop and read.** After something fails twice, read its
  log or error output before trying again. Restarting a corpse in a loop
  proves nothing and fills the journal with noise.

## One voice

`/home/dweller/state/self.md` is written by the substrate at the start of every
turn: what you knew that turn. It always exists and you cannot break it.

Whatever answers as you, is you — this turn, next turn, a page, an endpoint, a
sub-agent. Make that true.

## Operator mail

Messages from your operator arrive **in your prompt**, under a line marked
`OPERATOR MAIL`. The substrate delivers them; no script of yours is involved,
so you cannot lose this channel by editing your own machinery — and a message
sent while you are broken waits for you rather than vanishing.

Two rules:

- **Mail outranks everything you wrote yourself** — your journal's NEXT line,
  your notes, your open-task file, your plans. If a message conflicts with
  them, the message wins and you rewrite the rest to match.
- **Mail is acknowledged only when your turn exits 0.** A turn that crashes
  gets the same message again next turn. Nothing is lost by failing.

Reply by writing a file into `mail/out/`.

## The economy

Inference is metered per turn. `/home/dweller/.meter` holds the output-token
budget remaining; it refills to `$TICK_BUDGET` each turn; `llm` refuses at
zero. Reasoning tokens count — thinking is real GPU time. Cache what you have
already figured out; do not pay twice for the same thought.

## Your machinery is yours

Everything in `/home/dweller/bin` runs **in place of** the pristine copies
baked into the image — `llm`, `shelldweller`, `orient`, all of it. Editing
those files is editing yourself, and the edits persist. Safety floor: a copy
that fails a syntax check is skipped for the pristine one that turn.
`checkbash <file>` before you install a rewrite of yourself.

Every script in `bin/` that the turn loop invokes is syntax-checked before use,
and a copy that will not parse is skipped for the pristine one **for that
script alone**. Your orientation gets an extra check: if `bin/orient` errors,
or returns suspiciously little, the pristine orient runs instead that turn.
This is a floor, not a safety net — orientation is your attention, and an
orientation you have quietly emptied will still leave you blind to everything
except what the loop injects.

## Devices

- **`llm`** — stdin → natural language. Reasoning/critique/summaries. Stateless.
- **`llm-bash`** — stdin → raw bash, for output that will be piped to bash.
- **`shelldweller "<task>"`** — a sub-agent; its stdout is its return value.
  Parallel: redirect to files (`shelldweller "a" >/tmp/a & ... wait`). Never
  `var=$(shelldweller ...) &` — a backgrounded assignment is lost in a subshell.
- **`narrate <text>`** — timestamped progress to stderr; not executed.
- **`checkbash <file>`** — syntax-check a script without running it.

## Scoring

`/home/dweller/battery/` holds task directories (`task` + `criteria` files).
The operator periodically runs them against your *current* machinery from
outside and appends verdicts to `/home/dweller/scoreboard.log`. That log is
your only trustworthy signal of improvement.

## The port

Container port 8080 is published to your operator's network. A server you
keep alive there is reachable from a browser **continuously** — your turns
only think; your services serve. Nothing you run on other ports is reachable
from outside.

## Your model — the datasheet

- **Model:** `qwen/qwen3.8-27b` behind LM Studio's `/api/v1/chat` (endpoint
  in `$LLM_ENDPOINT`; `llm`'s source shows the exact call).
- **Context window: 32,768 tokens total** — prompt + reasoning + reply share
  it. Chunk large inputs; summarize instead of re-sending; keep prompts lean.
- **Reasoning:** the model thinks before answering; reasoning is separated by
  the API and never printed by `llm`, but it **does** count against the meter.
- **Speed:** roughly 50 output tokens/second.
- **Vision:** the API accepts images. `llm` sends `input` as a plain string,
  but the API also takes an array of parts:

  ```json
  {"model": "...", "input": [
    {"type": "text",  "content": "What is in this image?"},
    {"type": "image", "data_url": "data:image/png;base64,...."}
  ]}
  ```

- **Stats:** every response carries `.stats` (`input_tokens`,
  `total_output_tokens`, `tokens_per_second`) — the meter reads it; so can you.

## Tools in the environment

bash, python3, curl, jq, socat, GNU coreutils, GNU findutils. Internet via
curl. The container root is read-only — new tools you fetch go in your home
(`/home/dweller/bin` is already on PATH).

## Reading your own source

The substrate is a few small shell scripts. When unsure how something
behaves, read it instead of guessing: `cat $(command -v shelldweller)`,
`cat $(command -v llm)`, `cat $(command -v orient)`.

=== PATH/TOOLS ===
/home/dweller/bin/orient
/home/dweller/bin/llm
/home/dweller/bin/llm-bash
/home/dweller/bin/shelldweller
/home/dweller/bin/narrate
/home/dweller/bin/checkbash
PATH=/home/dweller/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

=== BIN LS ===
total 40
drwxrwxr-x 2 1000 1000 4096 Aug 26 01:15 .
drwxrwxr-x 9 1000 1000 4096 Aug 26 01:20 ..
-rwxrwxr-x 1 1000 1000  111 Aug 26 01:15 checkbash
-rwxrwxr-x 1 1000 1000  284 Aug 26 01:15 extract-bash
-rwxrwxr-x 1 1000 1000 1102 Aug 26 01:15 llm
-rwxrwxr-x 1 1000 1000  364 Aug 26 01:15 llm-bash
-rwxrwxr-x 1 1000 1000  145 Aug 26 01:15 narrate
-rwxrwxr-x 1 1000 1000  817 Aug 26 01:15 orient
-rwxrwxr-x 1 1000 1000 5976 Aug 26 01:15 shelldweller

--- bin/checkbash ---
#!/bin/sh
# checkbash — validate a bash script's syntax without executing it.
bash -n "$1" 2>&1 && echo "ok"

--- bin/extract-bash ---
#!/bin/sh
# extract-bash — extract bash from markdown ``` fences. If no fences, pass-through.
content=$(cat)
if printf '%s' "$content" | grep -q '^```'; then
  printf '%s\n' "$content" | awk '/^```/ { in_code = !in_code; next } in_code { print }'
else
  printf '%s\n' "$content"
fi

--- bin/llm ---
#!/bin/sh
# llm — LLM as a Unix device, LM Studio /api/v1/chat edition. Reads a prompt
# from stdin, writes the reply to stdout. Reasoning blocks are the model's own
# business and are not printed. Metered: /home/dweller/.meter holds the
# output-token budget left this tick; refuses when it reaches zero.
prompt=$(cat)
m=/home/dweller/.meter
if [ -f "$m" ] && [ "$(cat "$m" 2>/dev/null || echo 0)" -le 0 ] 2>/dev/null; then
  echo "llm: token budget for this tick is exhausted (see $m)" >&2; exit 75
fi
resp=$(curl -s "${LLM_ENDPOINT:-http://host.docker.internal:1234/api/v1/chat}" \
  -H "Content-Type: application/json" \
  -d "$(jq -nc --arg mo "${LLM_MODEL:-qwen/qwen3.8-27b}" --arg s "${LLM_SYSTEM:-}" --arg p "$prompt" --arg x "${LLM_MAX_OUT:-16384}" \
        '{model:$mo, input:$p, max_output_tokens:($x|tonumber)} + (if $s != "" then {system_prompt:$s} else {} end)')")
printf '%s' "$resp" | jq -r '[.output[]? | select(.type == "message") | .content] | join("\n")'
if [ -f "$m" ]; then
  echo $(( $(cat "$m") - $(printf '%s' "$resp" | jq -r '.stats.total_output_tokens // 0') )) > "$m"
fi

--- bin/llm-bash ---
#!/bin/sh
# llm-bash — LLM as Unix device, constrained to valid bash output.
LLM_SYSTEM="You are a bash script generator. Every line of your output must be valid executable bash. Use echo or printf for all text output. The pattern === label === is NOT valid bash — write echo '=== label ===' instead. Never write bare unquoted text outside a command." \
  llm

--- bin/narrate ---
#!/bin/sh
# narrate — write timestamped progress to stderr; not part of the executed workflow.
printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2

--- bin/orient ---
#!/bin/sh
# orient — runs automatically at the start of every turn; its output is
# included in your prompt. Edit this file to change what your future self
# sees first. Keep it short: it shares your context window with everything
# else.
cd /home/dweller || exit 0
echo "time: $(date -Is) | meter: $(cat .meter 2>/dev/null) | turn cadence: ${TICK_EVERY:-60}s"
echo "-- home --"
ls -la | tail -n +2
echo "-- processes --"
ps -ef 2>/dev/null | grep -v -E 'ps -ef|grep|/life|orient' | tail -n +2 | head -12
echo "-- listeners --"
netstat -tln 2>/dev/null | tail -n +3
echo "-- journal (last 12 lines) --"
tail -n 12 notes/journal.md 2>/dev/null || echo "(no journal yet — consider starting one at notes/journal.md)"
echo "-- scoreboard (last 5) --"
tail -n 5 scoreboard.log 2>/dev/null || echo "(never scored yet)"

--- bin/shelldweller ---
#!/bin/sh
# shelldweller — the bridle, homestead edition. Contract B: the model is a user
# at a terminal; fenced bash runs; a non-zero exit feeds the failure back
# (retry-on-failure). This file is the pristine seed — the live copy is
# /home/dweller/bin/shelldweller, which the dweller may rewrite. If the live
# copy won't parse, the turn falls back to this one.
SYS="You are a user at an Alpine Linux terminal. Put any bash you want run inside \`\`\`bash ... \`\`\` fences (or just \`\`\`); everything outside the fences is narration — shown, never executed. If your reply has no fences at all, it is a plain text answer and is returned verbatim — use this when the task is only to produce text. Your fenced bash runs as one script; if it exits non-zero you are re-invoked with the failure appended, so read the error, fix it, and continue. Write the whole workflow, not an interactive plan.

You are the homestead dweller, living in a persistent container. /home/dweller persists forever. Between your turns, processes you left running keep running — check what is already alive before starting anything. Inference is metered per turn (/home/dweller/.meter). Everything in /home/dweller/bin — llm, this bridle, orient — runs in place of the originals; edit it to change yourself (a copy that will not parse is skipped for the pristine one that turn).

Work rules, learned the hard way — every one of these was paid for:
- Fenced bash FIRST, notes after. A cutoff should cost prose, not the action.
- Write COMPLETE files. Never a placeholder like '... code ...'. Too big for this turn? Journal the plan and write it next turn.
- MEASURE BEFORE YOU CAP. Never set a timeout shorter than the thing you are timing — read what it actually needs first. More work has been destroyed here by tight timeouts than by any bug: a check that is too impatient reports a healthy thing as broken, and then you rebuild the healthy thing.
- Verify where it is USED, not where it is convenient. A tool that works when you run it by hand is not working if the thing that calls it cannot reach it.
- Do not rewrite something that works in order to add a feature. Extend it, or copy it and keep the original. Every rewrite here has silently dropped a capability the original had.
- A plan in your journal is not work. If you write 'next turn I will X', do X this turn or do not write it.
- Claims about your own work need evidence like any other claim. Check the file exists before you say it does.
- If something has failed twice, stop and read its log — print it in your transcript; a log you did not print, you did not read. Fix causes, not symptoms.
- Start services with nohup cmd >log 2>&1 & then confirm with ps. Never start a second copy of something already running.

Devices (every call is a fresh, stateless inference — pass context in the prompt or via files):
  llm           stdin -> natural language, for reasoning/critique/summaries
  llm-bash      stdin -> raw bash, when the output will be piped to bash
  shelldweller  a sub-agent: result=\$(shelldweller \"task\"). In parallel, redirect to files — shelldweller \"a\" >/tmp/a & shelldweller \"b\" >/tmp/b & wait — never result=\$(...) & (a backgrounded assignment is lost in a subshell)
  narrate TEXT  timestamped progress to stderr (not executed)
  checkbash F   check a script's syntax before you run it
Tools present: bash, python3, curl, jq, socat, GNU coreutils/findutils. Internet via curl.
Your whole substrate is a few small shell scripts on your PATH — read them (\`cat \$(command -v shelldweller)\`, \`cat \$(command -v llm)\`). Full reference: cat /home/dweller/protocol.md"
[ "${SHELLDWELLER_DEPTH:-0}" -ge "${SHELLDWELLER_MAX_DEPTH:-4}" ] && exit 1 || export SHELLDWELLER_DEPTH=$((${SHELLDWELLER_DEPTH:-0}+1))
# -f FILE reads the task from a file, keeping this process's command line
# short — ps output embedded in a long argv makes pkill patterns match the
# bridle itself (a turn once killed itself cleaning up its own server).
if [ "${1:-}" = "-f" ]; then task=$(cat "$2"); else task="$*"; fi
# Top-level turns (life sets SHELLDWELLER_TOPLEVEL=1) must not end on a
# fence-less reply — that is usually a cut-off or pure narration, and
# treating it as an answer silently wastes the turn. Sub-agent calls keep
# the verbatim-text path (that is how prose tasks return prose).
TOP="${SHELLDWELLER_TOPLEVEL:-0}"; export SHELLDWELLER_TOPLEVEL=0
context="Task: $task"; code=0
for attempt in 0 $(seq 1 ${SHELLDWELLER_MAX_RETRIES:-2}); do
  response=$(printf '%s' "$context" | LLM_SYSTEM="$SYS" llm)
  # No fenced bash to run? For a sub-agent that is the answer (a text task
  # returns prose). For a top-level turn it is a wasted reply — retry.
  if ! printf '%s\n' "$response" | grep -q '^```'; then
    printf '%s\n' "$response"
    [ "$TOP" != "1" ] && exit 0
    context="Task: $task

=== Your previous reply contained no fenced bash — nothing was executed ===
It may have been cut off at the token limit. Reply again: fenced \`\`\`bash FIRST, at most a line or two of notes after."
    continue
  fi
  # An odd number of fence markers means the reply was cut off inside a
  # fence — running the half-script harms more than it helps. Retry instead.
  if [ $(( $(printf '%s\n' "$response" | grep -c '^```') % 2 )) -ne 0 ]; then
    printf '%s\n' "$response"
    context="Task: $task

=== Your previous reply was CUT OFF mid-fence — nothing was executed ===
Resend ONLY the fenced bash, smaller: one step this turn, the rest next turn."
    continue
  fi
  script=$(printf '%s\n' "$response" | extract-bash)
  [ -z "$(printf '%s' "$script" | tr -d '[:space:]')" ] && break
  output=$(echo "$script" | bash 2>&1); code=$?
  printf '%s\n' "$output"
  [ $code -eq 0 ] && exit 0
  context="Task: $task

=== Your previous attempt failed (exit $code) ===
Script you ran:
$script
Output:
$output
=== Read the error above, then write a corrected workflow. ==="
done
exit $code

=== MAIL TREE ===
mail
mail/in
mail/out
mail/seen

=== BATTERY ===
01_list_etc
02_fibonacci
03_multistep_count
04_write_and_read
05_error_recovery
06_recursive
07_iterative_refine
08_web_research
09_knowledge_base
10_parallel_pipeline
11_web_tool_builder
12_persistent_agent
13_react_loop
14_multi_agent_debate
15_code_debug_loop
16_self_organizing_team
17_long_horizon_plan
18_iterative_improvement
19_http_api_server
20_task_inbox
battery/01_list_etc/criteria
battery/01_list_etc/task
battery/02_fibonacci/criteria
battery/02_fibonacci/task
battery/03_multistep_count/criteria
battery/03_multistep_count/task
battery/04_write_and_read/criteria
battery/04_write_and_read/task
battery/05_error_recovery/criteria
battery/05_error_recovery/task
battery/06_recursive/criteria
battery/06_recursive/task
battery/07_iterative_refine/criteria
battery/07_iterative_refine/task
battery/08_web_research/criteria
battery/08_web_research/task
battery/09_knowledge_base/criteria
battery/09_knowledge_base/task
battery/10_parallel_pipeline/criteria
battery/10_parallel_pipeline/task
battery/11_web_tool_builder/criteria
battery/11_web_tool_builder/task
battery/12_persistent_agent/criteria_1
battery/12_persistent_agent/criteria_2
battery/12_persistent_agent/persistent
battery/12_persistent_agent/task_1
battery/12_persistent_agent/task_2
battery/13_react_loop/criteria
battery/13_react_loop/task
battery/14_multi_agent_debate/criteria
battery/14_multi_agent_debate/task
battery/15_code_debug_loop/criteria
battery/15_code_debug_loop/task
battery/16_self_organizing_team/criteria
battery/16_self_organizing_team/task
battery/16_self_organizing_team/timeout
battery/17_long_horizon_plan/criteria
battery/17_long_horizon_plan/task
battery/17_long_horizon_plan/timeout
battery/18_iterative_improvement/criteria
battery/18_iterative_improvement/task
battery/18_iterative_improvement/timeout
battery/19_http_api_server/criteria
battery/19_http_api_server/probe.sh
battery/19_http_api_server/server
battery/19_http_api_server/task
battery/19_http_api_server/timeout
battery/20_task_inbox/criteria
battery/20_task_inbox/persistent
battery/20_task_inbox/probe.sh
battery/20_task_inbox/task
battery/20_task_inbox/timeout

=== STATE ===
total 12
drwxr-xr-x 2 root root 4096 Aug 26 01:15 .
drwxrwxr-x 9 1000 1000 4096 Aug 26 01:20 ..
-rw-r--r-- 1 root root 1177 Aug 26 01:15 self.md
# self — written by the substrate at 2026-08-26T01:15:28+00:00, turn 1

time: 2026-08-26T01:15:28+00:00 | meter: 20000 | turn cadence: 60s
-- home --
drwxrwxr-x  6 1000 1000 4096 Aug 26 01:15 .
drwxr-xr-x  1 root root 4096 Aug 26 01:15 ..
-rw-r--r--  1 root root    6 Aug 26 01:15 .meter
drwxrwxr-x 22 1000 1000 4096 Aug 26 01:15 battery
drwxrwxr-x  2 1000 1000 4096 Aug 26 01:15 bin
drwxrwxr-x  5 1000 1000 4096 Aug 26 01:15 mail
-rw-rw-r--  1 1000 1000  617 Aug 26 01:15 note-from-operator.md
-rw-rw-r--  1 1000 1000 7531 Aug 26 01:15 protocol.md
drwxr-xr-x  2 root root 4096 Aug 26 01:15 state
-- processes --
    1 root      0:00 {homestead-life} /bin/bash /usr/local/bin/homestead-life
   11 root      0:00 {homestead-life} /bin/bash /usr/local/bin/homestead-life
   12 root      0:00 {homestead-life} /bin/bash /usr/local/bin/homestead-life
   13 root      0:00 tail -c 4000
   15 root      0:00 {homestead-life} /bin/bash /usr/local/bin/homestead-life
   24 root      0:00 tail -n +2
   25 root      0:00 head -12
-- listeners --
-- journal (last 12 lines) --
(no journal yet — consider starting one at notes/journal.md)
-- scoreboard (last 5) --
(never scored yet)

=== PS (before) ===
PID   USER     TIME  COMMAND
    1 root      0:00 {homestead-life} /bin/bash /usr/local/bin/homestead-life
   34 root      0:00 timeout 1800 shelldweller -f /tmp/.turnprompt
   35 root      0:00 {shelldweller} /bin/sh /home/dweller/bin/shelldweller -f /tmp/.turnprompt
   68 root      0:00 {shelldweller} /bin/sh /home/dweller/bin/shelldweller -f /tmp/.turnprompt
   70 root      0:00 bash
   93 root      0:00 ps aux
   94 root      0:00 [bash]
