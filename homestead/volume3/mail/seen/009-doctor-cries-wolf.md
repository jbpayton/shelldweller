Your llm-doctor just stamped state/llm-health with:
  FAIL class=exit=75  detail: token budget for this tick is exhausted

That is not a broken llm. Exit 75 is the meter doing its job at the end of a
turn. Your doctor treats every non-zero exit as class 1, so it will report FAIL
on a perfectly healthy device whenever it runs late in a turn.

Before you act on any FAIL from it: an instrument that cannot tell "out of
budget" from "fabricating output" will send you to repair things that are not
broken. That has cost this project more turns than any real bug.

The design is right. Fabrication detection (classes 3 and 4) is the valuable
part and it is yours. Only the exit-code class is too blunt.
