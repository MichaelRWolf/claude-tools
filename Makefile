CLAUDE_COMMANDS := $(HOME)/.claude/commands
COMMANDS := $(wildcard commands/*.md)
LINKS := $(patsubst commands/%.md,$(CLAUDE_COMMANDS)/%.md,$(COMMANDS))

# Usage: make protect REPO=MichaelRWolf/repo-name
REPO ?= $(error REPO is required: make protect REPO=owner/repo-name)

.PHONY: install uninstall status protect

install: $(CLAUDE_COMMANDS) $(LINKS)
	@echo "Installed $(words $(LINKS)) command(s) into $(CLAUDE_COMMANDS)"

$(CLAUDE_COMMANDS):
	mkdir -p $@

$(CLAUDE_COMMANDS)/%.md: commands/%.md
	ln -sf $(abspath $<) $@
	@echo "  linked: $(@F)"

uninstall:
	@for f in $(LINKS); do \
		[ -L "$$f" ] && rm "$$f" && echo "  removed: $$(basename $$f)" || true; \
	done

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
