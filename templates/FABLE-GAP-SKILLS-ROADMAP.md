# Skills Roadmap - Closing the Fable 5 Gap on Opus 4.8

Companion to the master CLAUDE.md. The CLAUDE.md sets always-on behavior; skills carry the deep procedural detail that shouldn't live in every context window. Each skill below maps to a specific Fable 5 advantage.

The stack, bottom to top:

1. **Karpathy 4 rules** (CLAUDE.md Section 0) - within-turn execution discipline
2. **Master CLAUDE.md** (Sections 1-10) - cross-turn long-horizon workflow
3. **`.agent/` working memory** - per-task state on disk
4. **Knowledge wiki** (Karpathy LLM-wiki pattern, Obsidian front-end) - durable cross-project memory

Format per skill: what Fable does natively → what the skill encodes → status.

---

## Tier 1 - build these first (highest leverage)

### 1. `long-run-memory`
- **Fable advantage:** native file-based memory, runs for days on one task.
- **Skill encodes:** both memory layers.
  - *Working layer:* the `.agent/` protocol - file templates for STATE.md / PLAN.md / DECISIONS.md / FAILURES.md / MAP.md / LOG.md, checkpoint cadence rules, resume-from-cold procedure, secrets/sensitive-data exclusion checklist.
  - *Durable layer:* the wiki-compile pattern - append distilled learnings to LOG.md during work; on task close-out, compile into concept articles, cross-link, refresh index.md. Retrieval is index-guided reading (read index.md, pull relevant articles), not embeddings - at personal/team scale a structured index beats vector search. Include a wiki article template (YAML frontmatter: title, tags, created, updated; one-sentence summary; standard markdown links) so the vault stays both human-readable in Obsidian and agent-queryable.
  - *Obsidian conventions:* vault = plain folder of markdown; keep `.agent/` per-repo and gitignored, wiki in the vault; avoid Obsidian-only syntax (prefer standard links over wikilinks) so nothing breaks outside the app; optional Dataview-friendly frontmatter for human dashboards.
  - *Adapter pattern:* teams with an existing knowledge/recall system (RAG index, MCP memory server) substitute it for the wiki - query first, write back on completion.
  - *Automation notes:* Claude Code hooks can capture session transcripts and trigger background compile (see coleam00/claude-memory-compiler for a reference implementation of the Karpathy knowledge-base architecture). Ship the skill so it works manually first; hooks are an optional upgrade.
- **Trigger description (pushy):** "Use whenever a task will span more than a few tool calls, touches multiple files, could outlive the context window, or resumes prior work. Also trigger on 'continue where we left off', 'long refactor', 'migration', 'multi-day', 'close out', or 'what do we know about X'."
- **Status:** SPEC. Build first - it is the substrate everything else writes to.

### 2. `self-review`
- **Fable advantage:** self-validation loops (Anthropic cited a 3x performance jump from self-validation).
- **Skill encodes:** adversarial review checklists by change type (API change, schema/migration, async/queue, auth, third-party integration payloads), seam-verification procedure for multi-file diffs, regression sweep selection logic, a Section-0 compliance pass (silent assumptions? bloat? out-of-scope edits? success criterion actually run?), and a "verified vs written" hand-back template.
- **Trigger:** "Use before reporting ANY code task as complete, before opening a PR, and whenever the user asks 'is this done/safe/ready'."
- **Status:** SPEC.

### 3. `deep-planning`
- **Fable advantage:** long-horizon decomposition; lead grows with task complexity.
- **Skill encodes:** explore-then-plan procedure, blast-radius mapping, acceptance-criteria patterns (runnable proofs only - operationalizes Karpathy rule 4), dependency-ordered execution for refactors, effort-dial rubric.
- **Trigger:** "Use for any task touching 2+ files, any ambiguous request, any refactor, migration, or new integration - even if the user says 'quick'."
- **Status:** SPEC.

## Tier 2 - build after Tier 1 proves out

### 4. `context-compaction`
- **Fable advantage:** effectively unbounded working sessions.
- **Skill encodes:** when to checkpoint, what a resumable checkpoint must contain, how to summarize tool output lossily-but-safely, targeted-read patterns (grep/slice over whole-file reads), and resume order (STATE.md → PLAN.md → FAILURES.md → wiki index.md).
- **Status:** SPEC. Overlaps CLAUDE.md Section 5 - the skill version adds templates and worked examples.

### 5. `parallel-orchestration`
- **Fable advantage:** fewer turns per task, strong async delegation.
- **Skill encodes:** decomposition into independent briefs, subagent brief template (goal / files / acceptance criteria / return format / Section 0 rules), integration procedure, and when NOT to parallelize (shared mutable state, strictly ordered steps).
- **Status:** SPEC. Teams already running custom agent orchestration should audit overlap before writing.

### 6. `codebase-mapping`
- **Fable advantage:** holds the whole codebase in working memory during multi-file work.
- **Skill encodes:** MAP.md construction procedure (entry points, data flow, ownership, test topology), incremental update rules, and a wiki-first policy: check index.md and relevant concept articles before mapping from scratch; push durable architecture facts back to the wiki on completion.
- **Status:** SPEC.

### 7. `failure-recovery`
- **Fable advantage:** recovers from its own failures without human help (Anthropic's protein-design example).
- **Skill encodes:** diagnose → hypothesize → fix → retry loop, 3-hypothesis budget, FAILURES.md logging format, escalation template (what to tell the user when genuinely stuck: evidence, hypotheses tried, recommended next probe), and a compile rule: recurring failure patterns graduate from FAILURES.md into wiki concept articles so they're never rediscovered.
- **Status:** SPEC.

## Tier 3 - situational

### 8. `stack-verification` (template, customized per team)
- **Skill encodes:** concrete verification recipes for the team's real integration surfaces - e.g., workflow-engine test executions with sample payloads, CRM writeback checks, webhook/queue replay, warehouse cost-guard checks before large scans. Ships as a template with placeholder recipes; each team fills in its own stack, ideally sourcing recipes from their wiki.
- **Status:** SPEC (template). Not a "Fable gap" skill per se, but it typically pays for itself fastest because it turns "self-validate everything" from a principle into runnable steps for that team's actual systems.

### 9. Existing pieces to keep in the loadout
- **forrestchang/andrej-karpathy-skills** (exists, community) - the four-rule CLAUDE.md. Already merged into our master file as Section 0; teams can alternatively `@import` the original alongside.
- **skill-creator** (exists, in Anthropic's example skills) - use it to build all of the above, including its eval loop to measure trigger accuracy.
- **claude-memory-compiler** (exists, community) - reference implementation of hooks-based capture + compile for the wiki layer; adopt or borrow from it rather than building capture automation from scratch.
- **Obsidian** (exists) - front-end for the wiki. No plugin dependencies required; Dataview optional for human dashboards.
- Standard document/frontend skills (exist) - unrelated to the Fable gap, keep enabled as normal.

---

## Build order and method

1. Set up the wiki folder (or Obsidian vault) and drop in index.md plus the article template - this takes minutes and everything else assumes it exists.
2. Build Tier 1 with skill-creator, one at a time, with 5 to 8 test prompts each drawn from the team's real recent tasks.
3. Run the description-optimization loop so skills trigger reliably - undertriggering is the default failure mode.
4. Add capture/compile automation (hooks) only after the manual compile step has proven its value - automation of a bad compile format just produces noise faster.
5. Re-evaluate after two weeks of real use: the honest test is whether Opus 4.8 + this stack completes tasks you'd otherwise have routed to Fable 5.

## What this will NOT close

Be clear-eyed: raw reasoning depth on genuinely hard problems (FrontierCode-class work, novel debugging across module boundaries) is in the weights. This stack closes the workflow gap - execution discipline, planning, persistence, self-verification, memory - which is a large share of the perceived difference, but on the hardest 10 to 20% of tasks Fable 5 will still win. The recommended posture: route those to Fable 5 and keep Opus 4.8 + this stack as the high-volume default. That hybrid is also cheaper and preserves zero-data-retention eligibility for teams that need it.
