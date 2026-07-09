---
name: deep-planning
description: Explore-then-plan protocol with runnable acceptance criteria. Use for any task touching 2+ files, any ambiguous request, any refactor, migration, new feature, or new integration - even if the user says "quick" or "simple". Also trigger on "plan this", "how should we approach", "break this down", or before starting anything estimated at more than ~20 lines of change. Skip only for genuinely trivial single-file, obvious changes.
---

# Deep Planning

Plan on disk before touching code. The plan is checked against the codebase, not against assumptions.

## Effort dial (decide first)
- **Quick** - single file, obvious, <~20 lines: skip this skill; just do it and verify.
- **Standard** - feature, bugfix, single module: steps 1-4 below, lightweight PLAN.md.
- **Deep** - migration, multi-module refactor, integration, multi-session work: full protocol + `.agent/` directory (long-run-memory skill) + subagent fan-out where independent.

When unsure, round up one level.

## Protocol

### 1. Explore first
Read broadly before editing anything. Map the blast radius:
- Direct targets: files that must change.
- Callers and consumers of everything you'll touch (grep for usages, don't assume).
- Tests covering the area (existing test topology tells you the safety net).
- Configs, env vars, migrations, feature flags involved.
- Downstream: jobs, webhooks, clients, reports that consume the output.

If a knowledge wiki exists (long-run-memory skill), read index.md and relevant concept articles BEFORE exploring raw code.

### 2. Write PLAN.md (in .agent/ if it exists, else repo root)
```markdown
# Plan - <task>
## Goal
<one paragraph, in terms of user-visible outcome>

## Acceptance criteria (runnable proofs only)
- [ ] <command/test/observable behavior> → expected result
- [ ] ...

## Blast radius
<files to touch and why; boundaries crossed>

## Steps (dependency order)
1. [ ] <step - leaf modules first, then consumers, then entry points>
2. [ ] ...

## Risks
- <risk> → mitigation

## Rollback
<how to undo if this goes wrong - concrete, not "revert">
```

### 3. Sanity-check the plan against the codebase
Verify the plan's assumptions with targeted reads: do the interfaces you're planning around actually look like that? If exploration contradicts the plan, REVISE THE PLAN. Never force a wrong plan onto a codebase.

### 4. Execute step by step
Check boxes in PLAN.md as steps complete. After each dependency layer, compile/typecheck before moving up. If mid-execution reality diverges from plan, stop, update PLAN.md, then continue - silent divergence is how multi-file changes rot.

## Acceptance criteria rules (this is the core of the skill)
Every criterion must be executable and observable:
- GOOD: "pytest tests/billing/ passes", "POST /enroll with sample.json returns 201 and a row appears in enrollments", "the workflow run completes with payload fixtures/consent.json".
- BAD: "code is correct", "billing works", "should be fine", "looks good".

If the user gave no criterion, PROPOSE one in PLAN.md before starting and state it in the first response. Building without a runnable definition of done is not permitted.

## Ambiguity handling
- Reversible/low-stakes ambiguity: choose, record in DECISIONS.md, state the assumption in the hand-back.
- Irreversible/high-stakes ambiguity (data deletion, production, security boundaries, money movement, compliance logic): stop and ask ONE consolidated question with a recommended default.
