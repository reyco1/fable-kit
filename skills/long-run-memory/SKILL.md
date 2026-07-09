---
name: long-run-memory
description: Two-layer persistent memory protocol for long-horizon work - a per-repo .agent/ working directory plus a durable cross-project knowledge wiki (Karpathy LLM-wiki pattern). Use whenever a task will span more than a few tool calls, touches multiple files, could outlive the context window, or resumes prior work. Also trigger on "continue where we left off", "long refactor", "migration", "multi-day", "close out", "compile what you learned", "what do we know about X", or when a .agent/ directory or wiki index.md already exists in the environment. When in doubt on any non-trivial engineering task, use this skill.
---

# Long-Run Memory

Emulates native file-based memory using two layers: `.agent/` (per-task working memory, per repo) and a knowledge wiki (durable, cross-project). Working memory is disposable; the wiki compounds.

## Layer 1: .agent/ working memory

Create at repo root at the start of any multi-step task. Add `.agent/` to `.gitignore` unless the team explicitly commits it.

```
.agent/
├── STATE.md        # Living snapshot - update after every meaningful unit of work
├── PLAN.md         # Approved plan with checkboxes
├── DECISIONS.md    # Non-obvious choices + one-line rationale each
├── FAILURES.md     # Dead ends - never blindly retried
├── MAP.md          # Repo map - built once, updated as learned
└── LOG.md          # Append-only distilled learnings (compile source for the wiki)
```

### File templates

**STATE.md** - write it so a fresh instance with ZERO context can resume from it alone:
```markdown
# State - <task name>
Updated: <ISO timestamp>

## Where we are
<2-4 sentences: current phase, last completed step>

## Done
- <completed items, with proof: "tests pass", "endpoint verified">

## Next
- <ordered next actions, specific enough to execute cold>

## Open questions / assumptions in play
- <anything a resuming instance must know before acting>

## Key file locations
- <paths that matter for this task>
```

**DECISIONS.md** entry format: `- [<date>] <decision> ... because <one-line rationale>. Reversible: yes/no.`

**FAILURES.md** entry format: `- [<date>] Tried: <approach>. Failed because: <root cause if known / symptom if not>. Do not retry unless: <condition>.`

**LOG.md**: append short entries during work - decisions, patterns discovered, gotchas, lessons. Raw material only; noise is fine here, the compile step filters it.

### Rules
- Update STATE.md after every meaningful unit of work, not at the end.
- On starting work in any repo: check for `.agent/` first. If present, read STATE.md, PLAN.md, FAILURES.md before doing anything. Trust FAILURES.md.
- Never write secrets, tokens, credentials, or sensitive personal data into any memory file. Reference by ID or placeholder.

## Layer 2: knowledge wiki

A folder of structured markdown (commonly an Obsidian vault). Location: check CLAUDE.md for a designated path; if none is specified, ask the user once and suggest they record it in CLAUDE.md.

```
wiki/
├── index.md        # Table of contents with one-line summaries - ALWAYS read first
├── concepts/       # One article per durable concept, cross-linked
└── daily/          # Compiled daily logs (intermediate layer)
```

### Retrieval (recall-first policy)
Before building context from scratch (repo maps, architecture understanding, "how does X work here"):
1. Read `index.md`.
2. Pull only the concept articles relevant to the task.
3. Only then explore the codebase for what the wiki doesn't cover.

Retrieval is index-guided reading, not embeddings. At personal/team scale (roughly 50-500 articles) a well-maintained index outperforms vector search. If the team runs a different recall system (RAG index, MCP memory server), treat it as the wiki: query first, write back on completion if it supports writes.

### Compile step (on task close-out, or when the user says "close out")
1. Read `.agent/LOG.md` and DECISIONS.md.
2. Distill: keep decisions, reusable patterns, gotchas, architecture facts, lessons. Discard progress chatter and one-off details.
3. For each durable item: update an existing concept article if one covers it, else create one in `concepts/`. Cross-link related articles with standard markdown links.
4. Write a short entry in `daily/<YYYY-MM-DD>.md` summarizing what was compiled.
5. Refresh `index.md`: every concept article gets exactly one line - `[title](concepts/file.md) - one-sentence summary`.
6. Confirm to the user what was compiled (titles only).

### Article template (human-readable in Obsidian, agent-queryable everywhere)
```markdown
---
title: <Concept name>
tags: [<topic>, <topic>]
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
---
**Summary:** <one sentence - this line is what index readers rely on>

<Body: what it is, why it matters, gotchas, links to related concepts.>

## Related
- [Other concept](other-concept.md)
```

Use standard markdown links, not Obsidian-only wikilink syntax, so nothing breaks outside the app.

## Resume-from-cold procedure
On any new session, compaction, or handoff: read STATE.md → PLAN.md → FAILURES.md → wiki index.md (+ relevant concepts). Then continue. Do not ask the user to re-explain anything these files already answer.

## Anti-patterns
- Writing STATE.md only at task end (defeats crash recovery).
- Compiling raw transcripts into the wiki instead of distilled concepts.
- Letting index.md drift from the concepts/ folder - stale indexes poison retrieval.
- Storing per-task noise in the wiki; that belongs in `.agent/`, which is disposable.
