# ADR-0001: Use `# pinned: <reason>` as the intentional-version-hold marker

**Status:** Accepted

## Context

The `setup-pre-commit-hooks` skill's verify mode compares each `rev:` value in a repo's `.pre-commit-config.yaml` against the canonical snippet library and flags stale pins. Some pins are deliberate — a specific version is held back for a known reason (compatibility constraint, upstream breakage, pending migration). Without a convention, verify mode would produce noise for these cases and train users to ignore its output.

## Decision

Use `# pinned: <reason>` as an inline comment on the `rev:` line to mark an intentional version hold:

```yaml
- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.4.0  # pinned: needs Python 3.8 compat until ApprovalTests migrates
```

Verify mode reads this comment, suppresses the stale-rev warning for that entry, and displays the reason instead.

## Alternatives considered

**Bare comment** — any comment on the `rev:` line is treated as an intentional pin. Rejected: too loose. Comments like `# 100MB` already appear on other lines for unrelated reasons; a bare-comment convention would produce false suppressions and is not grep-able.

**Separate lockfile** — a companion file (e.g. `.pre-commit-pins.yaml`) listing intentional holds. Rejected: extra indirection, harder to read alongside the config, requires the skill to manage two files.

**No mechanism** — accept ongoing verify noise for deliberate pins. Rejected: trains users to ignore verify output, defeating its purpose.

## Consequences

- Once repos use `# pinned:` comments, changing the marker syntax silently breaks existing pins (verify resumes flagging them as stale with no warning). This is why the decision is recorded here.
- The marker is grep-able: `grep -r '# pinned:' .` lists all intentional holds across a repo.
- The reason field is freeform prose — no schema enforcement, by design.
