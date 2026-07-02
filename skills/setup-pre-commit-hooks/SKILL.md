---
name: setup-pre-commit-hooks
description: Scope to a single repo (arg or current dir) and configure .pre-commit-config.yaml. Detects hook categories, tracks stable versions, offers updates when behind, audits .gitattributes for byte-fidelity. Runs autonomously across shell loops.
args: "[repo_path]"
---

# setup-pre-commit-hooks

Assembles or verifies `.pre-commit-config.yaml` from snippets tracked to stable releases. Offers to update hooks when behind stable, and notifies when intentionally ahead. Also audits `.gitattributes` for byte-fidelity compliance (no implicit line-ending conversion).

## TL;DR

**What this skill does:**

- Manages pre-commit hook configuration (`.pre-commit-config.yaml`) from canonical YAML snippets
- Auto-detects which hooks your repo needs (markdown linting, Python formatting, shell linting, etc.)
- Audits `.gitattributes` to ensure binary files round-trip unchanged (per [Jay Bazuzi's byte-fidelity principle](https://jay.bazuzi.com/gitattributes/): "I can put a file in now and get it out later, unchanged")

**How to use:**

- Single repo (current dir): `claude /setup-pre-commit-hooks`
- Single repo (specified path): `claude /setup-pre-commit-hooks /path/to/repo`
- Batch via shell: Loop and call with different paths; each Claude session handles one repo autonomously
- Always scopes to exactly one repo; no multi-repo orchestration from Claude

**Key principle:** Snippets track the latest stable release for each hook. The skill offers to update pinned versions when behind stable, and notifies (at info level) when ahead of stable. Implicit git line-ending conversion (`text=auto`) silently corrupts binary files across platforms; this skill enforces explicit declarations: `* -text diff` to opt out of conversion, plus per-extension `binary` flags.

---

## Arguments

**`[repo_path]` (optional):**

- If provided: use that path as the target repo. Must be a git repository.
- If omitted: use the current working directory (must be a git repository).
- Always scopes to exactly one repo. No multi-repo orchestration.

**Usage in shell loops:**

```bash
for repo in /path/one /path/two /path/three; do
  cd "$repo" && claude /setup-pre-commit-hooks
done
```

Or pass the path as an argument (useful if you can't cd):

```bash
for repo in /path/one /path/two /path/three; do
  claude /setup-pre-commit-hooks "$repo"
done
```

Each Claude invocation handles one repo autonomously: detects files, applies safe defaults (update to stable, install hooks), and completes.

---

## Autonomous Mode

When called as part of a shell loop (or any non-interactive context), the skill applies **safe defaults**:

- **Version updates:** Always update hooks that are behind stable (unless explicitly pinned with `# pinned: <reason>`)
- **Hook installation:** Always run `make setup-hooks` or `pre-commit install` unless Makefile/hooks are missing
- **Gitattributes:** Apply canonical byte-fidelity template if missing; migrate weak `text=auto` to strong `* -text diff` if present
- **JSON formatting scope:** Default to "Safe only" tier (`.claude/`, `.vscode/`, config root level) if offered
- **No prompts for decisions:** The skill completes each step with output showing what was done

**Why:** Shell orchestration expects each invocation to complete independently without blocking for user input. Safe defaults ensure reasonable outcomes across diverse repos.

---

## Critical: When hooks run

**Analysis phase (Detect and Verify) is read-only. Never modify files based on hook state; never invoke `pre-commit run`.**

- **Analysis** (Detect, Verify): reads config and repo state to report drift. No mutations, no hook execution.
- **Hook execution** is owned exclusively by:
  - `git commit` (automatic, as pre-commit hook runs before commit)
  - Explicit user command: `pre-commit run` (if the user types it)
- **Hook execution is never implied** by analyzing the config or setting up new hooks. Configuring `.pre-commit-config.yaml` ≠ running the hooks.

This boundary ensures the skill is safe to run repeatedly without unexpected side effects.

---

## Detect mode

*In autonomous mode: Skip user confirmation steps. Auto-detect all applicable categories, pre-select safe defaults, and apply without prompts.*

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

| Signal                     | Snippet | Why opt-in                                                                                            |
|----------------------------|---------|-------------------------------------------------------------------------------------------------------|
| Any `*.json` files present | `json`  | Scope varies widely by repo; always run [JSON Scope Selection](#json-scope-selection) before applying |

Pre-selection behavior differs per flow:

- **Initial Setup**: pre-select based on detected signals; present checklist for confirmation
- **Verify**: categories already active in the current config are pre-selected; signal-detected categories not in the config are offered as additions

### Step 2 -- Branch

**If `.pre-commit-config.yaml` does not exist** → run Initial Setup flow.

**If `.pre-commit-config.yaml` exists** → run Verify flow.

---

## Version tracking strategy

Snippets are maintained to track the latest **stable** release for each hook repository. Stability is determined by GitHub's release classification: stable releases are those not marked as pre-release.

**Version states during Verify:**

- ⚠️ **Behind stable** (pinned < stable) -- actionable drift; offer to update
- ✅ **Current** (pinned = stable) -- no action needed
- ℹ️ **Ahead of stable** (pinned > stable) -- intentional (pre-release or held back); notify at info level
- 📌 **Pinned** (marked `# pinned: <reason>`) -- intentional lock; respect the pin, show reason

**How stable versions are determined:**

- Query GitHub API for each hook repo's latest release (non-prerelease)
- If the pinned version is marked with `# pinned: <reason>`, respect the intent and show reason
- If updating is offered and accepted, `pre-commit autoupdate` will fetch latest within the same major version (unless a new major is stable)

---

## Initial Setup flow

*In autonomous mode: Auto-detect categories, assemble config, run autoupdate, install hooks, apply gitattributes, and commit. No prompts.*

### Step 1 -- Assemble config

Read each selected snippet file from `snippets/`. Each file is a self-contained `repos:` list. Merge all `repos:` entries into one final config, preserving order: universal → markdown → python → shell → shell-dotfiles → local-guards.

Consolidate `local` repo entries: if multiple snippets contribute local hooks, merge them into a single `- repo: local` block.

### Step 2 -- Show draft and confirm

Display the assembled `.pre-commit-config.yaml` and a confirmation checklist:

- Write `.pre-commit-config.yaml`?
- Run `pre-commit autoupdate` to fetch latest revs? (recommended -- snippets may have stale pins)
- Then: run [Post-Config-Change Sequence](#post-config-change-sequence)?

After the standard checklist, offer any detected opt-in snippets. If any JSON files exist in the repo, run the [JSON Scope Selection](#json-scope-selection) procedure and incorporate the result before re-displaying the draft.

### Step 3 -- Write and run

Execute confirmed actions in order: write config → autoupdate → Post-Config-Change Sequence.

### Note on `shell-dotfiles` category

The `shell-dotfiles` snippet names specific file paths (`home/.aliases`, etc.) matching the Portable_Profile repo. If installing in a different dotfiles repo, edit the `files:` patterns in the snippet before or after writing. The skill will note this when `shell-dotfiles` is selected.

---

## Verify flow

*In autonomous mode: Skip all prompts. Report drift, then automatically update hooks behind stable (unless pinned), install hooks, apply gitattributes changes, and commit.*

### Step 1 -- Check version drift against stable

For each repo entry in the current config:

1. **Determine stable version** -- query GitHub for latest non-prerelease version of that hook repo
2. **Compare pinned to stable** -- classify into one of four states:
   - ⚠️ **Behind** (pinned < stable) → actionable; offer to update
   - ✅ **Current** (pinned = stable) → no action
   - ℹ️ **Ahead** (pinned > stable) → intentional; inform at info level
   - 📌 **Pinned** (marked `# pinned: <reason>`) → respect the pin, show reason
3. **Missing hooks** -- hooks present in matched snippet but absent from current config → flag
4. **Unrecognized hooks** -- present in current config but not in any snippet → flag; suggest canonical equivalent where obvious

After reporting version drift, check for opt-in snippets: if any JSON files exist and `pretty-format-json` is absent from the config, offer to add it via the [JSON Scope Selection](#json-scope-selection) procedure.

### Step 2 -- Report version drift

Show a structured drift report with version states. Example format:

```text
markdownlint-cli:       ⚠️  v0.48.0 < stable v0.49.0  [behind] -- offer to update
check-added-large-files: ✅ v6.0.0 = stable v6.0.0   [current]
texthooks:              ℹ️  v0.7.2 > stable v0.7.1   [ahead of stable]
ruff-pre-commit:        📌 v0.5.0  # pinned: waiting for Python 3.8 compat
prettier:               ⚠️  unrecognized -- not in canonical snippets
```

Report structure:

- **Behind:** show pinned, show stable, offer to update
- **Current:** show version, confirm no action needed
- **Ahead:** show pinned, show stable, info-level notification
- **Pinned:** show version and reason, skip any drift message
- **Unrecognized:** flag and suggest canonical equivalent if known

If no drift and all versions current: "All hooks are tracking stable. No changes needed."

### Step 3 -- Makefile and .gitattributes checks

Always run, regardless of drift.

1. Run [Makefile Check Procedure](#makefile-check-procedure) and show recap
2. Prompt (explicit yes/no): run `make setup-hooks` (or `pre-commit install` if no Makefile)?
3. If yes → run it
4. Run [.gitattributes Check Procedure](#gitattributes-check-procedure) and show recap
5. Prompt (explicit yes/no): apply any offered `.gitattributes` changes?
6. If yes → write and stage `.gitattributes`

### Step 4 -- Apply updates

User says "write" to apply selected updates to `.pre-commit-config.yaml`. Show diff before writing. Never write without explicit confirmation.

### Step 5 -- Post-write actions

If changes were written to `.pre-commit-config.yaml` or `.gitattributes`, prompt (explicit yes/no): stage and commit these changes?
If yes → stage and commit.

---

## JSON Scope Selection

Used whenever `pretty-format-json` is offered (Initial Setup or Verify). Produces a `files:` pattern (and optional `exclude:`) to insert into the snippet.

### Step 1 -- Scan and classify

Run: `find . -name "*.json" -not -path "./.git/*" -not -path "*/node_modules/*" | sort`

Classify every file found into one of three buckets:

**Never touch** (hard-exclude regardless of tier chosen):

| Pattern                                            | Reason                        |
|----------------------------------------------------|-------------------------------|
| `package-lock.json`, `yarn.lock.json`, `*.lock`    | Generated; must not be sorted |
| `node_modules/**`                                  | Third-party; never modify     |
| `dist/**`, `build/**`, `coverage/**`, `.bundle/**` | Generated output              |
| Files matching `*_\d{8}T\d{6}*.json`               | Timestamped data snapshots    |
| Files > 100 KB                                     | Likely data, not config       |

**Risky** (key order may be conventional or file is semi-generated):

| Pattern                                           | Reason                                    |
|---------------------------------------------------|-------------------------------------------|
| `package.json`                                    | Conventional key order (name/version/...) |
| `tsconfig*.json`, `jsconfig.json`                 | Some tools are order-sensitive            |
| `appsscript.json`, `*.clasp.json`                 | GAS manifests; unknown sensitivity        |
| Any JSON file under `Atlassian/`, `data/`, `tmp/` | Data blobs, not config                    |

**Safe** (normalizing sort order adds value, no known risk):

| Pattern                              | Reason             |
|--------------------------------------|--------------------|
| `.claude/*.json`                     | Claude config      |
| `.vscode/*.json`                     | VS Code config     |
| `.markdownlint.json`                 | Linting config     |
| `.eslintrc.json`, `.prettierrc.json` | Linting/fmt config |
| Other flat root-level config files   | Single-purpose     |

### Step 2 -- Show classified inventory

Display the full file list grouped by bucket, with counts:

```text
JSON files found (12 total):

Safe to normalize (4):
  .claude/settings.json
  .claude/settings.local.json
  .markdownlint.json
  .vscode/settings.json

Risky -- key order may be meaningful (3):
  package.json
  tsconfig.json
  appsscript.json

Never touch -- generated or data (5):
  package-lock.json           [generated]
  coverage/coverage-final.json  [generated]
  dist/appsscript.json        [generated]
  Atlassian/comments_parsed.json  [data]
  Atlassian/comments_parsed_tagged.json  [data]
```

### Step 3 -- Present scope tiers

Offer a numbered menu. Never-touch files are excluded from every tier.

```text
Select scope for pretty-format-json:

  0) None          -- skip this hook
  1) .claude/ only -- 2 files  (.claude/settings.json, ...)
  2) Safe only     -- 4 files  (adds .vscode/, .markdownlint.json, ...)
  3) Safe + risky  -- 7 files  (also includes package.json, tsconfig.json, ...)
  4) All JSON      -- 7 files  (same as 3; never-touch files always excluded)
  C) Custom        -- enter your own files: regex
```

Note: if "Safe + risky" and "All JSON" produce the same count (all non-never-touch files), collapse them into one option labeled "All (except never-touch)".

### Step 4 -- Derive files: pattern

**Tier 0** -- skip hook entirely (omit the hook from the config).

**Tier 1** -- `.claude/` only:

```yaml
files: '(^|/)\.claude/.*\.json$'
```

**Tier 2** -- safe files (`.claude/`, `.vscode/`, `.markdownlint.json`):

```yaml
files: '(^|/)\.(claude|vscode)/.*\.json$|(^|/)\.markdownlint\.json$'
```

**Tiers 3/4** -- all except never-touch (paths in `exclude:` derived from inventory):

```yaml
files: '\.json$'
exclude: '(package-lock|node_modules|dist|build|coverage)/.*'
```

**Tier C** -- user-supplied regex. Show a preview of matching files before confirming.

After tier selection, show the derived `files:` / `exclude:` lines and list which files **will** be acted on and which **will not**, so the user can verify before the snippet is written.

---

## Post-Config-Change Sequence

Used by Initial Setup (Step 3) after `.pre-commit-config.yaml` is written. Verify handles this inline via its own Steps 3 and 5.

**Order is required**: hooks must be installed before the commit runs, so pre-commit uses the new config during the commit.

1. Run [Makefile Check Procedure](#makefile-check-procedure) and show recap
2. Prompt (explicit yes/no): run `make setup-hooks` (or `pre-commit install` if no Makefile)?
3. If yes → run it
4. Run [.gitattributes Check Procedure](#gitattributes-check-procedure) and show recap
5. Prompt (explicit yes/no): apply any offered `.gitattributes` changes?
6. If yes → write and stage `.gitattributes`
7. Prompt (explicit yes/no): stage and commit `.pre-commit-config.yaml` (and `.gitattributes` if changed)?
8. If yes → stage and commit

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

## .gitattributes Check Procedure

Check the repo for byte-fidelity compliance per Jay Bazuzi's recommendation (<https://jay.bazuzi.com/gitattributes/>): no implicit line-ending conversion; all files round-trip unchanged.

**Recap (always show):**

```text
.gitattributes present:           yes / no
Byte-fidelity opt-out (* -text):  yes / no
Binary files found in repo:       <list of detected extensions>
Declared binary (unspecified):    <list of extensions unrecognized by git check-attr>
```

**Detection logic:**

Fixed known-binary extension list: `jpeg jpg png gif bmp ico zip gz tar 7z pdf docx doc xlsx xls pptx ppt woff woff2 ttf otf mp3 mp4 mov sqlite sqlite3 db`

1. Scan for files: `git ls-files | grep -E '\.(jpeg|jpg|...|db)$'` to find any binary-looking files tracked in the repo
2. For each file found, run `git check-attr binary -- <path>`
3. Classify results:
   - `set` → binary declaration exists, OK
   - `unset` → explicitly marked as text (may be intentional, e.g., `.html`)
   - `unspecified` → no rule found → **the bug class** (file is treated by git's `text=auto` heuristic)
4. Separately check `.gitattributes` for the pattern `^\*\s+-text` (strong opt-out via `* -text diff`) vs. relying on `text=auto` catch-all (weaker)

**Offer (explicit yes/no, never auto-write):**

If `.gitattributes` is missing entirely:

- Show the canonical template below
- Prompt: create `.gitattributes` with the template?
- **Important:** If user confirms → write `.gitattributes`, then **restart the skill from the beginning** (as though it's a fresh Detect mode invocation). The presence of a newly-committed `.gitattributes` may affect hook selection and other detection logic downstream.

If `.gitattributes` present but any detected binary files are unspecified:

- Show a diff-style preview of proposed additions
- Prompt: add the missing binary declarations?

If `.gitattributes` present, all detected binaries are declared, but using `* text=auto` instead of `* -text diff`:

- Explain the difference (heuristic vs. explicit opt-out)
- Show a preview of the migration
- Prompt: migrate to the stronger `* -text diff` form?

**Canonical `.gitattributes` template:**

```gitattributes
# No line-ending conversion ever. Bytes in = bytes out.
* -text diff

# Binary files: no diff display, no conversion.
*.jpeg binary
*.jpg  binary
*.png  binary
*.gif  binary
*.bmp  binary
*.ico  binary
*.zip  binary
*.gz   binary
*.tar  binary
*.7z   binary
*.pdf  binary
*.docx binary
*.doc  binary
*.xlsx binary
*.xls  binary
*.pptx binary
*.ppt  binary
*.woff binary
*.woff2 binary
*.ttf  binary
*.otf  binary
*.mp3  binary
*.mp4  binary
*.mov  binary
*.sqlite binary
*.sqlite3 binary
*.db   binary
```

**Reference:** See also Portable_Profile's git-templates (`~/repos/Portable_Profile/git/git-templates/info/attributes`) and `.gitattributes_global` for machine-local fallback defaults.

---

## Intentional pin convention

To keep a hook at a specific version despite a newer stable release, add a `# pinned: <reason>` comment on the same line as `rev:`:

```yaml
- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.4.0  # pinned: needs Python 3.8 compat until ApprovalTests migrates
```

Verify mode will display the reason and respect the pin (no update offer). This is useful for:

- Waiting for downstream projects to adopt a new major version
- Holding back a version with a known regression (not yet fixed in stable)
- Intentional version management (e.g., testing pre-releases on a branch)

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

| File        | Contents                                                                             | Scope                                                               |
|-------------|--------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| `json.yaml` | `pretty-format-json` (`--autofix --sort-keys`) -- normalizes key order in JSON files | Set interactively via [JSON Scope Selection](#json-scope-selection) |

To add a new category: create a new snippet file, no other changes needed.

---

## References

### Byte-fidelity and `.gitattributes`

**Jay Bazuzi's post on why implicit line-ending conversion is a problem:**
<https://jay.bazuzi.com/gitattributes/>

**Key argument:** Git's default `core.autocrlf` and implicit `text=auto` heuristic violate the round-trip guarantee: "I can put a file in now and get it out later, unchanged." This is especially dangerous for:

- Binary files (can be silently corrupted)
- Scripts requiring specific line endings (e.g., Windows `.cmd` files requiring CRLF, or shebang scripts requiring LF)
- Cross-platform projects where different contributors have different `core.autocrlf` settings

**Solution:** Commit a `.gitattributes` file with explicit rules:

- `* -text diff` -- opt out of all implicit conversion
- Per-extension `binary` declarations for known binary types
- Per-extension `text eol=lf` for files that must be LF (e.g., shell scripts, RFC 4180 CSV)

This skill's `.gitattributes Check Procedure` enforces these conventions and helps repos bootstrap and maintain the file.

---

## Future expansion (not implemented)

- Publish as `npx skills@latest add MichaelRWolf/claude-tools` once stable
- Additional categories: `nodejs.yaml` (prettier/eslint), `ruby.yaml` (rubocop), `go.yaml` (gofmt)
- `local.yaml` slot for per-repo custom hooks not suited for the shared library
- Wolf-air guard: annotate hooks requiring source compilation; warn when on that host
