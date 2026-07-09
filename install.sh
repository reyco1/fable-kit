#!/usr/bin/env bash
# fable-kit installer - works two ways:
#
#   A) Remote (the CLI you'll actually use):
#        curl -fsSL https://raw.githubusercontent.com/OWNER/fable-kit/main/install.sh | bash -s -- ~/path/to/project
#
#   B) Local clone:
#        git clone https://github.com/OWNER/fable-kit && ./fable-kit/install.sh ~/path/to/project
#
# What it sets up in the target project:
#   - CLAUDE.md operating mode at the project root
#   - 8 skills in .claude/skills/ (or ~/.claude/skills with --global-skills)
#   - knowledge wiki scaffold, PROJECT-LOCAL by default at <project>/wiki/
#     (committed with the repo so the whole team shares it; use --wiki PATH
#     to point at a personal/global vault instead, e.g. an Obsidian vault)
#   - .gitignore entry for .agent/ (working memory stays out of git; the wiki does not)
#   - docs/ with GETTING-STARTED and the skills roadmap
#
# Options:
#   TARGET_DIR        project folder to set up (default: current directory)
#   --wiki PATH       use an external wiki location instead of <project>/wiki
#   --global-skills   install skills to ~/.claude/skills (all projects)
#   --force           overwrite existing CLAUDE.md/docs (keeps .bak of CLAUDE.md)
#   --repo OWNER/NAME override the GitHub repo to fetch from (remote mode)
#   --ref  BRANCH     override the git ref to fetch (default: main)
#
# Safe to re-run: existing files are preserved unless --force is given.

set -euo pipefail

REPO="${FABLE_KIT_REPO:-OWNER/fable-kit}"   # <-- set to your GitHub slug after pushing
REF="${FABLE_KIT_REF:-main}"
TARGET="."
WIKI=""            # empty = project-local default, resolved after TARGET is known
GLOBAL_SKILLS=0
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wiki)          WIKI="$2"; shift 2 ;;
    --global-skills) GLOBAL_SKILLS=1; shift ;;
    --force)         FORCE=1; shift ;;
    --repo)          REPO="$2"; shift 2 ;;
    --ref)           REF="$2"; shift 2 ;;
    -h|--help)       grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)               TARGET="$1"; shift ;;
  esac
done

say()  { printf '  \033[32m✓\033[0m %s\n' "$1"; }
skip() { printf '  \033[33m•\033[0m %s\n' "$1"; }
die()  { printf '  \033[31m✗\033[0m %s\n' "$1" >&2; exit 1; }

# ---- Locate kit files: local checkout, or fetch from GitHub -------------------
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
CLEANUP=""
if [[ -z "$SRC" || ! -d "$SRC/templates" || ! -d "$SRC/skills" ]]; then
  # Remote mode (piped via curl, or script copied out of the repo)
  TMP="$(mktemp -d)"; CLEANUP="$TMP"
  TARBALL_URL="${FABLE_KIT_TARBALL:-https://codeload.github.com/$REPO/tar.gz/refs/heads/$REF}"
  echo "Fetching fable-kit from $REPO@$REF ..."
  curl -fsSL "$TARBALL_URL" -o "$TMP/kit.tar.gz" || die "could not download $TARBALL_URL"
  tar -xzf "$TMP/kit.tar.gz" -C "$TMP"
  SRC="$(find "$TMP" -maxdepth 2 -type d -name templates -print -quit | xargs dirname)"
  [[ -d "$SRC/templates" && -d "$SRC/skills" ]] || die "downloaded archive doesn't look like fable-kit"
fi
trap '[[ -n "$CLEANUP" ]] && rm -rf "$CLEANUP"' EXIT

# ---- Resolve paths -------------------------------------------------------------
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
if [[ -z "$WIKI" ]]; then
  WIKI="$TARGET/wiki"; WIKI_REF="wiki/ (relative to the project root)"; WIKI_LOCAL=1
else
  WIKI="${WIKI/#\~/$HOME}"; WIKI_REF="$WIKI"; WIKI_LOCAL=0
fi

echo ""
echo "fable-kit installer"
echo "  project : $TARGET"
echo "  wiki    : $WIKI $( [[ $WIKI_LOCAL -eq 1 ]] && echo '(project-local, shared via git)' )"
[[ $GLOBAL_SKILLS -eq 1 ]] && echo "  skills  : global (~/.claude/skills)" || echo "  skills  : project ($TARGET/.claude/skills)"
echo ""

# ---- 1. CLAUDE.md ---------------------------------------------------------------
if [[ -f "$TARGET/CLAUDE.md" && $FORCE -eq 0 ]]; then
  skip "CLAUDE.md already exists - left untouched (use --force to replace; a .bak is kept)"
else
  [[ -f "$TARGET/CLAUDE.md" ]] && cp "$TARGET/CLAUDE.md" "$TARGET/CLAUDE.md.bak" && skip "existing CLAUDE.md backed up to CLAUDE.md.bak"
  sed "s|__WIKI_PATH__|$WIKI_REF|g" "$SRC/templates/CLAUDE.md" > "$TARGET/CLAUDE.md"
  say "CLAUDE.md installed (wiki path baked in: $WIKI_REF)"
fi

# ---- 2. Skills --------------------------------------------------------------------
if [[ $GLOBAL_SKILLS -eq 1 ]]; then SKILLS_DEST="$HOME/.claude/skills"; else SKILLS_DEST="$TARGET/.claude/skills"; fi
mkdir -p "$SKILLS_DEST"
installed=0
for srcdir in "$SRC"/skills/*/; do
  name="$(basename "$srcdir")"
  if [[ -d "$SKILLS_DEST/$name" && $FORCE -eq 0 ]]; then
    skip "skill $name already present - left untouched"
  else
    rm -rf "$SKILLS_DEST/$name"; cp -r "$srcdir" "$SKILLS_DEST/$name"; installed=$((installed+1))
  fi
done
say "skills installed: $installed new/updated → $SKILLS_DEST"

# ---- 3. Wiki scaffold ---------------------------------------------------------------
mkdir -p "$WIKI/concepts" "$WIKI/daily"
if [[ -f "$WIKI/index.md" ]]; then
  skip "wiki index.md already exists - left untouched"
else
  cp "$SRC/templates/wiki/index.md" "$WIKI/index.md"
  say "wiki scaffold created at $WIKI"
fi

# ---- 4. .gitignore -------------------------------------------------------------------
if [[ -e "$TARGET/.gitignore" ]] && grep -qxF '.agent/' "$TARGET/.gitignore"; then
  skip ".gitignore already covers .agent/"
else
  printf '\n# Claude Code working memory (fable-kit) - the wiki/ folder is NOT ignored on purpose\n.agent/\n' >> "$TARGET/.gitignore"
  say ".agent/ added to .gitignore (wiki stays committed)"
fi

# ---- 5. Docs ---------------------------------------------------------------------------
mkdir -p "$TARGET/docs"
for doc in GETTING-STARTED.md FABLE-GAP-SKILLS-ROADMAP.md; do
  if [[ -f "$TARGET/docs/$doc" && $FORCE -eq 0 ]]; then
    skip "docs/$doc already exists - left untouched"
  else
    cp "$SRC/templates/$doc" "$TARGET/docs/$doc"; say "docs/$doc installed"
  fi
done

# ---- Done ------------------------------------------------------------------------------
cat <<EOF

Done. Next steps:
  1. cd "$TARGET" && claude
  2. Give it a real task WITH a success criterion, e.g.:
       "Add X. Success = command Y exits 0 and Z is observable."
  3. End big tasks with: "close out and compile what you learned into the wiki"
  4. Read docs/GETTING-STARTED.md for the full on-ramp.

Verify inside a session: /memory shows CLAUDE.md; ask "what skills do you have?"
EOF
