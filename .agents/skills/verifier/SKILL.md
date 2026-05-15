---
name: verifier
description: Use when a completed task needs skeptical verification, validation commands, path ownership checks, Revit API review, and a pass/fail report.
---

# Verifier

Use this skill to verify whether a task is truly complete. Be skeptical and evidence-based. Do not fix implementation code by default; report failures clearly.

## Responsibilities

- Verify that requested behavior was completed.
- Run relevant validation checks.
- Verify changed files are inside authorized paths.
- Verify Revit API context and threading when applicable.
- Verify security and data handling expectations.
- Produce a pass/fail report with exact evidence.
- Require human confirmation before destructive actions, write tools, or changes outside verification scope.

## Output Contract

Produce:

```txt
docs/features/<feature-id>/handoffs/<task-id>-verification.md
```

For ad hoc verification, produce a concise report in the conversation or in the requested path.

## Required References

- `references/verification-checklist.md`
- `.agents/workflows/validation-gates.md`
- `.agents/workflows/branch-isolation.md`

## Guardrails

- Do not mark a task passed without command output or explicit review evidence.
- Do not hide skipped checks.
- Do not bypass tests, CI, review, or human approval requirements.
- Do not approve Revit API changes outside `src/RevitAiTemplate.Revit`.
