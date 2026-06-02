---
name: saml-todo
description: >
  Lists todo items from .todo/todo.csv. Shows all items, or filters by status/severity.
  Can update item status (pending, in_progress, done, blocked).
  Source of truth: `.todo/todo.csv`.
---

# saml-todo Skill

Lists and manages todo items from `.todo/todo.csv`.

## Commands

### List all todos

```python
import csv

SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3}

with open(".todo/todo.csv", newline="") as f:
    rows = sorted(csv.DictReader(f), key=lambda r: (SEVERITY_ORDER.get(r["severity"], 9), r["id"]))
for r in rows:
    print(f'{r["severity"]} [{r["status"]}] {r["id"]} - {r["title"]}')
```

### List by status

```python
import csv

target_status = "pending"  # pending | in_progress | done | blocked
with open(".todo/todo.csv", newline="") as f:
    rows = [r for r in csv.DictReader(f) if r["status"] == target_status]
for r in rows:
    print(f'{r["severity"]} [{r["status"]}] {r["id"]} - {r["title"]}')
```

### List by severity

```python
import csv

target_severity = "critical"  # critical | high | medium | low
with open(".todo/todo.csv", newline="") as f:
    rows = [r for r in csv.DictReader(f) if r["severity"] == target_severity]
for r in rows:
    print(f'{r["severity"]} [{r["status"]}] {r["id"]} - {r["title"]}')
```

### Summary counts

```python
import csv
from collections import Counter

with open(".todo/todo.csv", newline="") as f:
    counts = Counter(r["severity"] for r in csv.DictReader(f))
for sev in ["critical", "high", "medium", "low"]:
    print(f"{sev}: {counts.get(sev, 0)}")
```

### Show next pending item

```python
import csv

SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3}

with open(".todo/todo.csv", newline="") as f:
    pending = [r for r in csv.DictReader(f) if r["status"] == "pending"]
pending.sort(key=lambda r: (SEVERITY_ORDER.get(r["severity"], 9), r["id"]))
next_item = pending[0] if pending else None
if next_item:
    print(f'{next_item["severity"]} [{next_item["status"]}] {next_item["id"]} - {next_item["title"]}')
else:
    print("No pending items.")
```

### Show a specific todo's detail

```python
import csv

with open(".todo/todo.csv", newline="") as f:
    rows = [r for r in csv.DictReader(f) if r["id"] == "01-itemlistscreen-god-screen"]
if rows:
    print(rows[0])
else:
    print("Not found.")
```

### View the corresponding plan file

```bash
cat .todo/01-itemlistscreen-god-screen.md
```

## Updating Status

### Update status
```python
import csv, tempfile, os

target_id = "01-itemlistscreen-god-screen"
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

Set `new_status` to one of: `pending`, `in_progress`, `done`, `blocked`.

## Filter flags

When invoked with no arguments, list all todos sorted by severity then id.

When invoked with `--pending`, list only pending todos.
When invoked with `--critical`, list only critical todos.
When invoked with `--done`, list all completed todos.

## Todo item file format

Each item also has a corresponding `.todo/NN-TICKET-ID.md` with full details:

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

## Workflow reference

From `saml-code-review`:

To work through todos automatically:
1. Pick the next pending item from `.todo/todo.csv` (start with critical).
2. `saml-plan` → creates `.plan/YYYY-MM-DD-hh-mm-TICKET-ID.md`
3. `saml-implement` → implements from the plan, reviews, fixes. Only if `saml-plan` was successful.
4. Mark done in `.todo/todo.csv` only if `saml-implement` was successful.
5. Execute `git add .` and `git commit --file .git/GITGUI_MSG` to create a commit, only if successful.

To view current status:
```python
import csv

SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3}

with open(".todo/todo.csv", newline="") as f:
    rows = sorted(csv.DictReader(f), key=lambda r: (SEVERITY_ORDER.get(r["severity"], 9), r["id"]))
for r in rows:
    print(f'{r["severity"]} [{r["status"]}] {r["id"]} - {r["title"]}')
```