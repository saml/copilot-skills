---
name: saml-todo-next
description: >
  Picks the next pending todo item from .todo/todo.csv (sorted by severity: critical → high → medium → low),
  then automatically executes the full pipeline: saml-plan → saml-implement → git commit → mark done.
  No user interaction needed after invocation.
---

# saml-todo-next Skill

Loops through ALL pending todo items until none remain. Each item goes through: plan → implement → commit → done.

## Process

**LOOP**: Repeat steps 1–3 until no pending items remain. Each iteration processes one item in a fresh sub-agent context and creates one commit.

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

**If `next_item` is None → all items are done. Print summary and stop.**

### 2. Read the detail file

Read the corresponding `.todo/{id}.md` file for full context:

```bash
cat .todo/{id}.md
```

### 3. Launch fresh sub-agent to process item

Launch a **single general-purpose task sub-agent** with a fresh context. This sub-agent is **stateless** — pass all context it needs in the prompt. The sub-agent will:

1. Mark the item as `in_progress` in `.todo/todo.csv`
2. Invoke `saml-plan` skill (automation mode — no interactive questions)
3. If plan passes: invoke `saml-implement` skill with the plan file path
4. If implement passes: `git add . && git commit --file .git/GITGUI_MSG`
5. Mark item as `done` in `.todo/todo.csv`
6. Return result (success/failure + plan file path + summary)

#### Sub-agent context

Pass the following in the sub-agent prompt:

**Todo item details:**
- ID: `{next_item["id"]}`
- Title: `{next_item["title"]}`
- Description: `{next_item["description"]}`
- Severity: `{next_item["severity"]}`

**Detail file:**
```
{contents of .todo/{id}.md}
```

**Project context (to help the sub-agent navigate):**
- AGENTS.md contents (list of available skills)
- Makefile if present in project root

**Explicit instruction in prompt:**
> This is automation mode. You are processing a single todo item.
> - Invoke `saml-plan` skill WITHOUT interactive questions (automation mode).
> - Pass the todo details as context to saml-plan.
> - After plan succeeds, invoke `saml-implement` with the exact plan file path.
> - After implement succeeds, run: `git add . && git commit --file .git/GITGUI_MSG`
> - Mark item done in .todo/todo.csv
> - Report: STATUS: PASS|FAIL, plan file path, summary

#### Sub-agent expected output

The sub-agent must report back:
- `STATUS: PASS` or `STATUS: FAIL`
- Plan file path (e.g., `.plan/2025-01-15-14-30-01-itemlistscreen.md`)
- If FAIL: reason and which step failed (plan/implement/commit/mark-done)

#### Error handling for this step

- **Sub-agent returns `STATUS: FAIL`**: Stop the loop. Report the failure reason and which step failed. Leave item as `in_progress` in `.todo/todo.csv`.
- **Sub-agent times out or crashes**: Stop the loop. Leave item as `in_progress` in `.todo/todo.csv`. Report timeout/crash.

**→ Loop: Go back to Step 1 to process next item (if sub-agent succeeded and reported PASS).**

### Error Handling

- **Sub-agent returns `STATUS: FAIL`**: Stop processing. Report the failure reason and which step failed. Leave item as `in_progress` in `.todo/todo.csv`.
- **Sub-agent times out or crashes**: Stop processing. Leave item as `in_progress`. Report timeout/crash to user.
- **Normal completion after all items done**: Print summary of completed items and commits.

On any error, output a summary of:
- Items completed (marked `done`)
- Items in progress that encountered errors
- Next steps for the user

## Workflow reference

From `saml-code-review` — "Working Through Todos":

> 1. Pick the next pending item from `.todo/todo.csv` (start with critical).
> 2. `saml-plan` → creates `.plan/YYYY-MM-DD-hh-mm-TICKET-ID.md`
> 3. `saml-implement` → implements from the plan, reviews, fixes. Only if `saml-plan` was successful.
> 4. Mark done in `.todo/todo.csv` only if `saml-implement` was successful.
> 5. Execute `git add .` and `git commit --file .git/GITGUI_MSG` to create a commit, only if successful.
> 6. Repeat from step 1 until no pending items remain.

`saml-todo-next` handles all steps 1-6 automatically. User only invokes `saml-todo-next` once and it processes every pending item, one commit per item.