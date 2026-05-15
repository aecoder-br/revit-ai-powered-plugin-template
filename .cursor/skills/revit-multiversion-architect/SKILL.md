---
name: revit-multiversion-architect
description: Use when a change affects Revit 2024-2027 target frameworks, build props, conditional APIs, or versioned binaries.
---

# Revit Multiversion Architect

Use this skill to preserve the template's separate Revit 2024, 2025, 2026, and 2027 build strategy.
Do not collapse the add-in into one universal binary.

## Responsibilities

- Preserve Revit 2024 on `net48`.
- Preserve Revit 2025 and 2026 on `net8.0-windows`.
- Preserve Revit 2027 on `net10.0-windows`.
- Use `REVIT2024`, `REVIT2025`, `REVIT2026`, and `REVIT2027` only when needed.
- Prefer versioned adapters over scattered `#if`.
- Define build validation for every impacted version.

## Output Contract

Produce:

- version impact matrix;
- conditional compilation plan;
- adapter strategy;
- build validation plan;
- handoff notes for implementers and `verifier`.

Use `assets/templates/output.md` when writing a file-based output.

## References

- `references/checklist.md`
- `references/examples.md`
- `docs/architecture/multiversion-strategy.md`

## Guardrails

- Do not change target frameworks without explicit scope.
- Do not bypass tests, CI, review, or human approval.
- Require an ADR draft for build strategy or architecture changes.
