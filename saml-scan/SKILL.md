---
name: saml-scan
description: >
  Scans code base and updates `.github/copilot-instructions.md` with the latest info.
  This should be triggered every time you scan code base.
---

# Process

When this skill is invoked, execute the following phases in order.

---

# Phase 1 — Scan

1. Read `.github/copilot-instructions.md` if it exists to understand project conventions.

2. Explore the codebase if you haven't already.

3. Compare what's in `.github/copilot-instructions.md` with findings from the exploration.

4. Update `.github/copilot-instructions.md` to match the current codebase.

   `.github/copilot-instructions.md` should contain:
   - How to build and run the project.
   - How to run tests.
   - How to run formatter and linter.
   - Key folder structure so that agents don't need to scan the full codebase repeatedly.

---

# Phase 2 — Review (Claude Sonnet 4.6, sync sub-agent)

Launch a sub-agent using model **`Claude Sonnet 4.6`** with the following prompt (fill in placeholders):

```
You are a senior engineer reviewing a project's AI instructions file.

Working directory: <cwd>

Review `.github/copilot-instructions.md` and assess whether it accurately and
completely describes the project. Focus on:
- Correctness: do the build/test/lint commands actually work?
- Completeness: are any important commands, conventions, or folder structures missing?
- Clarity: would an AI agent be able to act on these instructions without ambiguity?

Return exactly ONE of:
  PASS: <one-sentence summary of what looks good>
or
  FAIL: <bullet list of specific problems or missing information>

Do not nitpick style. Only flag genuine gaps or errors.
```

Collect the review result. If **PASS**, skip to Phase 4. If **FAIL**, proceed to Phase 3.

---

# Phase 3 — Amend Loop (GPT-5.4 mini, background sub-agent)

Repeat the following loop. Stop when the reviewer returns **PASS**, or after
**3 iterations** — then report remaining issues to the user.

### Amend step

Launch a **background sub-agent** using model **`GPT-5.4 mini`** with this prompt:

```
You are a software engineer updating a project's AI instructions file.

Working directory: <cwd>

Reviewer feedback on `.github/copilot-instructions.md`:
<FAIL message verbatim>

Instructions:
- Address every issue raised by the reviewer.
- Update `.github/copilot-instructions.md` accordingly.
- Do not remove accurate information; only fix or add content.
- Return a concise summary of what you changed.
```

Wait for the amend sub-agent to complete.

### Review step

Re-run the review prompt from Phase 2 against the updated file.

- If **PASS**: go to Phase 4.
- If **FAIL**: run another Amend step with the new feedback.

---

# Phase 4 — Done

Report to the user:

> ✅ **Done!** `.github/copilot-instructions.md` has been updated and reviewed.
> <PASS message from reviewer>

If the loop hit the 3-iteration limit without passing, instead report:

> ⚠️ The review-fix loop reached 3 iterations without a clean pass.
> Remaining issues:
> <last FAIL message>
> Please review `.github/copilot-instructions.md` manually.
