# ADR-0003: MCP registration is a recipe, not a tracked state file

**Status:** Accepted

## Context

Claude.app and claude(1) each keep MCP registrations in app-managed state: `~/.claude.json` (claude(1), mixed with session and project data) and Claude.app's `Claude Extensions` directory. Neither can be symlinked from a repo without tracking data that churns.

## Decision

Track the recipe, not the state. `make install-mcp` runs the standard commands: `claude mcp add --scope user daylite -- <bridge>` for claude(1), and opens `Daylite.mcpb` for Claude.app. The Daylite bridge path lives in one variable. `make status` reports drift, including a missing bridge.

## Alternatives considered

**Symlink `~/.claude.json` or the extension directory** -- rejected. Both are app-managed and would track unrelated data.

**Hand-written JSON snippet in the repo** -- rejected. It duplicates what `claude mcp add` already writes and can drift from the format the CLI expects.

## Consequences

- Install and uninstall stay standard CLI calls, so a future Claude or Daylite release that changes the format does not break the repo.
- Claude.app's extension install requires one manual click, because Claude.app owns that step.
