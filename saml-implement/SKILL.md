---
name: saml-implement
description: >
  Full implement → review cycle. Delegates implementation to a background sub-agent, then reviews its work with a more capable model.
  If the review fails, it creates a fix plan and sends it back to the implementor for another iteration of implementation and review,
  until the review passes. Use this when asked to implement a feature end-to-end with automated review.

  This assumes the plan file already exists (e.g. created by `saml-plan` skill) with a detailed implementation plan. If not, it will prompt the user to create one first.
---

# Process

When this skill is invoked, execute the following phases in order.

---

## Phase 1 — Implement (GPT-5.4 mini, background sub-agent)

0. Find the latest plan file in `./.plan/` (the one with the most recent timestamp in its filename). If no plan file is found, stop and tell the user:
   > ❌ No plan file found in `./.plan/`. Please run the `saml-plan` skill first to create a plan file.
   You can use the following bash script to find the latest plan file (note that it is using `/usr/bin/env bash` to pick up better bash version):
   
   ```bash
   #!/usr/bin/env bash
   files=( ./.plan/2*.md )
   echo "${files[-1]}"
   ```
1. Read the plan file.

2. Launch a **background sub-agent** using model **`GPT-5.4 mini`** with
   the following prompt (fill in the placeholders):

   ```
   You are a software engineer. Your job is to implement the following plan
   exactly as written. Do not skip steps or take shortcuts.

   Working directory: <cwd>

   Plan:
   <full contents of the plan file>

   Instructions:
   - Follow the plan step by step.
   - Simplicity first. Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.
   - Surgical changes only. Touch only what you must. Clean up your own mess.
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
directory against the plan below. Focus on: simplicity, readability, correctness, code quality,
edge cases, test coverage, and adherence to the plan.

Working directory: <cwd>

Plan:
<full contents of the plan file>

Implementation summary from the implementor (iteration <current iteration> of 3):
<summary from Phase 1 or the most recent Fix step>

Instructions:
- Examine the relevant changed files.
- Return exactly ONE of:
    PASS: <one-sentence summary of what was implemented>
  or
    FAIL: <detailed fix plan written to the fix plan file at `PLANFILE.fixplan.md` where `PLANFILE` is the name of the plan file being implemented. For example, if the plan file is `./.plan/2024-06-20-15-30-my-feature.md`, the fix plan file should be `./.plan/2024-06-20-15-30-my-feature.fixplan.md`.>
- Do not suggest stylistic nitpicks unless they violate the project's
  stated conventions. Only flag genuine bugs, missing requirements,
  or significant quality issues.
- Make sure tests are written as well. And tests are high production quality code.
- Make sure code is simple and straightforward, without unnecessary complexity or overengineering.
```

The fix plan file will be created if the reviewer returns **FAIL**. It should contain a detailed
fix plan that the implementor can follow to address the reviewer's concerns. It should be actionable, specific,
and detailed enough for the implementor to make the necessary changes in a fresh new context without additional guidance.

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
<full contents of the plan file>

Implementation summary so far:
<summary from Phase 1 or the previous Fix step>

Reviewer feedback:
<full contents of the fix plan file created by the reviewer>

Instructions:
- Fix all issues raised by the reviewer.
- Discover and run the existing tests and linter after your changes
  (check Makefile, package.json scripts, pom.xml, build.gradle, or CI config).
- Return a concise summary of what you changed and whether tests/linter
  passed or failed.
```

Wait for the sub-agent to complete. Increment the iteration counter, then go
back to the **Review step**.

Do not delete the fix plan file after fixes.

---

## Phase 3 — Done

Report to the user:

> ✅ **Done!** The reviewer approved the implementation.
> Here's a summary: <PASS message from reviewer>

If the loop hit the 3-iteration limit without passing, instead report:

> ⚠️ The review-fix loop reached 3 iterations without a clean pass.
> Remaining issues:
> <last FAIL message>
> Please review manually.
