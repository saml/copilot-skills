---
name: saml-plan
description: >
  Writes a detailed implementation plan to the file `./.plan.md`.
  This should be automatically triggered when the user asks for a plan for implementation.
---

# Process

When this skill is invoked, execute the following phases in order.

---

## Phase 1 — Setup

1. Ask the user what they want to implement if it is not clear. Use the question tool (for example, `ask_user` or `vscode_askQuestions`) to capture their response.

2. Ask clarifying questions (one at a time via the question tool, for example `ask_user` or `vscode_askQuestions`) to resolve ambiguity before writing the plan. Focus on:
   - Feature scope and boundaries (what's in / out)
   - Behavioral choices (defaults, limits, error handling)
   - Implementation approach when multiple valid options exist

   Skip questions that have an obvious, unambiguous answer.

---

## Phase 2 — Write Plan

3. Write a self-contained implementation plan to the plan file: `./.plan.md`.
   Overwrite any existing content.
   The plan must be detailed enough for a less-capable model to execute in a new fresh context.
   The plan should contain implementation detail for:
   - Specific file paths and function names to create/modify.
   - Key decisions made and the rationale behind them.
   - Dependencies or prerequisites (libraries, env vars, existing utilities to reuse).
   - Test cases to write, including what behavior each test validates.
   - Error handling and edge cases to address.


---

## Phase 3 — Review Plan

4. Delegate review to the `saml-plan-review` skill instead of duplicating review logic here.
   - Invoke `saml-plan-review` immediately after writing `./.plan.md`.
   - Pass context that this is an internal handoff from `saml-plan` (delegated mode), and that the reviewer should validate and fix `./.plan.md` directly.
   - If `saml-plan-review` reaches a clean pass, proceed to Phase 4.
   - If `saml-plan-review` reaches its iteration limit without a pass, report that status to the user and include where remaining issues are captured.

---

## Phase 4 — Done

5. Tell the user: **"✅ Plan written. Please review `./.plan.md`. Let me know when you're happy with it
   or what you'd like to change."**

   If delegated review did not pass within its iteration limit, instead surface that warning result and point the user to `./.plan-review.md`.
