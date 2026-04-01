---
name: slee-implement
description: >
  Full implement → review cycle. Delegates implementation to `GPT-5.4 mini`,
  then runs a review-fix loop (`Claude Sonnet 4.6` reviews, `GPT-5.4 mini` fixes)
  until the review passes. Use this when asked to implement a feature end-to-end with automated review.
---

# Process

When this skill is invoked, execute the following phases in order.

---

# Phase 1 — Implement (GPT-5.4 mini, background sub-agent)

1. Read `~/.copilot/session-state/<session-id>/plan.md`.
   - If the file does not exist, stop and tell the user:
     > ❌ No `plan.md` found. Please run the `saml-plan` skill first to create a plan.

2. Launch a **background sub-agent** using model **`GPT-5.4 mini`** with
   the following prompt (fill in the placeholders):

   ```
   You are a software engineer. Your job is to implement the following plan
   exactly as written. Do not skip steps or take shortcuts.

   Working directory: <cwd>

   Plan:
   <full contents of plan.md>

   Instructions:
   - Follow the plan step by step.
   - After making all changes, discover and run the existing tests and linter.
     To find them, check (in order): Makefile targets, package.json scripts,
     pom.xml (mvn test), build.gradle, or a CI config (e.g. .github/workflows/).
     Run whatever is present; skip gracefully if nothing is found.
   - When done, provide a concise summary of: what was changed, which files
     were modified, and whether tests/linter passed or failed.
   ```

3. Wait for the sub-agent to complete.

4. Collect its summary. If it reports test/linter failures that it could not
   fix, note them — they will be passed to the reviewer.

---

## Phase 2 — Review-Fix Loop (Claude Sonnet 4.6 reviews, GPT-5.4 mini fixes)

Track the iteration count (start at 1). Stop when the reviewer returns **PASS**,
or after **3 iterations** (to avoid infinite loops) — in which case report
remaining issues to the user.

### Review step

Launch a **background sub-agent** using model **`Claude Sonnet 4.6`** with this prompt:

```
You are a senior code reviewer. Review the implementation in the working
directory against the plan below. Focus on: correctness, code quality,
edge cases, test coverage, and adherence to the plan.

Working directory: <cwd>

Plan:
<full contents of plan.md>

Implementation summary from the implementor (iteration <current iteration> of 3):
<summary from Phase 1 or the most recent Fix step>

Instructions:
- Examine the relevant changed files.
- Return exactly ONE of:
    PASS: <one-sentence summary of what was implemented>
  or
    FAIL: <bullet list of specific issues to fix>
- Do not suggest stylistic nitpicks unless they violate the project's
  stated conventions. Only flag genuine bugs, missing requirements,
  or significant quality issues.
```

Wait for the sub-agent to complete.

### Decision

- If the reviewer returns **`PASS`**: go to Phase 3.
- If the reviewer returns **`FAIL`**: proceed to the Fix step.

### Fix step

Launch a **background sub-agent** using model **`GPT-5.4 mini`** with this prompt:

```
You are a software engineer fixing reviewer feedback. Address every issue
listed below. Do not change code unrelated to the feedback.

Working directory: <cwd>

Original plan:
<full contents of plan.md>

Implementation summary so far:
<summary from Phase 1 or the previous Fix step>

Reviewer feedback:
<FAIL message verbatim>

Instructions:
- Fix all issues raised by the reviewer.
- Discover and run the existing tests and linter after your changes
  (check Makefile, package.json scripts, pom.xml, build.gradle, or CI config).
- Return a concise summary of what you changed and whether tests/linter
  passed or failed.
```

Wait for the sub-agent to complete. Increment the iteration counter, then go
back to the **Review step**.

---

## Phase 3 — Done

Report to the user:

> ✅ **Done!** The reviewer approved the implementation.
> Here's a summary: <PASS message from reviewer>
>
> Files changed: <output of `git diff --name-only HEAD` in the working directory>

If the loop hit the 3-iteration limit without passing, instead report:

> ⚠️ The review-fix loop reached 3 iterations without a clean pass.
> Remaining issues:
> <last FAIL message>
> Please review manually or run `/slee-review` to continue the loop.

