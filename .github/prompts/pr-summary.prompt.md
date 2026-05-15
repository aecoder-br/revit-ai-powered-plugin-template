---
mode: agent
description: Produce a PR summary and review checklist for a completed change.
---

<!-- Generated prompt adapter. Source: AGENTS.md, .agents/skills/pr-reviewer/SKILL.md, .agents/workflows/handoff-contract.md, .agents/workflows/validation-gates.md. -->

# PR Summary

Use `AGENTS.md` and `.agents/skills/pr-reviewer/SKILL.md`.
Use `.agents/workflows/handoff-contract.md` and `.agents/workflows/validation-gates.md`.

Summarize the diff, architecture impact, Revit API context, security/privacy impact, tests run, docs changed, and residual risks.
Do not hide failed or skipped validation.
