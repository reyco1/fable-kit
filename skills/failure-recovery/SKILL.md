---
name: failure-recovery
description: Diagnose-hypothesize-fix-retry loop with a 3-hypothesis budget before escalating. Use the moment anything fails - a test, build, deployment, API call, migration, or command - and especially when tempted to report "it didn't work" or to retry the same thing unchanged. Also trigger on flaky or intermittent failures, on "still broken", and when resuming a task whose FAILURES.md has entries.
---

# Failure Recovery

"It didn't work" is never a stopping point, and retrying the same thing unchanged is never a strategy. Every retry must be driven by a new hypothesis.

## The loop

### 1. Diagnose
Capture the actual evidence: full error output, logs, the exact command and inputs. Reproduce it once deliberately - a failure that can't be reproduced can't be fixed, only observed (see flaky handling below). Localize: what is the smallest thing that fails?

### 2. Hypothesize
State a specific, falsifiable cause: "the migration fails because the FK constraint is checked before the backfill runs" - not "something is wrong with the migration." Before adopting it, check `.agent/FAILURES.md`: if this hypothesis (or approach) was already tried, it is spent - pick a different one.

### 3. Fix and retry
Make the minimal change the hypothesis implies. Retry the reproduction. Two outcomes:
- **Fixed:** verify it didn't break something adjacent (self-review regression sweep), log the root cause to LOG.md, continue the task.
- **Not fixed:** log the attempt to FAILURES.md, return to step 2 with what the failed fix taught you.

### FAILURES.md entry format
```
- [<date>] Symptom: <what failed>. Hypothesis: <cause>. Tried: <change>. Result: <still failing / new symptom>. Do not retry unless: <condition>.
```

## The 3-hypothesis budget
Three DISTINCT hypotheses (not three retries of one) before escalating to the user. Distinct means a different causal story, usually a different layer: code logic vs environment/config vs data shape vs external dependency. If two hypotheses live in the same layer, deliberately form the third in a different one.

Budget exceptions - escalate immediately, before hypothesis 1, when:
- The fix would be destructive or irreversible (data deletion, force ops, prod changes).
- Evidence points to something outside your control (expired credentials, provider outage, missing access).
- The failure reveals the task's premise is wrong (the feature conflicts with existing behavior by design).

## Flaky / intermittent failures
Don't chase a ghost with the standard loop. Run the reproduction N times to estimate frequency; look for the classic causes first (timing/races, test-order dependence, external service variance, unpinned versions); if it can't be made deterministic within budget, quarantine it explicitly in the hand-back rather than pretending a green run resolved it.

## Escalation template (when the budget is spent)
```
Blocked on: <one-line symptom>
Evidence: <key error output, where full logs live>
Hypotheses tried:
1. <hypothesis> → <what the attempt showed>
2. ...
3. ...
Ruled out: <what we now know it is NOT>
Recommended next probe: <the single most informative thing to try, and what it needs from you - access, a decision, information>
```
An escalation that teaches the user what it isn't is progress; a bare "still broken" is not.

## Compile rule
Recurring failure patterns (hit twice across tasks) graduate from FAILURES.md into a wiki concept article at close-out - e.g. "gotcha: staging DB lacks the extension prod has" - so no future session rediscovers them.
