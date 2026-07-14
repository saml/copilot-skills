---
name: saml-jira-ticket
description: >
  Gets jira ticket from git branch name.
---

Use the following command to extract the jira ticket from the current git branch name:

```sh
git rev-parse --abbrev-ref HEAD | grep -oE '[A-Z]+-[0-9]+'
```
