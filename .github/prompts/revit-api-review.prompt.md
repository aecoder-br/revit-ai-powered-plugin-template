---
mode: agent
description: Review Revit API usage and threading boundaries.
---

<!-- Generated prompt adapter. Source: AGENTS.md, .agents/skills/revit-api-senior/SKILL.md, .agents/workflows/validation-gates.md. -->

# Revit API Review

Use `AGENTS.md` and `.agents/skills/revit-api-senior/SKILL.md`.
Use `.agents/workflows/validation-gates.md` for validation expectations.

Review that Revit API code stays in `src/RevitAiTemplate.Revit`.
Check ExternalEvent routing, valid API context, named transactions, DTO boundaries, selection, active document, linked documents, units, family documents, and worksharing risk.
Report findings before any summary.
