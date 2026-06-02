---
name: saml-plan-review
description: >
  Reviews an existing plan file and fixes issues until review passes.
  Use when you've manually edited a plan and want it re-validated.
---

# Process

## Phase 1 — Find Plan

- If path given, use it. Otherwise find latest `.md` in `./.plan/` (exclude `*.review.md` and `*.fixplan.md`).
- Read the plan file. If not found, tell user to run `saml-plan` first.

## Phase 2 — Gather Context

- Read codebase context: `AGENTS.md`, `.github/copilot-instructions.md`, or similar.
- Understand project conventions relevant to the plan.

## Phase 3 — Review-Fix Loop

Launch a sync sub-agent (default model) to review the plan:

> Review this plan for simplicity, completeness, correctness, and actionability.
> Return PASS or FAIL with specific issues.
> Write review to `PLANFILE.review.md`.

- If PASS → done.
- If FAIL → fix the plan file based on feedback, re-run.
- Max 3 iterations.

## Done

Tell user: **"✅ Plan reviewed: `<path>`"**
If iteration limit hit, show remaining issues.
