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

## Adding a new command

1. Create `commands/<name>.md` — the file content is the prompt Claude receives
2. Run `make install` — symlink is created automatically
3. Use `/name` in Claude Code
