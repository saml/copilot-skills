---
name: saml-plan-review
description: >
  Reviews and fixes the implementation plan in `./.plan.md` to ensure it's complete, correct, and actionable before implementation begins.
  This should be automatically triggered when the user asks for a review of the plan.
---

# Process

When this skill is invoked, execute the following phases in order.

---

## Phase 1 — Setup

1. Determine invocation mode:
   - **Standalone mode**: user explicitly asked to review/fix a plan.
   - **Delegated mode**: invoked internally from `saml-plan` right after draft creation.

2. If in **standalone mode**, ask the user what they want to improve in `./.plan.md`.
   If in **delegated mode**, skip this question and proceed.

3. Ask clarifying questions (one at a time via the question tool, for example `ask_user` or `vscode_askQuestions`) only when necessary to resolve ambiguity before reviewing and fixing the plan. Focus on:
   - Specific issues or gaps they want to address in the plan.
   - Any constraints or requirements for the plan that should be considered during the review.

   Skip questions that have an obvious, unambiguous answer. In delegated mode, prefer proceeding without questions unless required to avoid a wrong assumption.

---

## Phase 2 — Understand the Codebase

4. Gather necessary knowledge of codebase to review and improve the plan.
   These files can help: `.github/copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md` or other summary files.
   If no relevant information is found, free to read codebase or ask the user to provide necessary info.

5. Verify `./.plan.md` exists and read its full contents.
   - If the file does not exist, stop and tell the user:
     > ❌ No `./.plan.md` found. Please run the `saml-plan` skill first to create a plan.



## Phase 3 — Review-Fix Loop

6. Set an iteration counter to 1. Use a maximum of 3 iterations.

7. Launch a **sync sub-agent** using model **`Claude Sonnet 4.6`** with the following prompt:

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

   Also write the FAIL bullet list to `./.plan-review.md` for the plan author to read.

   Do not nitpick style. Only flag genuine gaps, missing steps, or incorrect assumptions.
   ```

8. Parse the reviewer output.
   - If output starts with **`PASS:`**, proceed to Phase 4.
   - If output starts with **`FAIL:`**, continue to Step 9.
   - If output is malformed (neither PASS nor FAIL), treat it as FAIL and ask the reviewer to rerun with the exact required format.

9. Fix `./.plan.md` according to reviewer feedback.
   - Make concrete edits that address every listed gap.
   - Ask additional clarifying questions only when a feedback item cannot be resolved from codebase context.

10. Re-run the reviewer check from Step 7 after edits.
   - If result is **PASS**, proceed to Phase 4.
   - If result is **FAIL**, increment iteration counter and repeat Steps 8-10 (Step 10 re-invokes Step 7).
   - If iteration counter exceeds 3, stop and report remaining issues to the user.

---

## Phase 4 — Done

11. If review passed, tell the user:
   **"✅ Plan reviewed and updated. Please review `./.plan.md`. Let me know if you'd like any further changes."**

12. If the 3-iteration limit was reached without a pass, tell the user:
   **"⚠️ Plan review reached the 3-iteration limit without a clean pass. Please review the remaining issues and decide whether to continue refining `./.plan.md` manually."**
