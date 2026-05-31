---
name: saml-code-review
description: >
  Reviews the codebase end-to-end using improve-codebase-architecture, stores the HTML report
  to .todo/, generates and updates todos.json, and lets you work through items with
  saml-plan and saml-implement.
---

# Process

When this skill is invoked, execute the following phases in order.

---

## Phase 1 — Read Context

1. Find and read the project's domain context:
   - `CONTEXT.md` at repo root or in `docs/`
   - ADRs in `docs/adr/` if they exist
   - Architecture notes in `agents/` if they exist

2. Find all source files to review:
   - For Android/Kotlin: glob `**/*.kt` in `app/src/main/java/`
   - Adjust glob for other languages as appropriate

3. Read the improve-codebase-architecture skill files for vocabulary:
   - `LANGUAGE.md` — module, interface, implementation, depth, seam, adapter, leverage, locality
   - `HTML-REPORT.md` — report format and diagram patterns

---

## Phase 2 — Explore Codebase

Use the **Explore agent** (stateless sub-agent) to walk the codebase organically. Do NOT use grep directly — delegate to the explore agent. Pass complete context.

Explore for:
- Shallow modules (interface nearly as complex as implementation)
- Leaky abstractions (implementation details bleeding across seams)
- God screens (files doing too much, too many state variables)
- Missing seams (untestable because no interface to inject)
- Tight coupling across packages
- Untested or hard-to-test code

Apply the **deletion test**: imagine deleting the module. Does complexity vanish (pass-through) or reappear across N callers (earning its keep)?

Cover these areas:
- **Domain layer**: domain models, repository interfaces, use cases
- **Data layer**: repository implementations, Room DAOs/entities, file storage
- **UI layer**: screens, ViewModels, sheet/dialog components, form fields

---

## Phase 3 — Write HTML Report

Write a self-contained HTML report to `.todo/YYYY-MM-DD-architecture-review.html`.

Use the format from `HTML-REPORT.md`:
- Tailwind via CDN + Mermaid via CDN for diagrams
- One card per candidate with before/after diagrams
- Recommendation strength badges: `Strong` (emerald), `Worth exploring` (amber), `Speculative` (slate)
- Top recommendation section at the end

Diagram types to use:
- Mermaid flowchart for call/dep graphs
- Mass diagram for interface-vs-implementation size comparison
- Cross-section for layered shallowness

Use the glossary terms exactly: **module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality**. Never substitute: component, service, boundary, layer.

---

## Phase 4 — Generate Todo Items

Read the HTML report and the raw code findings. Generate one `.todo/NN-TICKET-ID.md` file per actionable item, and update `todos.json` at the repo root.

### Todo item file format

```markdown
# Title

## Severity: critical | high | medium | low

## Files
- file1.kt (lines N-M)
- file2.kt (line X)

## Problem
One sentence. What hurts and why it matters.

## Solution
One sentence. What changes.

## Category
clean-code | architecture | kotlin-idiom | android-pattern

## Status: pending
```

### todos.json format

```json
{
  "todos": [
    {
      "id": "NN-ticket-id",
      "title": "Short title",
      "description": "One-liner from problem",
      "status": "pending | in_progress | done | blocked",
      "severity": "critical | high | medium | low"
    }
  ]
}
```

Ordering: critical first, then high, medium, low. Within each group, by id/number.

### Severity rules
- **critical**: runtime crash, data loss, security issue
- **high**: significant architectural smell, major code quality problem
- **medium**: noticeable issue, fixable when touching that code
- **low**: polish, minor improvement

---

## Phase 5 — Done

Report:
- Path to the HTML report (`.todo/YYYY-MM-DD-architecture-review.html`)
- Path to `todos.json`
- Count by severity
- First critical item ready to work on

Example:
> ✅ Code review complete.
>
> **HTML Report**: `.todo/2026-05-31-architecture-review.html`
> **Todo list**: `todos.json` (4 critical, 3 high, 4 medium, 1 low)
>
> Start with `saml-plan` for `01-nullable-deps-crash` (fix ItemListViewModel nullable deps).

---

## Working Through Todos

To work on a specific todo:
1. `saml-plan` → creates `.plan/YYYY-MM-DD-hh-mm-TICKET-ID.md`
2. `saml-implement` → implements from the plan, reviews, fixes
3. Mark done in `todos.json`

To mark done manually:
```bash
jq '.todos[] | select(.id == "01-nullable-deps-crash") | .status = "done"' todos.json | sponge todos.json
```

To view current status:
```bash
cat todos.json | jq '.todos[] | "\(.severity) [\(.status)] \(.id) - \(.title)"'
```
