---
name: saml-todo-del
description: >
  Deletes all `.todo/*.md` files for done items and removes done rows from `.todo/todo.csv`.
  Use to clean up completed work.
---

Clean up completed todo items using the following script:

```python
import csv, os, tempfile

csv_path = ".todo/todo.csv"
fieldnames = ["id", "title", "description", "status", "severity"]

with open(csv_path, newline="") as f:
    rows = list(csv.DictReader(f))

done_rows = [r for r in rows if r["status"] == "done"]
remaining_rows = [r for r in rows if r["status"] != "done"]

if not done_rows:
    print("No done items to delete.")
else:
    # Delete .md files for done items
    for r in done_rows:
        md_path = f'.todo/{r["id"]}.md'
        if os.path.exists(md_path):
            os.remove(md_path)
            print(f'Deleted: {md_path}')
        else:
            print(f'Skipped (not found): {md_path}')

    # Rewrite CSV without done rows
    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile("w", dir=".todo", delete=False, newline="", suffix=".csv") as tmp:
            tmp_path = tmp.name
            writer = csv.DictWriter(tmp, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(remaining_rows)
        os.replace(tmp_path, csv_path)
    except Exception:
        if tmp_path and os.path.exists(tmp_path):
            os.unlink(tmp_path)
        raise

    print(f"\n✅ Deleted {len(done_rows)} done item(s) from .todo/todo.csv")
```

Run this script in the project's working directory to delete all completed todo items.

**Process:**
1. Reads `.todo/todo.csv` to identify all items with `status == "done"`
2. Deletes corresponding `.todo/{id}.md` files (skips silently if not found)
3. Rewrites `.todo/todo.csv` with only non-done rows using atomic replace
4. Reports what was deleted

**Edge Cases:**
- **No done items**: Prints "No done items to delete." and exits cleanly
- **Missing `.md` file**: Skips with "Skipped (not found)" message
- **Partial failure**: CSV is rewritten last, so if `.md` deletion fails midway, done entries remain in CSV for retry

**Prerequisites:**
- `.todo/todo.csv` must exist (script will raise FileNotFoundError if missing)
