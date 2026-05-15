# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
make install    # symlink commands/ and skills/ into ~/.claude/
make uninstall  # remove those symlinks
make status     # show linked vs missing for each artifact
```

No build step, no test runner. The artifacts are Markdown files; correctness is validated by reading them.

## Architecture

Two artifact types live under two directories and are installed via symlinks into `~/.claude/`:

**`commands/`** -- single `.md` files, each containing the full prompt Claude receives when the user types `/<name>`. Use a command when the instructions are self-contained with no supporting files.

**`skills/`** -- directories, each containing a `SKILL.md` (with YAML frontmatter) plus optional bundled assets. Skills are for instructions that depend on co-located files (snippets, templates, scripts). The skill directory itself is symlinked as a whole into `~/.claude/skills/`.

### setup-pre-commit-hooks skill

Assembles or verifies `.pre-commit-config.yaml` from a canonical snippet library in `skills/setup-pre-commit-hooks/snippets/`. Each snippet is a standalone `repos:` YAML list for one logical category (`universal`, `markdown`, `python`, `shell`, `shell-dotfiles`, `local-guards`). To add a new category, add a snippet file -- no other changes needed.

Key convention: `rev: <version>  # pinned: <reason>` suppresses stale-rev warnings in Verify mode. Documented in `docs/adr/0001-intentional-pin-marker.md`.

### extract-rainbow-springs-reservation skill

Extracts Florida State Parks day-use vehicle entry reservations from Payment Summary screenshots and copies them as CSV. Bundled with `reservations.js` -- a Google Apps Script for the destination Sheets tab (copy-paste into **Extensions → Apps Script**; no clasp/deploy needed). Skill (not command) so the prompt and the Apps Script travel together.

## Adding new artifacts

- **New command**: create `commands/<name>.md`, run `make install`
- **New skill**: create `skills/<name>/SKILL.md` (with frontmatter), run `make install`
- **New snippet category**: add `skills/setup-pre-commit-hooks/snippets/<category>.yaml`

## Domain language

See `CONTEXT.md` for definitions of *command*, *skill*, *snippet*, and *intentional pin*.

## Agent skills

### Issue tracker

Issues live in GitHub Issues on MichaelRWolf/claude-tools. See `docs/agents/issue-tracker.md`.

### Triage labels

Default canonical label strings -- no overrides. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context -- `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
