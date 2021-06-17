# Run `make help` to display help

# --- Global -------------------------------------------------------------------

all: check format  ## check and format
	@if [ -e .git/rebase-merge ]; then git --no-pager log -1 --pretty='%h %s'; fi
	@echo '$(COLOUR_GREEN)Success$(COLOUR_NORMAL)'

check:  ## Lint and check format of shell scripts
	shellcheck *.sh
	shfmt -i 4 -d *.sh

format:  ## Format shell scripts
	shfmt -i 4 -w *.sh

.PHONY: all check format

# --- Release -------------------------------------------------------------------
NEXT_TAG := $(shell { git tag --list --merged HEAD --sort=-v:refname; echo v0.0.0; } | grep -E "^v?[0-9]+.[0-9]+.[0-9]+$$" | head -n1 | awk -F . '{ print $$1 "." $$2 "." $$3 + 1 }')
MAJOR_RELEASE := $(firstword $(subst ., ,$(NEXT_TAG)))

release:  ## Tag release
	git tag --annotate --message "Release $(NEXT_TAG)" $(NEXT_TAG)
	git push origin $(NEXT_TAG)
	git branch -f $(MAJOR_RELEASE)
	git push origin $(MAJOR_RELEASE)

.PHONY: release

# --- Utilities ----------------------------------------------------------------
COLOUR_NORMAL = $(shell tput sgr0 2>/dev/null)
COLOUR_RED    = $(shell tput setaf 1 2>/dev/null)
COLOUR_GREEN  = $(shell tput setaf 2 2>/dev/null)
COLOUR_WHITE  = $(shell tput setaf 7 2>/dev/null)

help:
	@awk -F ':.*## ' 'NF == 2 && $$1 ~ /^[A-Za-z0-9%_-]+$$/ { printf "$(COLOUR_WHITE)%-25s$(COLOUR_NORMAL)%s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: help
