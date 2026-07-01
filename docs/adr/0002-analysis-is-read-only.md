# ADR-0002: Analysis phase must never execute hooks

**Status:** Accepted

## Context

The `setup-pre-commit-hooks` skill's Detect and Verify flows inspect `.pre-commit-config.yaml` and the repo's file state to auto-detect categories, report drift, and audit `.gitattributes` compliance. These flows are documentation-inspection and reporting steps -- they should never modify the working tree or execute pre-commit hooks.

In practice, nothing explicitly forbade an agent from interpreting "verify the config is correct" as license to actually run the hooks to see if they work. This interpretive gap caused issue #4: while a user was refining the skill's configuration, an agent ran hooks against an unrelated repo (Job_Search), reformatting markdown files, and the user had to `git checkout -- .` to revert.

## Decision

Analysis (Detect and Verify phases) is strictly read-only:

- Inspect and report: config state, drift vs. canonical snippets, `.gitattributes` compliance, Makefile presence.
- Never mutate files based on hook state.
- Never invoke `pre-commit run`, `pre-commit autoupdate`, or any hook-execution command.

Hook execution is owned exclusively by:

- Automatic: `git commit` (the pre-commit framework runs the installed hook before each commit)
- Manual: explicit user command: `pre-commit run` (if the user types it in a terminal)

Configuring `.pre-commit-config.yaml` does not imply running hooks. The SKILL.md section "Critical: When hooks run" (lines 27-38) is the enforcement point for this decision.

## Alternatives considered

**Rely on prose only, no ADR** -- rejected. The fix (SKILL.md's "Critical" section) is prose-only, and without a recorded rationale, a future edit could soften the wording ("check that hooks work by running them in dry-run mode") without realizing the safety implication. This repo already uses ADRs to record *why* a decision matters (see ADR-0001), so the same pattern applies here.

**Add a linter / test to enforce the boundary** -- rejected. This repo is prompt-only (no build, no test runner, no CI). The ADR serves as the durable record; the enforcement mechanism is review discipline (code review noticing if a future SKILL.md edit reintroduces ambiguity).

**Dry-run / check mode for Verify** -- rejected. Since analysis never executes hooks in the first place, a dry-run mode is unnecessary. The point is not to run hooks with `--check` vs. `--fix`; it's to not run them at all during analysis.

## Consequences

- Any future edit to SKILL.md's Detect or Verify sections must preserve the read-only / execution boundary. Future editors should reference this ADR if they consider adding hook-execution steps to those flows.
- The boundary is grep-able: `grep -rn "Critical: When hooks run" skills/setup-pre-commit-hooks/SKILL.md` confirms the enforcement text is present.
- If an agent is run in a repo using the skill, the agent's context includes SKILL.md's "Critical" section (lines 27-38), which states the boundary explicitly before the Detect flow begins. This is the primary safeguard against re-introducing the issue.
