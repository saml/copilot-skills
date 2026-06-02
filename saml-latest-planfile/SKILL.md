---
name: saml-latest-planfile
description: >
  Finds the latest plan file in `./.plan/` directory (excludes *.review.md and *.fixplan.md).
  Trigger this automatically when you need to locate the latest plan file.
---

Find the latest plan file using the following script:

```bash
#!/usr/bin/env bash
files=( ./.plan/2*.md )
echo "${files[-1]}"
```

Exclude files matching `*.review.md` and `*.fixplan.md`.

If no plan file is found (the glob returns the literal pattern), stop with:
"❌ No plan file found. Run `saml-plan` first."

Otherwise, return the file path.
