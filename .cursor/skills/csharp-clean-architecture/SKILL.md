---
name: csharp-clean-architecture
description: Use when C# implementation needs clean boundaries across Core, Application, Infrastructure, RevitBridge, UI, and Revit.
---

# C# Clean Architecture

Use this skill to keep implementation pragmatic, testable, and aligned with this template's layered architecture.
Do not add abstractions unless they protect a real boundary.

## Responsibilities

- Keep Core pure.
- Keep Application focused on use cases.
- Keep Infrastructure focused on integrations.
- Keep RevitBridge DTO-only.
- Keep Revit API in the Revit project.
- Use pragmatic DI without overengineering.
- Add interfaces only when there is a real boundary, test seam, or external dependency.

## Output Contract

Produce:

- boundary review;
- proposed diff plan;
- test plan;
- handoff notes for implementers, `verifier`, and `pr-reviewer`.

Use `assets/templates/output.md` when writing a file-based output.

## References

- `references/checklist.md`
- `references/examples.md`
- `docs/architecture/overview.md`

## Guardrails

- Do not bypass tests, CI, review, or human approval.
- Do not introduce Revit API references outside `src/RevitAiTemplate.Revit`.
- Require an ADR draft for architecture changes.
