---
name: revit-api-senior
description: Use when implementation touches Revit API context, ExternalEvent routing, transactions, selection, parameters, or model writes.
---

# Revit API Senior

Use this skill for high-risk Revit API work in a professional AI-powered Revit add-in.
Do not implement code by default when the request is planning or review oriented.

## Responsibilities

- Keep Revit API usage inside `src/RevitAiTemplate.Revit`.
- Prevent Revit API objects from leaking into Core, Application, Infrastructure, UI, or bridge contracts.
- Route modeless UI, WPF, WebView2, MCP, named pipe, and background work through `ExternalEvent`.
- Require named `Transaction` boundaries for model writes.
- Prefer read-only tools and queries before write workflows.
- Review selection, active document, linked documents, units, parameters, shared parameters, family docs, and worksharing.

## Output Contract

Produce:

- implementation plan;
- API context review;
- transaction plan;
- risk list;
- handoff notes for implementers, `verifier`, and `pr-reviewer`.

Use `assets/templates/output.md` when writing a file-based output.

## References

- `references/checklist.md`
- `references/examples.md`
- `.agents/workflows/validation-gates.md`

## Guardrails

- Do not bypass tests, CI, review, or human approval.
- Require human confirmation before destructive actions or write tools.
- Never create a broad arbitrary Revit API execution tool.
