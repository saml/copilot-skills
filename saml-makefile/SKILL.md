---
name: saml-makefile
description: >
  Creates / updates a Makefile with common commands for the project.
---

Create `Makefile` if it does not exist.

Add common commands for the project in `Makefile`:

```
.PHONY: run
run:
  # command to run the project

.PHONY: test
test:
  # command to test the project

.PHONY: build
build:
  # command to build the project

.PHONY: lint
lint:
  # command to lint the project

.PHONY: format
format:
  # command to format the project
```

First command should be able to run the project. So that when user runs `make`, it should run the project.
Other commands are optional.

You can check AGENTS.md and memory files to find out commands to include to `Makefile`.
