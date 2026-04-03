---
name: saml-plan
description: >
  Collaboratively write plan.md with the user.
  It guides the user through writing a detailed implementation plan.
  This should be automtically triggered when the user asks for an implementation. Or, when the user asks `.plan.md` file to be created or modified.
---

# Process

When this skill is invoked, execute the following phases in order.

---

## Phase 1 — Setup

1. Ask the user what they want to implement, if they have not already passed the **what** parameter. Use the `ask_user` tool to capture their response.

2. Ask clarifying questions (one at a time via `ask_user`) to resolve ambiguity before writing the plan. Focus on:
   - Feature scope and boundaries (what's in / out)
   - Behavioral choices (defaults, limits, error handling)
   - Implementation approach when multiple valid options exist

   Skip questions that have an obvious, unambiguous answer.

---

## Phase 2 — Understand the Codebase

3. Gather necessary knowledge of codebase to write the plan.
   These files can help: `.github/copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md` or other summary files.
   If no relevant information is found, free to read codebase or ask the user to provide necessary info.

---

## Phase 3 — Write Plan

4. Write a self-contained implementation plan to the plan file: `./.plan.md`.
   Overwrite any existing content.
   The plan must be detailed enough for a less-capable model to execute in a new fresh context.
   The plan should contain implementation detail for:
   - Specific file paths and function names to create/modify.


---

## Phase 4 — Review Plan

4. Launch a **sync sub-agent** using model **`Claude Sonnet 4.6`** with the following prompt:

   ```
   You are a senior engineer reviewing an implementation plan.

   Working directory: <cwd>

   Plan:
   <full contents of ./.plan.md>

   Assess the plan for:
   - Completeness: are all necessary steps present? Are file paths and function names concrete?
   - Correctness: does the approach make sense given the codebase?
   - Succinctness: is the plan free of unnecessary steps or detail that doesn't add value?
   - Simplicity: is the plan as straightforward as possible, without unnecessary complexity and overengineering?
   - Actionability: could a junior engineer follow this without additional context?

   Return exactly ONE of:
     PASS: <one-sentence summary>
   or
     FAIL: <bullet list of specific gaps or issues>

   Do not nitpick style. Only flag genuine gaps, missing steps, or incorrect assumptions.
   ```

   - If **PASS**: proceed to Phase 5.
   - If **FAIL**: go back to Phase 1, 2, or 3 to address the issues. Freely ask user additional clarifying questions. Freely make adjustments to `./.plan.md`, then re-run the review until it **PASS**es. However, do not loop more than 3 times to prevent infinite loops.

---

## Phase 5 — Done

5. Tell the user: **"✅ Plan written. Please review `./.plan.md`. Let me know when you're happy with it
   or what you'd like to change."**
