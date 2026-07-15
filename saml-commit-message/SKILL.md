---
name: saml-commit-message
description: >
  Writes git commit message.
---

Commit message should have the following format:

```
<jira-ticket> <commit-message-title>

<jira-ticket-url>
<commit-message-body>
```

If jira ticket is not found, omit the `<jira-ticket>` and `<jira-ticket-url>` lines:

```
<commit-message-title>

<commit-message-body>
```

Get jira ticket using `saml-jira-ticket` skill.
Get jira ticket url using `saml-jira-ticket-url` skill.
Write the message to `.git/GITGUI_MSG` file.
