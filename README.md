# claude-tools

Personal Claude Code commands and tooling.

## Install

```bash
make install
```

Symlinks all `commands/*.md` files into `~/.claude/commands/`, making them available as slash commands in Claude Code.

## Uninstall

```bash
make uninstall
```

## Status

```bash
make status
```

## Commands

| Command | Description |
|---------|-------------|
| `/extract-rainbow-springs-reservation` | Extract Florida State Parks day-use reservation confirmations from screenshots → CSV in chat + clipboard |

## Daylite MCP

Connects Claude Code and Claude.app to Daylite's local MCP server.

- **MCP** (Model Context Protocol): an open standard that lets an AI app call a server's tools. Daylite's server is `DayliteMCPBridge`, inside `Daylite.app`. It runs locally over stdio and is only reachable from this Mac.
- **MCPB** (MCP Bundle): a `.mcpb` zip with a `manifest.json` that Claude.app installs as an extension. Daylite ships `Daylite.mcpb`.

Requirements: Daylite 2026.44 Direct or later (not the Mac App Store build), macOS Sequoia 15.2 or later, and a Daylite user with the Database Admin or Superuser role. Daylite must be running while in use.

1. Daylite > Settings > AI Integration: turn on "Allow AI apps to connect to Daylite".
2. `make install-mcp`: registers the bridge with claude(1) at user scope, and opens `Daylite.mcpb` for Claude.app if it is not installed yet.
3. Claude.app: click Install, then quit and reopen it once.

`make status` shows both clients. `make uninstall-mcp` removes the claude(1) registration; remove the Claude.app extension in Claude.app > Settings > Extensions.

## Adding a new command

1. Create `commands/<name>.md` — the file content is the prompt Claude receives
2. Run `make install` — symlink is created automatically
3. Use `/name` in Claude Code
