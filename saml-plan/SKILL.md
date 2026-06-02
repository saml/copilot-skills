---
name: saml-plan
description: >
  Writes an implementation plan to `./.plan/YYYY-MM-DD-hh-mm-TITLE.md`,
  then self-reviews until it passes.
---

# Process

## Phase 1 — Clarify

- Use `grill-with-docs` skill to get context.
- Ask clarifying questions about scope, behavior, and approach.
- Skip obvious questions.
- **If invoked from automation (e.g. `saml-todo-next`):** skip interactive questions, use provided context directly.

## Phase 2 — Write Plan

- Create plan file via `saml-planfile` skill.
- Write a self-contained plan detailed enough for a cheap model to execute.
- Use `tdd` skill to plan tests.
- Plan must include:
  - File paths and function names to create/modify.
  - TDD: which tests first, what each validates.
  - Key decisions and rationale.
  - Dependencies/prerequisites.
  - Error handling and edge cases.
- State assumptions explicitly. If uncertain, ask.
- Simplicity first. No overengineering.

## Phase 3 — Review-Fix Loop

Launch a sync sub-agent (default model) to review the plan:

> Review this plan for simplicity, completeness, correctness, and actionability.
> Return PASS or FAIL with specific issues.
> Write review to `PLANFILE.review.md`.

- If PASS → done.
- If FAIL → fix the plan file, re-run review.
- Max 10 iterations. If still failing, report to user with path to `PLANFILE.review.md`.

## Done

Tell user: **"✅ Plan written: `<path>`"**
If iteration limit hit, show remaining issues and point to `PLANFILE.review.md`.
