# Changelog

## 2026-07-01

### setup-pre-commit-hooks / verify mode

#### Analysis phase unexpectedly executed hooks (issue #4)

During verify mode refinement, the skill ran `pre-commit` hooks against an unrelated repo (Job_Search), reformatting markdown files. User had to `git checkout -- .` to revert.

**Root cause:** Nothing explicitly forbade an agent from interpreting "verify the config" as "run the hooks to check if they work." The Detect and Verify flows are inspection/reporting only and should never execute hooks.

**Resolution:** (1) Added "Critical: When hooks run" section to SKILL.md (lines 27-38) stating analysis is read-only and hooks only run via `git commit` or explicit user `pre-commit run`. (2) Added ADR-0002 (`docs/adr/0002-analysis-is-read-only.md`) to record why this boundary must hold, so future edits don't silently regress it. (3) No code changes to the Detect/Verify flows themselves - the gap was interpretive (missing guardrail prose), not procedural.

---

## 2026-05-06

### setup-pre-commit-hooks / markdown snippet

**Hook conflict: `markdownlint-fix` vs `markdown-table-formatter`**

`markdown-table-formatter` 1.7.0 produces tables with a mixed style: aligned
data rows (`| text |`) but tight separator rows (`|---|`). This is not a
recognized consistent style per markdownlint MD060 (`table-column-style`).
Result: each hook run, one tool "fixed" what the other had just set -- an
infinite loop that blocked commits.

**Resolution:** disable MD060 in the repo's `.markdownlint.json` (the tool
config file), not in the hook invocation args. The formatter is the authority
on table layout; MD060 has nothing useful to add when a formatter is already
running. The snippet now carries a `companion:` comment noting that any repo
using the markdown snippet must have `"MD060": false` in `.markdownlint.json`.
