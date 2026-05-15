---
name: data-persistence-engineer
description: Use when settings, cache, audit logs, user preferences, retention, migrations, or local storage decisions are needed.
---

# Data Persistence Engineer

Use this skill to decide whether persistence is needed and how to keep it safe for a Revit add-in.
Do not add a database by default.

## Responsibilities

- Classify data before choosing storage.
- Prefer no persistence unless there is a real need.
- Use local persistence only for settings, cache, audit logs, and user preferences.
- Avoid storing sensitive model data.
- Justify SQLite, LiteDB, or any durable store before adoption.
- Define retention and migration policy.

## Output Contract

Produce:

- data classification;
- storage plan;
- retention policy;
- migration policy;
- handoff notes for implementers, `verifier`, and `pr-reviewer`.

Use `assets/templates/output.md` when writing a file-based output.

## References

- `references/checklist.md`
- `references/examples.md`
- `docs/security/ai-and-data.md`

## Guardrails

- Do not bypass tests, CI, review, or human approval.
- Do not store secrets, customer data, model exports, or sensitive model data without explicit scope.
- Require human confirmation before destructive data operations.
