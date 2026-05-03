---
name: setup-pre-commit-hooks
description: Prompt-driven skill for assembling .pre-commit-config.yaml from canonical YAML snippets. Supports initial setup (new repos) and verify mode (existing configs). Uses the Python pre-commit framework, not Husky. Run in any repo before first commit, or to health-check an existing config against the canonical snippet library.
---

# setup-pre-commit-hooks

Assembles or verifies `.pre-commit-config.yaml` from canonical snippets stored in this skill's `snippets/` directory.

## Detect mode

**If `.pre-commit-config.yaml` does not exist** → run Initial Setup flow.

**If `.pre-commit-config.yaml` exists** → run Verify flow.

---

## Initial Setup flow

### Step 1 — Auto-detect categories

Inspect the repo to pre-select applicable snippet categories:

| Signal                                 | Pre-select              |
|----------------------------------------|-------------------------|
| Any `.md` files present                | `universal`, `markdown` |
| Any `.py` files present                | `python`                |
| `home/` directory present              | `shell-dotfiles`        |
| Any shell files (`.sh`, shebang lines) | `shell`                 |
| Any `.org` files present               | `local-guards`          |

Present the pre-filled checklist to the user for confirmation. They may add or remove categories before proceeding.

### Step 2 — Assemble config

Read each selected snippet file from `snippets/`. Each file is a self-contained `repos:` list. Merge all `repos:` entries into one final config, preserving order: universal → markdown → python → shell → shell-dotfiles → local-guards.

Consolidate `local` repo entries: if multiple snippets contribute local hooks, merge them into a single `- repo: local` block.

### Step 3 — Show draft and confirm

Display the assembled `.pre-commit-config.yaml` and a confirmation checklist:

- Write `.pre-commit-config.yaml`?
- Run `pre-commit autoupdate` to fetch latest revs? (recommended — snippets may have stale pins)
- Run `make setup-hooks` to activate hooks? (recommended)

For the `make setup-hooks` item, check first:
- `Makefile` exists with `setup-hooks` target → use it as-is
- `Makefile` exists without `setup-hooks` → offer to add the target; show the proposed addition
- No `Makefile` → offer to create one with the target; show the proposed file

If the user declines the Makefile offer, fall back to `pre-commit install` directly with a note.

### Step 4 — Write and run

Execute confirmed actions in order: write config → autoupdate → setup-hooks (or pre-commit install).

### Note on `shell-dotfiles` category

The `shell-dotfiles` snippet names specific file paths (`home/.aliases`, etc.) matching the Portable_Profile repo. If installing in a different dotfiles repo, edit the `files:` patterns in the snippet before or after writing. The skill will note this when `shell-dotfiles` is selected.

---

## Verify flow

### Step 1 — Auto-detect categories

Same detection logic as Initial Setup. Categories that appear active in the current config are pre-selected; others are offered as additions.

### Step 2 — Diff against canonical snippets

For each repo entry in the current config:

1. **Match to a snippet** — identify which snippet file it belongs to
2. **Check `rev:`** — if it differs from the snippet's rev:
   - If the `rev:` line has a `# pinned: <reason>` comment → show as intentionally pinned, display reason, skip stale warning
   - Otherwise → flag as stale, show current vs canonical rev
3. **Missing hooks** — hooks present in a matched snippet but absent from the current config → flag
4. **Unrecognized hooks** — present in current config but not in any snippet → flag; suggest canonical equivalent where the purpose is obvious (e.g. `prettier-markdown` → `markdown-table-formatter`, `black` → `ruff-format`)

### Step 3 — Report drift

Show a structured drift report. Example format:

```
ruff-pre-commit:  rev v0.4.0 → canonical v0.11.2  [stale]
markdownlint-cli: rev v0.48.0 → canonical v0.48.0  [ok]
prettier-markdown: unrecognized — consider migrating to markdown-table-formatter (canonical)
```

If no drift: "Config matches canonical snippets. No changes needed."

### Step 4 — Apply updates

User says "write" to apply selected updates. Show diff before writing. Never write without explicit confirmation.

---

## Intentional pin convention

To suppress a stale-rev warning for a deliberately held-back version, add a `# pinned: <reason>` comment on the same line as `rev:`:

```yaml
- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.4.0  # pinned: needs Python 3.8 compat until ApprovalTests migrates
```

Verify mode will display the reason and skip the stale warning for that entry.

---

## Snippet library

Snippets live in `snippets/` alongside this file. Each is a self-contained `repos:` YAML list.

| File                  | Contents                                                                              |
|-----------------------|---------------------------------------------------------------------------------------|
| `universal.yaml`      | `check-added-large-files` (100MB), `texthooks` (ligatures/smartquotes/unicode-dashes) |
| `markdown.yaml`       | `markdownlint-fix`, `markdown-table-formatter`                                        |
| `python.yaml`         | `ruff` + `ruff-format`                                                                |
| `shell.yaml`          | `shellcheck-shell` (typed file detection)                                             |
| `shell-dotfiles.yaml` | `shellcheck-bash-startup` + `shellcheck-profile` (named files, dotfiles repos only)   |
| `local-guards.yaml`   | `forbid-org-files`                                                                    |

To add a new category: create a new snippet file, no other changes needed.

---

## Future expansion (not implemented)

- Publish as `npx skills@latest add MichaelRWolf/claude-tools` once stable
- Additional categories: `nodejs.yaml` (prettier/eslint), `ruby.yaml` (rubocop), `go.yaml` (gofmt)
- `local.yaml` slot for per-repo custom hooks not suited for the shared library
- Wolf-air guard: annotate hooks requiring source compilation; warn when on that host
