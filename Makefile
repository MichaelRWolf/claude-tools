CLAUDE_COMMANDS := $(HOME)/.claude/commands
COMMANDS := $(wildcard commands/*.md)
LINKS := $(patsubst commands/%.md,$(CLAUDE_COMMANDS)/%.md,$(COMMANDS))

CLAUDE_SKILLS := $(HOME)/.claude/skills
SKILLS_SRC    := $(wildcard skills/*)
SKILL_LINKS   := $(patsubst skills/%,$(CLAUDE_SKILLS)/%,$(SKILLS_SRC))

# Daylite local MCP (Daylite.app 2026.44 Direct+). See docs/adr/0003-mcp-registration-is-a-recipe.md
DAYLITE_BRIDGE  := /Applications/Daylite.app/Contents/MacOS/DayliteMCPBridge
DAYLITE_MCPB    := /Applications/Daylite.app/Contents/Resources/Daylite.mcpb
CLAUDE_APP_EXT  := $(HOME)/Library/Application Support/Claude/Claude Extensions/local.mcpb.marketcircle.daylite

# Usage: make protect REPO=MichaelRWolf/repo-name
REPO ?= $(error REPO is required: make protect REPO=owner/repo-name)

.PHONY: install uninstall status protect setup-hooks install-mcp uninstall-mcp

install: $(CLAUDE_COMMANDS) $(LINKS) $(CLAUDE_SKILLS) $(SKILL_LINKS) install-mcp
	@echo "Installed $(words $(LINKS)) command(s) and $(words $(SKILL_LINKS)) skill(s)"

$(CLAUDE_COMMANDS):
	mkdir -p $@

$(CLAUDE_COMMANDS)/%.md: commands/%.md
	ln -sf $(abspath $<) $@
	@echo "  linked command: $(@F)"

$(CLAUDE_SKILLS):
	mkdir -p $@

$(CLAUDE_SKILLS)/%: skills/%
	ln -sf $(abspath $<) $@
	@echo "  linked skill:   $(@F)"

uninstall: uninstall-mcp
	@for f in $(LINKS); do \
		[ -L "$$f" ] && rm "$$f" && echo "  removed command: $$(basename $$f)" || true; \
	done
	@for f in $(SKILL_LINKS); do \
		[ -L "$$f" ] && rm "$$f" && echo "  removed skill:   $$(basename $$f)" || true; \
	done

install-mcp:
	@if ! command -v claude >/dev/null 2>&1; then \
		echo "skip: claude CLI not installed"; \
	elif [ ! -x "$(DAYLITE_BRIDGE)" ]; then \
		echo "skip: Daylite bridge missing ($(DAYLITE_BRIDGE))"; \
	elif claude mcp get daylite >/dev/null 2>&1; then \
		echo "ok:   claude(1) daylite already registered"; \
	else \
		claude mcp add --scope user daylite -- "$(DAYLITE_BRIDGE)" && echo "added: claude(1) daylite (user scope)"; \
	fi
	@if [ -d "$(CLAUDE_APP_EXT)" ]; then \
		echo "ok:   Claude.app daylite extension installed"; \
	elif [ -f "$(DAYLITE_MCPB)" ]; then \
		echo "open: click Install in Claude.app, then quit and reopen it once"; \
		open "$(DAYLITE_MCPB)"; \
	else \
		echo "skip: Daylite.mcpb missing (turn on AI Integration in Daylite first)"; \
	fi

uninstall-mcp:
	@if command -v claude >/dev/null 2>&1 && claude mcp get daylite >/dev/null 2>&1; then \
		claude mcp remove daylite -s user; \
	else \
		echo "skip: claude(1) daylite not registered"; \
	fi
	@echo "note: remove the Claude.app extension in Claude.app > Settings > Extensions"

protect:
	gh api repos/$(REPO)/branches/main/protection \
	  --method PUT \
	  --field required_status_checks=null \
	  --field enforce_admins=true \
	  --field required_pull_request_reviews=null \
	  --field restrictions=null \
	  --field allow_force_pushes=false \
	  --field allow_deletions=false
	@echo "Protected main branch of $(REPO)"

status:
	@echo "Commands dir: $(CLAUDE_COMMANDS)"
	@for f in $(LINKS); do \
		if [ -L "$$f" ]; then echo "  [linked]  $$(basename $$f)"; \
		else echo "  [missing] $$(basename $$f)"; fi; \
	done
	@echo "Skills dir:   $(CLAUDE_SKILLS)"
	@for f in $(SKILL_LINKS); do \
		if [ -L "$$f" ]; then echo "  [linked]  $$(basename $$f)"; \
		else echo "  [missing] $$(basename $$f)"; fi; \
	done

	@echo "MCP daylite (claude(1)):"; \
	if command -v claude >/dev/null 2>&1 && claude mcp get daylite >/dev/null 2>&1; then echo "  [registered] user scope"; else echo "  [missing]"; fi
	@echo "MCP daylite (Claude.app):"; \
	if [ -d "$(CLAUDE_APP_EXT)" ]; then echo "  [installed]"; else echo "  [missing]"; fi
	@if [ ! -x "$(DAYLITE_BRIDGE)" ]; then echo "MCP daylite: [bridge missing] $(DAYLITE_BRIDGE)"; fi

setup-hooks:
	pre-commit install
