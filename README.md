# fable-kit

One command turns any folder into a Fable-class Claude Code starter project: operating-mode CLAUDE.md, 8 workflow skills, a project-local knowledge wiki, gitignore hygiene, and onboarding docs.

Repo: https://github.com/reyco1/fable-kit (public)

## Requirements

- `bash`, `curl`, and `tar` on PATH (macOS and Linux have these by default; on Windows use WSL or Git Bash)
- No dependency on the target project's language/framework — the installer only writes files

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
... | bash -s -- ~/code/myapp --ref some-branch     # install from a branch/tag other than main
```

From a clone, `./install.sh --help` prints this same list straight from the script's header comment.

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

## Uninstalling / undoing

The installer only ever adds files, so removal is manual:

```bash
rm -rf .claude/skills docs/GETTING-STARTED.md docs/FABLE-GAP-SKILLS-ROADMAP.md wiki
rm CLAUDE.md   # or restore CLAUDE.md.bak if you ran --force
```

Also remove the `.agent/` line the installer appended to `.gitignore` if you no longer want it. If you used `--global-skills`, the skills live in `~/.claude/skills/<name>` instead of the project.

## Troubleshooting

**`curl: (56)` / 404 right after publishing or updating the repo**
`raw.githubusercontent.com` sits behind a CDN edge cache that can serve a stale (or nonexistent) file for a few minutes after a push. Wait 2-5 minutes and retry. To confirm the fix already landed on GitHub (bypassing the cache), check `https://github.com/OWNER/fable-kit/blob/main/install.sh` in a browser or `gh api repos/OWNER/fable-kit/contents/install.sh`.

**`could not download https://codeload.github.com/...` (404)**
Almost always one of:
- The repo is **private** — `curl | bash` has no credentials, so both `raw.githubusercontent.com` and `codeload.github.com` 404 on a private repo. Either make the repo public, or use the local-clone install method (`git clone` + `./install.sh`, which works with your existing git/gh auth).
- `--repo`/`FABLE_KIT_REPO` or `--ref` points at a slug or branch that doesn't exist. Double check the exact `owner/name` and branch.

**Script errors immediately with no fetch attempt**
You need `bash`, `curl`, and `tar` on PATH. On Windows, run it from WSL or Git Bash, not PowerShell/cmd directly.

**"downloaded archive doesn't look like fable-kit"**
The tarball came from the right repo/branch but the internal folder layout is unexpected — usually means `--repo` points at a fork that has renamed or removed `templates/` or `skills/`.

## Publishing your own fork

Already-published copies (like this one, at `reyco1/fable-kit`) need none of this — it's only for teams forking their own variant:

1. Fork or push this folder to GitHub under your own `owner/fable-kit`.
2. Make the repo **public** (required for the `curl | bash` one-liner — private repos can't serve `raw.githubusercontent.com`/`codeload.github.com` without auth).
3. Update the `REPO=` default at the top of `install.sh`, and replace every `reyco1` (or `OWNER`) reference in this README and in `templates/GETTING-STARTED.md` with your slug.
4. Push, wait a couple minutes for the CDN (see Troubleshooting above), then test the one-liner yourself before handing it to your team.
