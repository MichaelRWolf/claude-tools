---
name: setup-pre-commit-hooks
description: Prompt-driven skill for assembling .pre-commit-config.yaml from canonical YAML snippets. Supports initial setup (new repos) and verify mode (existing configs). Uses the Python pre-commit framework, not Husky. Run in any repo before first commit, or to health-check an existing config against the canonical snippet library. Includes opt-in scoped snippets (e.g., JSON normalization) for targeted use.
---

# setup-pre-commit-hooks

Assembles or verifies `.pre-commit-config.yaml` from canonical snippets stored in this skill's `snippets/` directory.

## Detect mode

### Step 1 -- Auto-detect categories

Inspect the repo to pre-select applicable snippet categories:

**Standard snippets** (auto-detected; safe to apply broadly):

| Signal                                 | Pre-select              |
|----------------------------------------|-------------------------|
| Any `.md` files present                | `universal`, `markdown` |
| Any `.py` files present                | `python`                |
| `home/` directory present              | `shell-dotfiles`        |
| Any shell files (`.sh`, shebang lines) | `shell`                 |
| Any `.org` files present               | `local-guards`          |

**Opt-in snippets** (never pre-selected; offer separately after the standard checklist):

| Signal                       | Snippet | Why opt-in                                                                                    |
|------------------------------|---------|-----------------------------------------------------------------------------------------------|
| `.claude/` directory present | `json`  | Scoped to `.claude/*.json` by default; broader scope risks `package-lock.json` and data blobs |

Pre-selection behavior differs per flow:

- **Initial Setup**: pre-select based on detected signals; present checklist for confirmation
- **Verify**: categories already active in the current config are pre-selected; signal-detected categories not in the config are offered as additions

### Step 2 -- Branch

**If `.pre-commit-config.yaml` does not exist** → run Initial Setup flow.

**If `.pre-commit-config.yaml` exists** → run Verify flow.

---

## Initial Setup flow

### Step 1 -- Assemble config

Read each selected snippet file from `snippets/`. Each file is a self-contained `repos:` list. Merge all `repos:` entries into one final config, preserving order: universal → markdown → python → shell → shell-dotfiles → local-guards.

Consolidate `local` repo entries: if multiple snippets contribute local hooks, merge them into a single `- repo: local` block.

### Step 2 -- Show draft and confirm

Display the assembled `.pre-commit-config.yaml` and a confirmation checklist:

- Write `.pre-commit-config.yaml`?
- Run `pre-commit autoupdate` to fetch latest revs? (recommended -- snippets may have stale pins)
- Then: run [Post-Config-Change Sequence](#post-config-change-sequence)?

After the standard checklist, show any detected opt-in snippets as a separate section:

```text
Optional / scoped snippets (not included above):
  [ ] json  -- pretty-format-json scoped to .claude/*.json
              (broaden files: pattern if you want wider JSON normalization)
```

If the user selects an opt-in snippet, add it to the assembled config and re-display the draft before writing.

### Step 3 -- Write and run

Execute confirmed actions in order: write config → autoupdate → Post-Config-Change Sequence.

### Note on `shell-dotfiles` category

The `shell-dotfiles` snippet names specific file paths (`home/.aliases`, etc.) matching the Portable_Profile repo. If installing in a different dotfiles repo, edit the `files:` patterns in the snippet before or after writing. The skill will note this when `shell-dotfiles` is selected.

---

## Verify flow

### Step 1 -- Diff against canonical snippets

For each repo entry in the current config:

1. **Match to a snippet** -- identify which snippet file it belongs to
2. **Check `rev:`** -- if it differs from the snippet's rev:
   - If the `rev:` line has a `# pinned: <reason>` comment → show as intentionally pinned, display reason, skip stale warning
   - Otherwise → flag as stale, show current vs canonical rev
3. **Missing hooks** -- hooks present in a matched snippet but absent from the current config → flag
4. **Unrecognized hooks** -- present in current config but not in any snippet → flag; suggest canonical equivalent where the purpose is obvious (e.g. `prettier-markdown` → `markdown-table-formatter`, `black` → `ruff-format`)

After reporting drift on standard snippets, check for opt-in snippets: if a detected signal is present (e.g., `.claude/` directory) and the corresponding opt-in snippet is absent from the config, surface it as an available addition:

```text
Optional snippets not in config:
  json  -- pretty-format-json (.claude/*.json) -- add?
```

### Step 2 -- Report drift

Show a structured drift report. Example format:

```text
ruff-pre-commit:  rev v0.4.0 → canonical v0.11.2  [stale]
markdownlint-cli: rev v0.48.0 → canonical v0.48.0  [ok]
prettier-markdown: unrecognized -- consider migrating to markdown-table-formatter (canonical)
```

If no drift: "Config matches canonical snippets. No changes needed."

### Step 3 -- Makefile check

Always run, regardless of drift. See [Makefile Check Procedure](#makefile-check-procedure).

Prompt (explicit yes/no): run `make setup-hooks` (or `pre-commit install` if no Makefile)?
If yes → run it.

### Step 4 -- Apply updates

User says "write" to apply selected updates. Show diff before writing. Never write without explicit confirmation.

### Step 5 -- Post-write actions

If changes were written to `.pre-commit-config.yaml`, prompt (explicit yes/no): stage and commit `.pre-commit-config.yaml`?
If yes → stage and commit.

---

## Post-Config-Change Sequence

Used by Initial Setup (Step 3) after `.pre-commit-config.yaml` is written. Verify handles this inline via its own Steps 3 and 5.

**Order is required**: hooks must be installed before the commit runs, so pre-commit uses the new config during the commit.

1. Run [Makefile Check Procedure](#makefile-check-procedure) and show recap
2. Prompt (explicit yes/no): run `make setup-hooks` (or `pre-commit install` if no Makefile)?
3. If yes → run it
4. Prompt (explicit yes/no): stage and commit `.pre-commit-config.yaml`?
5. If yes → stage and commit

Do not chain steps silently. Confirm each before running.

---

## Makefile Check Procedure

Check the repo for the `setup-hooks` target and report findings before offering options.

**Recap (always show):**

```text
Makefile present:       yes / no
setup-hooks target:     yes / no / n/a
```

**Then offer based on findings:**

| Makefile | Target | Action                                                     |
|----------|--------|------------------------------------------------------------|
| yes      | yes    | Use `make setup-hooks` as-is                               |
| yes      | no     | Offer to add `setup-hooks` target; show proposed addition  |
| no       | n/a    | Offer to create `Makefile` with target; show proposed file |

If user declines the Makefile offer → fall back to `pre-commit install` directly with a note.

**Canonical `setup-hooks` target:**

```makefile
.PHONY: setup-hooks
setup-hooks:
    pre-commit install
```

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

**Standard snippets** (auto-detected):

| File                  | Contents                                                                              |
|-----------------------|---------------------------------------------------------------------------------------|
| `universal.yaml`      | `check-added-large-files` (100MB), `texthooks` (ligatures/smartquotes/unicode-dashes) |
| `markdown.yaml`       | `markdownlint-fix`, `markdown-table-formatter`                                        |
| `python.yaml`         | `ruff` + `ruff-format`                                                                |
| `shell.yaml`          | `shellcheck-shell` (typed file detection)                                             |
| `shell-dotfiles.yaml` | `shellcheck-bash-startup` + `shellcheck-profile` (named files, dotfiles repos only)   |
| `local-guards.yaml`   | `forbid-org-files`                                                                    |

**Opt-in snippets** (offered separately; never auto-selected; review `files:` scope before applying):

| File        | Contents                                                                             | Default scope         |
|-------------|--------------------------------------------------------------------------------------|-----------------------|
| `json.yaml` | `pretty-format-json` (`--autofix --sort-keys`) -- normalizes key order in JSON files | `.claude/*.json` only |

To add a new category: create a new snippet file, no other changes needed.

---

## Future expansion (not implemented)

- Publish as `npx skills@latest add MichaelRWolf/claude-tools` once stable
- Additional categories: `nodejs.yaml` (prettier/eslint), `ruby.yaml` (rubocop), `go.yaml` (gofmt)
- `local.yaml` slot for per-repo custom hooks not suited for the shared library
- Wolf-air guard: annotate hooks requiring source compilation; warn when on that host
