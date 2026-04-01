---
name: saml-scan
description: >
  Scans code base and updates `.github/copilot-instructions.md` with the latest info.
  This should be triggered every time you scan code base.
---

# Process

When this skill is invoked, execute the following phases in order.

---

# Phase 1 - Scan

1. Read `.github/copilot-instructions.md` if it exists to understand project conventions.

2. Explore the codebase if you haven't done yet.

3. Compare what's in `.github/copilot-instructions.md` and findings from the exploration of the codebase.

4. Update `.github/copilot-instructions.md` to match current codebase.

   `.github/copilot-instructions.md` should contain:
   - How to build and run the project.
   - How to run tests.
   - How to run formatter and linter.
   - Key folder structure so that agents don't need to scan full codebase over and over again.

---

# Phase 2 - Review (current model, background sub-agent)

1. Launch a subagent to review the updated `.github/copilot-instructions.md` as a senior engineer.

2. Review subagent reports any problems and improvements you can make.

---

# Phase 3 - Amend loop (GPT-5.4 mini, backgrond sub-agent)

1. Launch a **background sub-agent** using model **GPT-5.4 mini** to read the review report and amend `.github/copilot-instructions.md` according to the report.

2. Loop review and amend phases until `.github/copilot-instructions.md` passes review.
