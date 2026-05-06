# Changelog

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
