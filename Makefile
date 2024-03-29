# Run `make help` to display help

# --- Global -------------------------------------------------------------------

all: check  ## Lint and check format of shell scripts
	@if [ -e .git/rebase-merge ]; then git --no-pager log -1 --pretty='%h %s'; fi
	@echo '$(COLOUR_GREEN)Success$(COLOUR_NORMAL)'

.PHONY: all

# --- Lint  ---------------------------------------------------------------------
SH_FILES := howl

check:  ## Lint and check format of shell scripts
	shellcheck $(SH_FILES)
	shfmt -i 4 -d $(SH_FILES)

format:  ## Format shell scripts
	shfmt -i 4 -w *.sh

.PHONY: check format

# --- Release -------------------------------------------------------------------

release: nexttag ## Tag and create GitHub release
	git tag $(NEXTTAG)
	git push origin $(NEXTTAG)
	git branch -f $(MAJOR_RELEASE)
	git push origin $(MAJOR_RELEASE)
	{ \
	  $(if $(RELNOTES),cat $(RELNOTES);) \
	  echo "## Changelog"; \
	  git log --pretty="tformat:* %h %s" --no-merges --reverse $(or $(LAST_RELEASE),@^).. ; \
	} | gh release create $(NEXTTAG) --title $(NEXTTAG) --notes-file - howl

nexttag:
	$(eval LAST_RELEASE := $(shell $(LAST_RELEASE_CMD)))
	$(eval NEXTTAG := $(shell $(NEXTTAG_CMD)))
	$(eval MAJOR_RELEASE := $(shell echo $(NEXTTAG) | cut -d. -f1 ))
	$(eval RELNOTES := $(wildcard docs/release-notes/$(NEXTTAG).md))

.PHONY: nexttag release

LAST_RELEASE_CMD := gh release view --json tagName --jq .tagName 2>/dev/null
define NEXTTAG_CMD
{
  { git tag --list --merged HEAD --sort=-v:refname; echo v0.0.0; }
  | grep -E "^v?[0-9]+\.[0-9]+\.[0-9]+$$"
  | head -n 1
  | awk -F . '{ print $$1 "." $$2 "." $$3 + 1 }';
  git diff --name-only @^ | sed -E -n 's|^docs/release-notes/(v[0-9]+\.[0-9]+\.[0-9]+)\.md$$|\1|p';
} | sort --reverse --version-sort | head -n 1
endef

# --- Utilities ----------------------------------------------------------------
COLOUR_NORMAL = $(shell tput sgr0 2>/dev/null)
COLOUR_RED    = $(shell tput setaf 1 2>/dev/null)
COLOUR_GREEN  = $(shell tput setaf 2 2>/dev/null)
COLOUR_WHITE  = $(shell tput setaf 7 2>/dev/null)

help:
	@awk -F ':.*## ' 'NF == 2 && $$1 ~ /^[A-Za-z0-9%_-]+$$/ { printf "$(COLOUR_WHITE)%-25s$(COLOUR_NORMAL)%s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: help
