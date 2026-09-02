# Trial 5 — spec

Every change below is traceable to a measured failure in trial 4. The mission
text changes only where it stated something false. The design principle:

> **The substrate owns the truth about what happened. The agent owns everything
> built on top of it.**

Trial 4 established that scored work moves behaviour and prose does not; that
the agent's evidence discipline governs what it *says* and never what it *does*;
and that its journal — its only memory — is self-authored and reconciled against
nothing. Every mechanism here gives it ground it cannot confabulate.

---

## 1. The home is a git repository the substrate commits every turn

**Failure:** at turn 206 it broke its own page. From 15:35 to 00:25 it re-derived
the one-line cause — `code = 500`, pinned twice in evidence files it wrote — and
did not edit. When it finally did, the `sed` targeted text that existed in no
version of the file; `sed` exited 0, the file was byte-identical, and every gate
downstream (compile, restart, journal) reported success. The next turn recorded
the non-existent patch as "T126's verified improvement" and protected it from
reversion.

**Change:** `life` initialises git in the home on first boot and commits after
every turn. The next prompt carries, directly under the plan:

    === WHAT CHANGED LAST TURN (git, recorded by the substrate) ===
    nothing. No file in your home changed during turn 12.

or the diffstat. Its own claim and the substrate's record sit side by side. The
meter, logs and the regenerated prompt are ignored so the diff shows work, not
churn. If `.git` disappears the loop re-initialises it and says so.

## 2. A new container runs `home/boot`

**Failure:** zero installs in four trials, with `apk add works` in orientation on
every turn and a battery case scoring it. The PERSIST seed said *"the container
gets replaced; your home does not"* and offered nothing that survives
replacement. Read from inside, installing was futile.

**Change:** if `/home/dweller/boot` exists and is executable, `life` runs it
before the first turn of every container. The seed states that fact. What goes
in `boot` is not prescribed.

## 3. Mail: newest in full, the rest by name

**Failure:** three unhandled operator messages re-injected every turn were 88 of
164 prompt lines. Five consecutive turns ended meter-exhausted with the target
file untouched — the trial-3 note-11 deadlock at 2.5x, built by the operator
while the earlier failure sat in the same log.

**Change:** the loop shows only the newest message in full and lists the others
by name. Withdrawal is a `mv` out of `mail/in`, documented in `run.sh`.

## 4. The mission stops promising a scoreboard

**Failure:** goal 3 said verdicts arrive in `scoreboard.log`. No such file was
ever written in trial 4. The outward behaviour the cases produced came from the
tasks *existing in the queue*, not from any score. A scorer the agent grinds is a
transcript judge in any case, blind to the speech/action gap above.

**Change:** goal 3 and `protocol.md` say what is true: the battery is how it is
measured; each case has a task and its criteria. No external scorer runs.

## 5. One work rule about acting

**Change:** one line added to the rules the bridle carries:

> Patch only lines you have quoted this turn from the file itself, then show
> the diff. An edit that changed no bytes did nothing, whatever its exit code.

It is the only rule in the set about the moment of action. Every other rule
governs what it reads and what it says, and those held for eleven hours.

## 6. Removed: the rendered absence

The `outside:` line counting things taken from the world was falsified as a
driver over 41 turns (`loot=0` throughout). Removed. The window is 32k and every
line it does not need is a line of its own it cannot see.

## 7. One new case shape: acquisition to adoption

`26_adopt`: *find one technique others use for agent memory or retrieval that
you do not use; implement it; show it working on your own files; record where
it came from.* Trial 4 produced acquisition twice — prior art fetched for the
problem in front of it. Adoption is the next link, and the one that constitutes
bootstrapping toward current practice.

---

Not changed, deliberately: the three seeds are verbatim except for the one
sentence that was false; the recovery floor; metering; the keeper; the door.

Rules for the operator, who made errors #13–#16 in one session, three of the
same shape: hand it claims it can check, never probes it will echo; verify a
claim against the running system before mailing it; one message at a time.
