# Getting Started - For First-Time Claude Code Users

You've been given two files: **CLAUDE.md** and **FABLE-GAP-SKILLS-ROADMAP.md**. This guide tells you what they are, where to put them, and what to do in your first week. No prior experience assumed.

---

## What these files are (plain English)

**CLAUDE.md** is an instruction file. Claude Code automatically reads any file named `CLAUDE.md` at the start of every session and follows it. Think of it as a standing briefing you give a new team member every morning - except you only have to write it once. This particular CLAUDE.md makes Claude plan before coding, verify its own work before telling you it's done, and keep notes on disk so it can pick up where it left off tomorrow.

**FABLE-GAP-SKILLS-ROADMAP.md** is NOT something you install. It's a reading document - a plan for advanced add-ons ("skills") you might build later. Ignore it for your first few weeks. Come back to it once the basics feel natural.

---

## Setup (one command)

Open a terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/reyco1/fable-kit/main/install.sh | bash -s -- /path/to/your/project
```

(Replace `/path/to/your/project` with the folder you want to work in - it can be brand new or an existing project. Replace `OWNER` with the GitHub account hosting fable-kit if your copy of this doc hasn't been updated with it.)

That single command sets up everything:

- **CLAUDE.md** at the project root - Claude Code reads it automatically at the start of every session; no further action needed.
- **8 skills** in `.claude/skills/` inside the project.
- **A `wiki/` folder** inside the project - this is Claude's long-term memory, a plain folder of text files that is committed to git so your whole team shares what Claude learns.
- **A `.gitignore` entry** for `.agent/` (Claude's per-task scratch notes, which should NOT be committed).
- **This guide and a roadmap doc** in `docs/`.

Re-running the command is always safe - it never overwrites anything that already exists.

### Optional - Install Obsidian

Obsidian is a free app for reading and browsing folders of text files. Download it from obsidian.md, choose "Open folder as vault," and pick your project's `wiki/` folder. You don't need any plugins. This is purely for YOU to browse what Claude has learned - Claude doesn't need Obsidian at all. Skip this if you want; you can add it any time.

### Optional - Personal wiki instead of project wiki

If you'd rather keep one personal knowledge vault across all your projects (instead of one wiki per project), add `--wiki ~/vault` to the install command. The default project-local wiki is the right choice for team repos; a personal vault suits solo cross-project work.

---

## Your first session

1. Open a terminal in your project folder and run `claude`.
2. Give it a real task, in plain language, and include how you'll know it worked. Example:

   > "Add a dark mode toggle to the settings page. Success = I can click it and the background switches."

   That last part matters - this CLAUDE.md requires Claude to have a testable definition of "done," and giving one saves it a step.
3. Let it work. Don't interrupt every 30 seconds. It's configured to plan first, work in long stretches, and verify before reporting back.
4. When it reports done, look at what it says it VERIFIED (ran, tested), not just what it wrote. That distinction is built into its instructions.

## What you should see (signs it's working)

- On any multi-step task, a `.agent/` folder appears in your project containing files like `PLAN.md` and `STATE.md`. Open them - they're plain text and human-readable. `PLAN.md` shows the plan with checkboxes; `STATE.md` shows where things stand.
- Claude states its assumptions out loud instead of silently guessing.
- Claude runs tests or commands before claiming something works.
- If you come back the next day and say "continue where we left off," it reads its own notes and resumes instead of asking you to re-explain.

If NONE of that happens: check the file is named exactly `CLAUDE.md` (capital letters matter) and sits in the folder you launched `claude` from. Inside a session you can type `/memory` to see which instruction files were loaded.

## Habits worth building (first two weeks)

- **End big tasks with a close-out.** Say something like: "We're done - close out and compile what you learned into the wiki." Claude will distill the session's lessons into your wiki folder. Do this and your setup literally gets smarter every week.
- **Skim STATE.md when you return to a project.** Fastest way to remember where you were.
- **When Claude makes a mistake you never want repeated, say: "Add a rule about this to CLAUDE.md."** The file is meant to grow. Think of it as a living document, not a set-and-forget config.
- **Be specific about "done."** The single biggest quality lever is giving a checkable success criterion with every task.

## What NOT to do yet

- Don't build any of the skills in the roadmap file yet. Learn the base workflow first.
- Don't set up hooks or background automation. The manual version teaches you what good output looks like; automate only after that.
- Don't paste passwords, API keys, or private personal data into sessions. The instructions tell Claude to keep secrets out of its notes, but the best protection is not introducing them.
- Don't delete the `.agent/` folder mid-task - that's Claude's working memory. Deleting it after a task is finished is fine.

## When you're ready for more

After a couple of weeks, when `.agent/` files and wiki close-outs feel routine, open FABLE-GAP-SKILLS-ROADMAP.md and start with the Tier 1 skills. Ask Claude itself to help: "Read the roadmap file and help me build the long-run-memory skill using skill-creator." It knows what to do from there.
