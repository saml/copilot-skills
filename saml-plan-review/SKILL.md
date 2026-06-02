---
name: saml-plan-review
description: >
  Reviews an existing plan file and fixes issues until review passes.
  Use when you've manually edited a plan and want it re-validated.
---

# Process

## Phase 1 — Find Plan

- If path given, use it. Otherwise find latest plan file using `saml-latest-planfile`.
- Read the plan file. If not found, tell user to run `saml-plan` first.

## Phase 2 — Gather Context

- Read codebase context: `AGENTS.md`, `.github/copilot-instructions.md`, or similar.
- Understand project conventions relevant to the plan.

## Phase 3 — Review-Fix Loop

Launch a **general-purpose sub-agent** (fresh context window) to review the plan.
The reviewer must NOT inherit any prior conversation history — pass all context explicitly in the prompt:

- The full plan file contents
- Codebase context gathered in Phase 2
- Project conventions and constraints

> You are a senior engineer. You HATE this plan and want to criticize it. Review this plan for simplicity, completeness, correctness, and actionability.
> Return PASS or FAIL with specific issues.
> Write review to `PLANFILE.review.md`.

- If PASS → done.
- If FAIL → fix the plan file based on feedback, re-run.
- Max 3 iterations.

## Done

Tell user: **"✅ Plan reviewed: `<path>`"**
If iteration limit hit, show remaining issues.
