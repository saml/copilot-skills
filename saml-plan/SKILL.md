---
name: saml-plan
description: >
  Enters plan mode to collaboratively write a plan.md with the user.
parameters:
  what: what to plan for
---

# Process

When this skill is invoked, first enter into **plan mode** if not already in **plan mode**.
Then execute the following steps in order.

1. Switch into **plan mode**, if not already in plan mode. If you are unable to switch to plan mode, ask user to switch to plan mode before proceeding.

2. Ask the user what they want to implement, if user already has not passed the parameter **what**. Use the `ask_user` tool so you
   can capture their response.

3. Read `.github/copilot-instructions.md` if it exists to understand project
   conventions. 

4. Write a self-contained implementation plan to the session plan file:
   `~/.copilot/session-state/<session-id>/plan.md`

   The plan must be detailed enough for a less-capable model to execute
   without any additional context. Include:
   - A clear problem statement
   - An ordered list of concrete steps (exact file paths, function names,
     logic changes, and code snippets where helpful)
   - Known risks and edge cases to watch out for
   - How to run existing tests and linters to verify the changes

5. Tell the user: **"✅ Plan written. Please review `plan.md` — you can edit
   it directly (Ctrl+Y in plan mode). Let me know when you're happy with it
   or what you'd like to change."**

