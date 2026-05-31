---
name: saml-scaffold
description: >
  Scaffolds a new project.
---

# linter and formatter

Ask user which linter and formatter they want to use.
Recommend a good linter and formatter for the project.

# AGENTS.md and memory files

Create `AGENTS.md` file if it does not exist.

`AGENTS.md` should something like:

```markdown
# Workflow

- Use tdd.
- Use domain drive design.
- Use deep modules.
- Do not `git commit`.
- Update referenced memory files. Or, create new memory file if needed.

# Memory file references

- Build [./agents/build.md](./agents/build.md)
- Test [./agents/test.md](./agents/test.md)
- Run [./agents/run.md](./agents/run.md)
```

Doesn't have to follow this template as-is, especially for existing projects.
If there are already existing memory files that could be refactored, refactor them and update `AGENTS.md` accordingly.

# .gitignore

`.gitignore` should have:

```
.plan/
```
