# fable-kit

One command turns any folder into a Fable-class Claude Code starter project: operating-mode CLAUDE.md, 8 workflow skills, a project-local knowledge wiki, gitignore hygiene, and onboarding docs.

## Install (the CLI)

```bash
curl -fsSL https://raw.githubusercontent.com/reyco1/fable-kit/main/install.sh | bash -s -- /path/to/project
```

Or from a clone:

```bash
git clone https://github.com/reyco1/fable-kit
./fable-kit/install.sh /path/to/project
```

Re-running is always safe: existing files are never overwritten without `--force`.

## Options

```bash
... | bash -s -- ~/code/myapp --wiki ~/vault        # personal/global wiki (e.g. Obsidian vault) instead of project-local
... | bash -s -- ~/code/myapp --global-skills       # skills for ALL projects (~/.claude/skills)
... | bash -s -- ~/code/myapp --force               # replace existing CLAUDE.md (keeps a .bak)
... | bash -s -- ~/code/myapp --repo you/your-fork  # install from a fork
```

## What gets installed

```
your-project/
├── CLAUDE.md                  # operating mode (wiki path baked in)
├── .claude/skills/            # 8 skills (project-scoped by default)
├── wiki/                      # knowledge wiki - COMMITTED, shared via git
│   ├── index.md               # retrieval index - Claude reads this first
│   ├── concepts/              # durable knowledge articles
│   └── daily/                 # compiled daily logs
├── .gitignore                 # + .agent/ (scratch memory stays out of git)
└── docs/
    ├── GETTING-STARTED.md     # novice on-ramp - read this first
    └── FABLE-GAP-SKILLS-ROADMAP.md
```

Wiki placement: project-local by default so the team shares compiled knowledge through git. Solo devs working across many repos may prefer one personal vault: `--wiki ~/vault`.

## The skills

Tier 1: `long-run-memory`, `self-review`, `deep-planning`
Tier 2: `context-compaction`, `parallel-orchestration`, `codebase-mapping`, `failure-recovery`
Tier 3: `stack-verification` (template - fill in your team's real integration recipes)

## Verify it worked

Inside a Claude Code session: `/memory` should show CLAUDE.md loaded; ask "what skills do you have available?" and the eight above should appear. On your first multi-step task, a `.agent/` folder should appear in the project.

## Publishing your own copy

1. Push this folder to GitHub as `fable-kit`.
2. Edit the `REPO=` default at the top of `install.sh` to your `owner/fable-kit` slug, and swap `OWNER` in this README and in `templates/GETTING-STARTED.md`.
3. Your team's install command is then the one-liner at the top of this file.
