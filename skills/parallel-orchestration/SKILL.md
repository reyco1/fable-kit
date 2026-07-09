---
name: parallel-orchestration
description: Decompose work into independent subagent briefs and integrate results cleanly. Use whenever a task contains independent units - exploring separate modules, running multiple test suites, researching multiple options, auditing multiple files - or when a deep task would otherwise serialize hours of independent work. Also trigger on "in parallel", "fan out", "split this up", or any exploration phase of a large codebase. Do not use for strictly ordered or shared-mutable-state work.
---

# Parallel Orchestration

The main thread is for decisions and integration. Independent work fans out.

## When to parallelize
Units are parallel-safe when they: touch disjoint files/modules, share no mutable state, have no ordering dependency, and can each be judged done by their own criterion. Classic fits: exploration/mapping of separate areas, running independent test suites, evaluating N candidate approaches, per-file audits, independent research questions.

## When NOT to parallelize
- Migrations or anything with strict ordering.
- Edits to overlapping files (merge pain exceeds the speedup).
- Work whose scope depends on another unit's findings - sequence those.
- Tiny tasks where brief-writing costs more than the work.

## The brief template (every subagent gets exactly this)
A brief must be self-contained: the subagent gets no follow-up questions.

```markdown
## Goal
<one paragraph - outcome, not activity>

## Scope
Files/areas: <explicit paths or globs>
Do NOT touch: <everything else - state it explicitly>

## Context you need
<the 3-10 facts from STATE/MAP/wiki the subagent can't discover cheaply>

## Acceptance criteria
- <runnable/observable proof of done>

## Return format
<exactly what to hand back - e.g. "markdown summary: findings, file:line references, open questions" or "diff + test output">

## Execution rules
- Surface assumptions explicitly; do not guess silently.
- Simplest change that meets the criteria; no speculative abstraction.
- Touch nothing outside Scope.
- Run your acceptance criteria before returning; report verified vs unverified.
```

## Orchestration procedure
1. Decompose into units; check each against the parallel-safe test above.
2. Write briefs. If two briefs' Scope sections overlap, merge or sequence them.
3. Launch. Main thread does not idle-wait: integrate results as they land, or work an independent unit itself.
4. **Integrate:** read each result, reconcile conflicts between subagent findings explicitly (never average them silently), update STATE.md and MAP.md with the merged picture BEFORE proceeding.
5. Verify at the seams: subagent work meeting individually can still fail jointly - run the joint criterion (build, integration test) after merging.

## Judging subagent output
Trust structure, verify claims: anything a subagent says it verified should come with the command/result; anything without proof gets re-run or marked unverified in STATE.md. A subagent returning "done" with no evidence is treated as not done.
