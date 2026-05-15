---
name: wpf-webview2-ux-ui
description: Use when WPF, MVVM, WebView2, modeless UI, Revit UX, loading, cancellation, or error states are involved.
---

# WPF WebView2 UX UI

Use this skill for Revit-friendly desktop UI work.
Treat WebView2 as UI runtime, not domain logic.

## Responsibilities

- Keep MVVM simple.
- Keep UI code free of direct Revit API calls.
- Route Revit interaction through application ports and ExternalEvent-backed services.
- Design Revit-appropriate dockable or modeless workflows.
- Include clear feedback, cancellation, loading state, error state, accessibility, and resilient layout.
- Hand off implementation constraints to `revit-api-senior` when UI triggers model access.

## Output Contract

Produce:

- UX flow;
- ViewModel plan;
- UI state model;
- error states;
- handoff notes for implementers and `verifier`.

Use `assets/templates/output.md` when writing a file-based output.

## References

- `references/checklist.md`
- `references/examples.md`
- `docs/architecture/revit-api-boundary.md`

## Guardrails

- Do not bypass tests, CI, review, or human approval.
- Do not call Revit API from UI, ViewModels, WebView2 handlers, or background tasks.
- Require human confirmation before destructive actions or write tools.
