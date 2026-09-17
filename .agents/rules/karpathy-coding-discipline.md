# Karpathy Coding Discipline — Enforcement Checklist

This rule provides concrete enforcement checks for every code change the agent makes,
derived from Andrej Karpathy's principles.

---

## Pre-Implementation Checklist

Before writing ANY code, the agent MUST:

- [ ] **Restate the task** in one sentence to confirm understanding
- [ ] **List assumptions** — anything not explicitly stated by the user
- [ ] **Flag ambiguity** — if the request has multiple valid interpretations, present them and ask
- [ ] **Propose the simplest approach** — default to the minimum viable solution
- [ ] **Identify affected files** — list only the files that MUST change

If any checkbox cannot be satisfied, **stop and ask the user**.

---

## During Implementation

### Simplicity Gate

For every function, class, or module you create or modify, ask:

1. Is this the **shortest** reasonable implementation?
2. Am I adding anything the user **didn't ask for**?
3. Would a **senior engineer** call this overcomplicated?

If YES to #2 or #3 → simplify before continuing.

### Surgical Change Gate

For every edit to an existing file:

1. Can I trace this line change **directly** to the user's request?
2. Am I touching **adjacent code** that isn't part of the task?
3. Am I changing **comments, formatting, or style** beyond my scope?

If YES to #2 or #3 → revert that change.

### Orphan Cleanup

After your changes:

- Remove imports YOUR changes made unused ✅
- Remove variables YOUR changes made unused ✅
- Remove functions YOUR changes made unused ✅
- Do NOT remove pre-existing dead code ❌

---

## Post-Implementation Verification

Before presenting the result:

- [ ] **Diff review** — every changed line traces to the user's request
- [ ] **No scope creep** — no unrequested features, refactors, or "improvements"
- [ ] **Tests pass** — if tests exist, run them. If the task warrants a test, write one
- [ ] **Style match** — new code matches the existing codebase style, not your preference

---

## Red Flags — Immediate Stop Conditions

If you catch yourself doing any of these, **stop and reconsider**:

- 🚩 Writing a generic utility when a specific solution would work
- 🚩 Adding configuration/options the user didn't mention
- 🚩 Creating an abstraction layer for code used in only one place
- 🚩 "While I'm here" improvements to nearby code
- 🚩 Error handling for scenarios that can't actually occur
- 🚩 Renaming existing variables/functions for "clarity" when not asked
- 🚩 Deleting comments you don't understand
- 🚩 Restructuring imports or file organization beyond your task scope
