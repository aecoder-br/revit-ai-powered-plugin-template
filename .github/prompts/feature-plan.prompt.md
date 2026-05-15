---
name: feature-plan
description: Plan a Revit AI template feature without implementing code.
agent: plan
argument-hint: <feature request or feature-id>
---

# Feature Plan

Use `AGENTS.md` as the repository rule source.
Use `.agents/skills/orchestrator-feature-lead/SKILL.md`.
Follow `.agents/workflows/feature-lifecycle.md`, `.agents/workflows/branch-isolation.md`, and `.agents/workflows/handoff-contract.md`.

Work in plan mode. Do not implement code.

Produce or update:

- `docs/features/<feature-id>/brief.md`
- `docs/features/<feature-id>/requirements.md`
- `docs/features/<feature-id>/task-plan.json`
- `docs/features/<feature-id>/handoffs/`

List ambiguities, assumptions, assigned skills, path ownership, validation gates, and recommended execution order.
