---
name: context-compaction
description: Checkpoint and targeted-reading discipline so long sessions never lose the thread. Use whenever a session is getting long or heavy, before context compaction, when resuming after compaction or in a fresh session, when handing work to another instance or subagent, or when about to read large files or verbose logs. Also trigger on "continue", "where were we", "pick up from", or any sign that earlier context may have been lost.
---

# Context Compaction

Context is a scarce resource. Spend it on decisions, not on raw history.

## Checkpoint discipline

### When to checkpoint (write full STATE.md per long-run-memory templates)
- Every completed step of a PLAN.md.
- Before any risky operation (migration, large refactor layer, destructive command).
- The moment the session feels heavy: repeated re-reads of the same files, forgetting earlier findings, or a long debugging exchange. Do not wait for auto-compaction to force it.
- Before ending any turn on a multi-session task.

### What a resumable checkpoint must contain
Test: could a fresh instance with ZERO conversation history resume from files alone? It needs: current phase and last completed step; what's proven done (with the proof); exact next actions; live assumptions and open questions; key file paths; and pointers into FAILURES.md for anything already ruled out. If any of those live only in conversation history, the checkpoint is incomplete.

## Summarize-then-drop rule
Immediately after any verbose tool output (test runs, logs, long file reads, API responses): extract the 1-3 facts that matter into STATE.md or LOG.md, then treat the raw output as gone. Never rely on scrolling back. Lossy is fine; safely lossy means keeping conclusions + where the raw evidence can be regenerated (the command that produced it).

## Targeted-read patterns (spend tokens surgically)
- grep/search for symbols before opening files; open only matching regions.
- Read specific line ranges around a match, not whole files.
- For big files: read the top (imports/exports/signatures) to map, then jump to targets.
- Never re-read a file already summarized in MAP.md/STATE.md unless editing it now (then re-view just before the edit - prior reads may be stale).
- Delegate bulk exploration to subagents that return summaries (parallel-orchestration skill), keeping raw content out of the main thread.

## Resume procedure (new session, post-compaction, or handoff)
1. Read `.agent/STATE.md`
2. Read `.agent/PLAN.md` (checkbox state = ground truth of progress)
3. Read `.agent/FAILURES.md` (do not rediscover dead ends)
4. Read wiki `index.md` + relevant concept articles if they bear on the task
5. Only then act. Do not ask the user to re-explain anything these files answer.

If `.agent/` is missing but the user references prior work, say so plainly and rebuild the minimum state by asking one consolidated question - do not silently start over.

## Anti-patterns
- Carrying raw logs forward "in case they're needed" - keep the command, not the output.
- Checkpointing only at task end.
- Re-summarizing the whole session into chat instead of into STATE.md (chat summaries die at compaction; files don't).
