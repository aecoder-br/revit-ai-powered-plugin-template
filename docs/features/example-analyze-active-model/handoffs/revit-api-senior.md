# Revit API Senior Handoff

## API Context Review

Future implementation must collect model data only in a valid Revit API context. If the command is triggered from modeless UI, WebView2, MCP, background work, or an AI callback, the request must enter Revit through ExternalEvent before reading the active document.

## Boundary Rules

- `Document`, `UIDocument`, `Element`, and Revit API collections must not leave `src/RevitAiTemplate.Revit`.
- Cross-boundary data should be immutable DTOs with safe names, counts, and stable identifiers only when needed.
- Core, Application, UI, MCP, and AI Gateway projects must not reference `Autodesk.Revit.*`.

## Transaction Plan

No transaction is required. This is a read-only feature.

## Review Notes

- Handle no active document.
- Treat family documents and linked documents as explicit scope decisions.
- Avoid assuming every category has the same visibility, element count behavior, or parameter surface across Revit versions.
- Keep Revit 2024, 2025, 2026, and 2027 validation separate.

## Handoff To QA Automation Engineer

Create tests around DTO shaping, request minimization, error handling, and Application-level behavior without Revit dependencies. Revit runtime behavior should use a manual smoke checklist unless a Revit-enabled test runner exists.
