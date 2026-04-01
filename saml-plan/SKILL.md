---
name: saml-plan
description: >
  Enters plan mode to collaboratively write a plan.md with the user.
parameters:
  what: what to plan for
---

# Process

When this skill is invoked, execute the following phases in order.

---

## Phase 1 — Setup

1. Switch into **plan mode**, if not already in plan mode. If you are unable to switch to plan mode, ask user to switch to plan mode before proceeding.

2. Ask the user what they want to implement, if they have not already passed the **what** parameter. Use the `ask_user` tool to capture their response.

3. Ask clarifying questions (one at a time via `ask_user`) to resolve ambiguity before writing the plan. Focus on:
   - Feature scope and boundaries (what's in / out)
   - Behavioral choices (defaults, limits, error handling)
   - Implementation approach when multiple valid options exist

   Skip questions that have an obvious, unambiguous answer.

---

## Phase 2 — Understand the Codebase

4. Read `.github/copilot-instructions.md` if it exists to understand project conventions (build commands, test commands, folder structure).

5. Launch a **sync explore sub-agent** to understand the parts of the codebase relevant to the planned work. Ask it to:
   - Identify key files, classes, and functions involved
   - Find existing patterns and conventions to follow
   - Note anything that could affect implementation (interfaces, dependencies, existing tests)

   Use its findings to ground the plan in concrete file paths, function names, and existing code patterns.

---

## Phase 3 — Write Plan

6. Write a self-contained implementation plan to the session plan file:
   `~/.copilot/session-state/<session-id>/plan.md`

   The plan must be detailed enough for a less-capable model to execute
   without any additional context. Include:
   - A clear problem statement
   - An ordered list of concrete steps (exact file paths, function names,
     logic changes, and code snippets where helpful)
   - Known risks and edge cases to watch out for
   - How to run existing tests and linters to verify the changes

---

## Phase 4 — Review Plan

7. Launch a **sync sub-agent** using model **`Claude Sonnet 4.6`** with the following prompt:

   ```
   You are a senior engineer reviewing an implementation plan.

   Working directory: <cwd>

   Plan:
   <full contents of plan.md>

   Assess the plan for:
   - Completeness: are all necessary steps present? Are file paths and function names concrete?
   - Correctness: does the approach make sense given the codebase?
   - Actionability: could a junior engineer follow this without additional context?

   Return exactly ONE of:
     PASS: <one-sentence summary>
   or
     FAIL: <bullet list of specific gaps or issues>

   Do not nitpick style. Only flag genuine gaps, missing steps, or incorrect assumptions.
   ```

   - If **PASS**: proceed to Phase 5.
   - If **FAIL**: revise `plan.md` to address the issues, then re-run the review once more.

---

## Phase 5 — Track Todos

8. Parse the concrete steps from `plan.md` and insert them as todos into the SQL `todos` table using descriptive kebab-case IDs. Include enough detail in each `description` that the todo is self-contained. Insert dependencies into `todo_deps` for steps that must be done in order.

---

## Phase 6 — Done

9. Tell the user: **"✅ Plan written. Please review `plan.md` — you can edit
   it directly (Ctrl+Y in plan mode). Let me know when you're happy with it
   or what you'd like to change."**

