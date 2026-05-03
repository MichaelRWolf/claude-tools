# Context: claude-tools

Personal tooling repo for Claude Code — custom skills and slash commands installed via symlinks from `~/.claude/`.

## Glossary

### Intentional pin

A `rev:` entry in `.pre-commit-config.yaml` annotated with `# pinned: <reason>` to signal that the version is deliberately held back and should not be treated as stale.

```yaml
- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.4.0  # pinned: needs Python 3.8 compat until ApprovalTests migrates
```

The `setup-pre-commit-hooks` skill's verify mode skips the stale-rev warning for intentional pins and displays the reason instead.

### Snippet

A self-contained YAML file under `skills/setup-pre-commit-hooks/snippets/` representing one logical group of pre-commit hooks. Each snippet is a valid `repos:` list that can be read, linted, and tested in isolation. The skill assembles a final `.pre-commit-config.yaml` by merging selected snippets' `repos:` lists.

### Skill

A directory under `skills/` containing a `SKILL.md` (with frontmatter) plus optional bundled assets (seed templates, snippets, scripts). Symlinked to `~/.claude/skills/` via `make install`. Invoked as `/skill-name` in Claude Code.

Use a skill (not a command) when supporting files must travel with the instructions.

### Command

A single `.md` file under `commands/`. Symlinked to `~/.claude/commands/` via `make install`. Invoked as `/command-name` in Claude Code.

Use a command (not a skill) when the instructions are fully self-contained with no supporting files.
