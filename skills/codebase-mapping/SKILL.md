---
name: codebase-mapping
description: Build and maintain a MAP.md repo map before multi-file work, wiki-first. Use before any multi-file change, refactor, or migration; when entering an unfamiliar repo or module; when the user asks "how does X work here", "where is Y handled", or "what would this change affect"; and whenever a change's blast radius is unclear. Also trigger when .agent/MAP.md exists but the code has moved since it was written.
---

# Codebase Mapping

Multi-file work fails when the model edits before it understands the territory. The map is built once, on disk, and updated as learned - never rebuilt from scratch when a prior map exists.

## Wiki-first policy
Before mapping from raw code:
1. Read the knowledge wiki `index.md` (long-run-memory skill) and pull architecture-relevant concept articles.
2. Check for an existing `.agent/MAP.md` - if present, verify its freshness against 2-3 spot checks (do the named entry points still exist?) rather than rereading everything.
3. Only map from scratch what neither source covers.

On task close-out, durable architecture facts discovered during mapping graduate into wiki concept articles via the compile step.

## MAP.md construction procedure
Scope the map to the task's blast radius plus one ring - not the whole repo.

1. **Entry points:** how execution enters the area - routes, CLI commands, cron/queue consumers, event handlers. Grep route tables, job registries, main files.
2. **Data flow:** for the task's core nouns (e.g. "enrollment", "invoice"), trace write path and read path: where created, mutated, persisted, consumed. Note serialization boundaries.
3. **Ownership:** which module owns which concern; where the awkward shared code lives; anything two modules both mutate (flag it - that's where bugs cluster).
4. **Test topology:** which tests cover the area, how they run, what has no coverage (uncovered zones need extra self-review care).
5. **Config surface:** env vars, feature flags, per-environment differences that affect the area.

## MAP.md template
```markdown
# Map - <area/task>
Updated: <date> | Confidence: <fresh / spot-checked / stale>

## Entry points
- <route/command/consumer> → <handler file:line>

## Data flow: <core noun>
write: <path through files> | read: <path> | persisted: <table/store>

## Ownership
- <module>: <concern>. Shared/hot spots: <files two owners touch>

## Test topology
- <suite/path>: covers <what>. Runs via: <command>
- Uncovered: <zones>

## Config surface
- <var/flag>: <effect, per-env notes>

## Change touch-list (for the current task)
- <file>: <why it must change>
```

## Maintenance rules
- Update MAP.md the moment exploration contradicts it - a wrong map is worse than none.
- Mark confidence honestly; a resuming instance must know whether to trust it.
- Big repos: fan mapping out per module via parallel-orchestration briefs; integrate returned summaries into one MAP.md.
- Use targeted reads to build the map (grep symbols, read signatures/line ranges) - mapping must not consume the context budget the task itself needs.
