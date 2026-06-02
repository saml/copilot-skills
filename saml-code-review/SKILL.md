---
name: saml-code-review
description: >
  Pure orchestration wrapper for code review. Delegates codebase analysis to improve-codebase-architecture
  (which produces the HTML report), extracts candidates into .todo/todo.csv + .todo/{id}.md files, and leaves
  todo management to saml-todo and saml-todo-next.
---

# Process

When this skill is invoked, execute the following three phases in order.

---

## Phase 1 — Invoke improve-codebase-architecture

Call the `improve-codebase-architecture` skill to analyze the codebase and generate the HTML report. You are a senior engineer. You HATE this project and want to criticize it.

**Important**: Run the skill through step 2 (report generation only). Let it write the HTML report to disk and print its absolute path. Do NOT proceed to step 3 (grilling loop), and suppress the follow-up prompt that asks which candidate to explore.

Capture the absolute path to the HTML report from the skill's output.

---

## Phase 2 — Extract Todos

Create the `.todo/` directory if it does not exist.

Parse the HTML report produced by step 1. Extract candidates from the report (candidate cards only; ignore the Top recommendation summary at the end).

For each candidate card, create one `.todo/{id}.md` file and one row in `.todo/todo.csv`.

**ID Format**: `NN-kebab-title` where NN is zero-padded sequence (01, 02, ...) and kebab-title is the candidate's title converted to kebab-case.

**Section order in each `.todo/{id}.md` file**:

- `# {title}` — heading with the candidate's title
- `## Severity: {severity}` — mapped from recommendation strength
- `## Files` — list of file paths affected; include line ranges only if the candidate specifies them, otherwise just file paths
- `## Problem` — candidate's problem text
- `## Solution` — candidate's solution text
- `## Category` — always set to `architecture`
- `## Status: pending` — new items always start pending

**Severity mapping**:

- `Strong` → `high`
- `Worth exploring` → `medium`
- `Speculative` → `low`
- Override to `critical` if the candidate describes a runtime crash, data loss, or security issue

**CSV file** (`.todo/todo.csv`) format: columns are `id,title,description,status,severity`. Use Python csv.DictWriter. Sort rows by severity (critical → high → medium → low), then by id. Example columns:

- `id`: `01-kebab-title`
- `title`: candidate's title
- `description`: candidate's problem text (one-liner)
- `status`: always `pending` for new items
- `severity`: mapped from recommendation strength

**Filename invariant**: each row's `id` in the CSV must have a corresponding `.todo/{id}.md` file.

---

## Phase 3 — Report

Print the following:

- **HTML Report Path**: absolute path to the HTML report produced by `improve-codebase-architecture`
- **Todo CSV Path**: path to `.todo/todo.csv`
- **Count by Severity**: total counts in the format `N critical, N high, N medium, N low`
- **Next Steps**: suggest running `saml-todo-next` to start working through items

Example output:

```
✅ Code review complete.

HTML Report: /absolute/path/to/.todo/2026-06-02-architecture-review.html
Todo list: .todo/todo.csv (2 critical, 3 high, 5 medium, 1 low)

Run saml-todo-next to start working through items.
```
