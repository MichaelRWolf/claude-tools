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

**`commands/`** — single `.md` files, each containing the full prompt Claude receives when the user types `/<name>`. Use a command when the instructions are self-contained with no supporting files.

**`skills/`** — directories, each containing a `SKILL.md` (with YAML frontmatter) plus optional bundled assets. Skills are for instructions that depend on co-located files (snippets, templates, scripts). The skill directory itself is symlinked as a whole into `~/.claude/skills/`.

### setup-pre-commit-hooks skill

The only skill. It assembles or verifies `.pre-commit-config.yaml` from a canonical snippet library in `skills/setup-pre-commit-hooks/snippets/`. Each snippet is a standalone `repos:` YAML list for one logical category (`universal`, `markdown`, `python`, `shell`, `shell-dotfiles`, `local-guards`). To add a new category, add a snippet file — no other changes needed.

Key convention: `rev: <version>  # pinned: <reason>` suppresses stale-rev warnings in Verify mode. Documented in `docs/adr/0001-intentional-pin-marker.md`.

## Adding new artifacts

- **New command**: create `commands/<name>.md`, run `make install`
- **New skill**: create `skills/<name>/SKILL.md` (with frontmatter), run `make install`
- **New snippet category**: add `skills/setup-pre-commit-hooks/snippets/<category>.yaml`

## Domain language

See `CONTEXT.md` for definitions of *command*, *skill*, *snippet*, and *intentional pin*.
