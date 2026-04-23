---
name: saml-planfile
description: >
  Creates an empty plan file: `./.plan/YYYY-MM-DD-hh-mm-TITLE.md`.
  Trigger this automatically when plan file needs to be created.
---

Create the file named `./.plan/YYYY-MM-DD-hh-mm-TITLE.md` where `YYYY-MM-DD-hh-mm` part is current year month day hour minute.
And, `TITLE` part should be short title of the plan.
Make sure `TITLE` part does not contain white spaces. And `TITLE` part should be all lower case.

If the directory `./.plan` does not exist, create it first.
If the file already exists, noop.
