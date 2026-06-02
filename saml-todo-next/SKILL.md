---
name: saml-todo-next
description: >
  Picks the next pending todo item from .todo/todo.csv (sorted by severity: critical → high → medium → low),
  then automatically executes the full pipeline: saml-plan → saml-implement → git commit → mark done.
  No user interaction needed after invocation.
---

# saml-todo-next Skill

Fully automated end-to-end execution of a single todo item: plan → implement → commit → done.

## Process

### 1. Find the next pending item

From `.todo/todo.csv`, find the first pending item sorted by:
1. `severity`: critical → high → medium → low
2. `id` (ascending numeric prefix)

```python
import csv

SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3}

with open(".todo/todo.csv", newline="") as f:
    pending = [r for r in csv.DictReader(f) if r["status"] == "pending"]
pending.sort(key=lambda r: (SEVERITY_ORDER.get(r["severity"], 9), r["id"]))
next_item = pending[0] if pending else None
```

### 2. Read the detail file

Read the corresponding `.todo/{id}.md` file for full context:

```bash
cat .todo/01-itemlistscreen-god-screen.md
```

### 3. Mark in_progress

Before doing any work, update `.todo/todo.csv`:

```python
import csv, tempfile, os

target_id = "01-itemlistscreen-god-screen"
new_status = "in_progress"
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

### 4. Invoke saml-plan (sub-agent)

Invoke the `saml-plan` skill with context:
- Ticket ID
- Title
- Description
- Severity
- File paths from the detail file

The saml-plan skill will run its full process:
1. Setup (grill-with-docs to clarify scope)
2. Write plan to `.plan/YYYY-MM-DD-hh-mm-TICKET-ID.md`
3. Internal review-fix loop (no separate saml-plan-review invocation)

### 5. If saml-plan passes — Invoke saml-implement (sub-agent)

Once saml-plan succeeds, invoke `saml-implement` skill automatically. This:
1. Finds the plan file created by saml-plan
2. Launches a background sub-agent to implement from the plan
3. Runs review-fix loop until review passes or iteration limit reached
4. Writes commit message to `.git/GITGUI_MSG`

### 6. If saml-implement passes — Git commit

After saml-implement completes successfully, execute:

```bash
git add . && git commit --file .git/GITGUI_MSG
```

### 7. Mark done

Reuse the update snippet above with `new_status = "done"`.

### Error Handling

- If saml-plan fails: leave item as `in_progress`, report the review file for the user to address.
- If saml-implement fails after iteration limit: report remaining issues, do not commit, leave as `in_progress`.
- If git commit fails: report error, leave as `in_progress`.

## Workflow reference

From `saml-code-review` — "Working Through Todos":

> 1. Pick the next pending item from `.todo/todo.csv` (start with critical).
> 2. `saml-plan` → creates `.plan/YYYY-MM-DD-hh-mm-TICKET-ID.md`
> 3. `saml-implement` → implements from the plan, reviews, fixes. Only if `saml-plan` was successful.
> 4. Mark done in `.todo/todo.csv` only if `saml-implement` was successful.
> 5. Execute `git add .` and `git commit --file .git/GITGUI_MSG` to create a commit, only if successful.

`saml-todo-next` now handles all steps 1-5 automatically. User only invokes `saml-todo-next`.