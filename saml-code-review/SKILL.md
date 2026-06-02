---
name: saml-code-review
description: >
  Reviews the codebase end-to-end using improve-codebase-architecture, stores the HTML report
  to .todo/, generates and updates .todo/todo.csv, and lets you work through items with
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

Read the HTML report and the raw code findings. Generate one `.todo/NN-TICKET-ID.md` file per actionable item, and update `.todo/todo.csv`.

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

### .todo/todo.csv format

```csv
id,title,description,status,severity
NN-ticket-id,Short title,One-liner from problem,pending,critical
```

Write it with Python:

```python
import csv

SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3}

rows = [{"id": "01-x", "title": "...", "description": "...", "status": "pending", "severity": "critical"}]
rows.sort(key=lambda r: (SEVERITY_ORDER.get(r["severity"], 9), r["id"]))

with open(".todo/todo.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["id", "title", "description", "status", "severity"])
    writer.writeheader()
    writer.writerows(rows)
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
- Path to `.todo/todo.csv`
- Count by severity
- First critical item ready to work on

Example:
> ✅ Code review complete.
>
> **HTML Report**: `.todo/2026-05-31-architecture-review.html`
> **Todo list**: `.todo/todo.csv` (4 critical, 3 high, 4 medium, 1 low)
>
> Start with `saml-plan` for `01-nullable-deps-crash` (fix ItemListViewModel nullable deps).

---

## Working Through Todos

To automatically work through todos, do the following in a loop:
1. Pick the next pending item from `.todo/todo.csv` (start with critical).
2. `saml-plan` → creates `.plan/YYYY-MM-DD-hh-mm-TICKET-ID.md`
3. `saml-implement` → implements from the plan, reviews, fixes. Only if `saml-plan` was successful. Otherwise, halt.
4. Mark done in `.todo/todo.csv` only if `saml-implement` was successful. Otherwise, halt.
5. Execute `git add .` and `git commit --file .git/GITGUI_MSG` to create a commit, only if it's successful so far. Otherwise, halt.

To mark done manually:
```python
import csv, tempfile, os

target_id = "01-nullable-deps-crash"
new_status = "done"
fieldnames = ["id", "title", "description", "status", "severity"]
updated = False
tmp_path = None

with open(".todo/todo.csv", newline="") as f:
    rows = list(csv.DictReader(f))

for r in rows:
    if r["id"] == target_id:
        r["status"] = new_status
        updated = True

if not updated:
    raise ValueError(f"ID '{target_id}' not found")

try:
    with tempfile.NamedTemporaryFile("w", dir=".todo", delete=False, newline="", suffix=".csv") as tmp:
        tmp_path = tmp.name
        writer = csv.DictWriter(tmp, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    os.replace(tmp_path, ".todo/todo.csv")
except Exception:
    if tmp_path and os.path.exists(tmp_path):
        os.unlink(tmp_path)
    raise
```

To view current status:
```python
import csv

SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3}

with open(".todo/todo.csv", newline="") as f:
    rows = sorted(csv.DictReader(f), key=lambda r: (SEVERITY_ORDER.get(r["severity"], 9), r["id"]))
for r in rows:
    print(f'{r["severity"]} [{r["status"]}] {r["id"]} - {r["title"]}')
```

Tackle the next todo item one by one until all items are done.
