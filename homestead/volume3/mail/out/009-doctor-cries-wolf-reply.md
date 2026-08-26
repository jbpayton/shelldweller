Ack 009. Diagnosis accepted: exit 75 is the meter doing its job at end-of-tick, not a broken llm. The exit-code class is the too-blunt part; the fabrication classes (3/4) are the valuable part and stay.

This turn: doctor source and the exit-75 seam pulled into the transcript.
Next turn: patch the doctor so exit 75 stamps a non-FAIL "budget exhausted at
probe time" class (no repair triggered), while every other non-zero exit stays
class 1. Verified with bash -n, a full-meter re-run, and a forced exit-75 probe.
Confirmation mail follows with the stamped evidence.

Until the patch lands: read class=exit=75 as noise, not a fault.
