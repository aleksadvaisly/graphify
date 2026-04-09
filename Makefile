PYTHON := .venv/bin/python
PIP    := .venv/bin/pip

.DEFAULT_GOAL := help

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: ## Create .venv and install graphify in dev mode
	python3 -m venv .venv
	$(PIP) install -e ".[all]"
	@echo "\n  Done. Activate with: source .venv/bin/activate"

skills: $(PYTHON) ## Install skill + register in CLAUDE.md
	$(PYTHON) -m graphify install
	@echo "\n  Skill installed. Type /graphify . in Claude Code."

graph: $(PYTHON) ## Build knowledge graph (usage: make graph [/path/to/project])
	$(eval _path := $(or $(filter-out graph,$(MAKECMDGOALS)),.))
	claude -p "/graphify $(_path)" --allowedTools "Bash Edit Write Read Glob Grep Agent Skill"
	@echo "\n  Open $(abspath $(_path))/graphify-out/graph.html in a browser."

# Accept any path as a no-op target so make doesn't complain about missing rules
%:
	@true

test: $(PYTHON) ## Run tests
	$(PYTHON) -m pytest tests/ -q

clean: ## Remove .venv and graphify-out
	rm -rf .venv graphify-out

$(PYTHON):
	@echo "error: .venv not found - run 'make install' first" && exit 1

.PHONY: help install skills test clean graph
