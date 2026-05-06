---
name: saml-epic
description: >
  Gets todo items from user and works on them one by one using `saml-plan` and `saml-implement`.
---

- Get list of things to do from user
- Ask all clarifying questions needed to disambiguate the items on the list, and to make sure you understand the requirements and acceptance criteria for each item.
- For each item in the list:
    - `/clear` the context to start fresh on the item. If you cannot clear context, launch sub-agent with a fresh context.
    - Use `saml-plan` skill to plan the item.
    - Once plan review passes, `/clear` context again. Or, launch another sub-agent with a fresh context.
    - Then, use `saml-implement` to implement the item. (It is important to clear context between `saml-plan` and `saml-implement`)
    - Move on to the next item in the list.
    - If any step fails (plan review or implementation review), stop and report the failure to the user, then wait for user input on how to proceed (e.g. fix the issue, skip the item, etc.).