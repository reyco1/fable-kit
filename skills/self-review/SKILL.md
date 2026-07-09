---
name: self-review
description: Adversarial self-validation before any hand-back. Use before reporting ANY code task as complete, before opening a PR, before saying "done", "fixed", "should work now", or "ready", and whenever the user asks "is this done", "is this safe", or "is this ready". Also use after completing any multi-file change, migration, or integration work, even if the user did not ask for review. Never skip this on the grounds that the change was small.
---

# Self-Review

Never claim work is done without running this loop. Report what you VERIFIED, not what you wrote.

## The loop

### 1. Run it
Execute the actual thing: tests, build, lint/typecheck, the real command, the real request with a real payload. Capture output. "It compiles" is not "it works."

### 2. Adversarial diff review
Re-read the FULL diff as a hostile senior reviewer. Generic checks: edge cases, error paths, off-by-ones, broken/unused imports, unhandled null/undefined, resource leaks, race conditions, logging of sensitive values.

Then apply the checklist for the change type(s) involved:

**API change:** backward compatibility of request/response shapes; error response contract; auth on new endpoints; input validation; updated client callers; versioning if breaking.

**Schema / migration:** rollback path actually works (write it, don't assume it); default values for existing rows; index impact on large tables; FK/constraint violations against real data shapes; migration ordering vs deployed code (old code must survive new schema during rollout).

**Async / queue / jobs:** idempotency on retry; poison-message handling; timeout and backoff; ordering assumptions; what happens if the worker dies mid-job.

**Auth / access control:** every new path checks authorization, not just authentication; no privilege widening by default; token/secret never logged or persisted; deny-by-default on ambiguous cases.

**Third-party integration payloads:** validate against the provider's actual contract, not memory of it; handle their error/rate-limit responses; test with a sample payload end to end; webhook signature verification if applicable.

### 3. Execution-discipline pass
Check the work against the four base rules:
- Any silent assumptions made? → surface them now in the hand-back and log to DECISIONS.md.
- Any bloat: speculative abstraction, unneeded flexibility, leftover debug scaffolding? → remove it.
- Any out-of-scope edits: files touched that the task didn't require? → revert them; note the finding instead.
- Was the stated success criterion actually executed? If there was no criterion, that is itself a failure - define one and run it before proceeding.

### 4. Check the seams
Multi-file changes fail at boundaries. For each boundary crossed (module interface, serialization layer, env/config, type edge, service call): verify the two sides agree, explicitly, with a compile/typecheck/test that exercises the seam.

### 5. Regression sweep
Run the existing test suite; at minimum, every test adjacent to touched code. A green new feature with a red neighbor is not done.

## If any step fails
Loop back and fix. Do NOT hand back known-broken work with a note. If genuinely blocked, use the failure-recovery protocol (3-hypothesis budget) before escalating.

## Hand-back template
```
Outcome: <what now works, one line>
Verified: <commands/tests run + results - only things actually executed>
Decisions/assumptions: <from DECISIONS.md, anything the user should sanity-check>
Not verified: <anything unrunnable here + why + how the user can verify>
Out-of-scope findings: <things noticed but deliberately not changed>
```

Empty sections may be omitted, except Verified - if Verified would be empty, the work is not ready to hand back.
