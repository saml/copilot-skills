---
name: saml-memory
description: >
  Updates agent memory files.
  Trigger this automatically when agent memory needs to be updated.
---

Find appropriate memory file in `./agents` directory.
If appropriate memory file is not found, create a new memory file.
For example, if you want to update folder structure, but no memory file is found, create one: `./agents/folder-structure.md`.

Update the memory file with the new information.

Make sure to reference the memory file in `AGENTS.md`.

# AGENTS.md

`AGENTS.md` should be short and mostly have references to other memory files:

```markdown
# Workflow

...

# Memory file references

- Build [./agents/build.md](./agents/build.md)
- Test [./agents/test.md](./agents/test.md)
- Run [./agents/run.md](./agents/run.md)
- ...
```

This is not exact template. `AGENTS.md` can have more or less information. But it should mostly have references to other memory files.
If `AGENTS.md` is getting big, split into multiple memory files and have them referenced in `AGENTS.md`.

If memory files have out dated information, update them.
If they are no longer needed, delete them.
Memory files should be up to date and relevant to the project.

If memory files can be refactored, refactor them and update `AGENTS.md` accordingly.
