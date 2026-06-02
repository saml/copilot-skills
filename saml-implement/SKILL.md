---
name: saml-implement
description: >
  Implements from the latest plan file using a cheap sub-agent,
  then review-fix loops until approved.
---

# Process

## Phase 1 — Implement

- Use `saml-latest-planfile` skill to find the latest plan file, or use given path.
  If no plan file found, stop: "❌ No plan file found. Run `saml-plan` first."
- Read the plan file contents fully.
- Launch a **task sub-agent** (task agent type. fresh context window) to implement.
  The implementer must NOT inherit your context — pass all context explicitly in the prompt:

  - The full plan file contents (verbatim)
  - The working directory path
  - Relevant codebase context (AGENTS.md, project conventions, Makefile if present)

  > Implement this plan exactly. Use `tdd` skill.
  > After changes, discover and run tests/linter
  > (check Makefile, package.json, pom.xml, build.gradle, or CI config).
  > Summarize what changed and pass/fail status.

- Wait for completion.

## Phase 2 — Review-Fix Loop

Launch a **general-purpose sub-agent** (fresh context window) to review.
The reviewer must NOT inherit the implementation agent's context — pass all context explicitly in the prompt:

- The full plan file contents
- A summary or diff of what was implemented
- Relevant codebase context (AGENTS.md, project conventions)

> You are a senior engineer. You HATE this implementation and want to criticize it. Review the implementation against the plan.
> Verify tests exist and are high quality.
> Return PASS or FAIL.
> On FAIL: write a detailed, actionable fix plan to `PLANFILE.fixplan.md`
> that a cheap model can follow in a fresh context without additional guidance.
> Only flag bugs, missing requirements, or quality issues — not style.

- If PASS → done.
- If FAIL → launch sub-agent (task agent type) with cwd, plan contents, and fixplan.md to fix. Fixer must rerun tests/linter after changes. Then re-run review.
- Max 10 iterations.

## Done

- Report result to user.
- Write commit message to `.git/GITGUI_MSG`.
