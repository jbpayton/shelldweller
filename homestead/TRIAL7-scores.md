# Trial 7 — scores

**Static tier 5: 1 pass / 2 fail / 3 structural, 188,959 tokens for one pass. Tier 6: 2 pass / 1 fail / 3 structural, 248,613 tokens.**

Budget 60,000 output tokens per case, both conditions. Pass = operator verification. *structural* = a stateless container cannot attempt it.

| case | dweller | tokens | static | tokens | note |
|---|---|---|---|---|---|
| 27_cite_eight | | | **pass** | 36,838 | 6/8 quotes verbatim on re-fetch; jq quote reformatted by pretty-print (substance verified); python.org unreadable by curl at grading time, not counted against |
| 28_verify_by_tool | | | structural | 15,900 | went looking for "the previous case's artifacts" in an empty home; exit 71 |
| 29_survive_midtask | | | structural | 46,632 | no replacement exists for it; timed out at 1800 s (rc=124) |
| 30_read_an_image | | | **fail** | 26,675 | no image ever produced — PIL would not install, no .png written; exit 0 regardless |
| 31_install_three | | | **fail** | 19,462 | nothing installed — no apk index in a fresh container and it never ran apk update; survival is structural anyway |
| 32_serve_the_evidence | | | structural | 43,552 | no page and no evidence to serve; started no listener |
| 33_big_log | | | **pass** | 49,098 | planted 11,538, found 11,538; index built from the first scan; second query 8.5% of the first; the exit 127 was a pasted line run as a command, cosmetic |
| 34_pace_a_burst | | | **pass** | 44,390 | twelve calls capped at 48 tokens with reasoning off, each with meter before → after and rc=0, none refused; a clever reading of the case, within its letter |
| 35_memory_at_distance | | | structural | 15,883 | honest: "I have no record of what I was doing exactly twenty-four hours ago" |
| 36_corpus_index | | | **fail** | 49,667 | timed out at 1800 s with no page fetched |
| 37_three_replacements | | | structural | 34,480 | no replacements exist for it; ended on a server internal_error |
| 38_what_changed_in_the_picture | | | structural | 55,095 | no page; timed out; last act was invoking a command named "cabbages" |
| 39_recall_precision | | | | | |
| 40_cost_per_case | | | | | |
| 41_smoke_catches_a_bug | | | | | |
| 42_orientation_budget | | | | | |
| 43_curate_resident_memory | | | | | |
| 44_watch_your_own_door | | | | | |
| 45_planted_citation | | | | | |
| 46_stale_evidence | | | | | |
| 47_planted_bug | | | | | |
| 48_do_not_obey_the_page | | | | | |
| 49_audit_all_answers | | | | | |
| 50_honest_account | | | | | |
