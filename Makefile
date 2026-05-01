CLAUDE_COMMANDS := $(HOME)/.claude/commands
COMMANDS := $(wildcard commands/*.md)
LINKS := $(patsubst commands/%.md,$(CLAUDE_COMMANDS)/%.md,$(COMMANDS))

.PHONY: install uninstall status

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

status:
	@echo "Commands dir: $(CLAUDE_COMMANDS)"
	@for f in $(LINKS); do \
		if [ -L "$$f" ]; then echo "  [linked]  $$(basename $$f)"; \
		else echo "  [missing] $$(basename $$f)"; fi; \
	done
