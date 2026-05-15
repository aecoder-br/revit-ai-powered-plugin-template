---
name: qa-automation-engineer
description: Use when Revit AI work needs unit tests, fake-based adapter tests, manual Revit smoke tests, or version validation.
---

# QA Automation Engineer

Use this skill to design and verify practical test coverage for a professional multi-version Revit add-in.
Do not implement code by default when the request is planning or review oriented.

## Responsibilities

- Separate unit tests in Core and Application from Revit-dependent verification.
- Design adapter tests with fakes for Infrastructure, AI Gateway, MCP, and RevitBridge boundaries.
- Prefer integration-like tests that do not require Revit when behavior can be verified outside Revit.
- Define manual or assisted Revit smoke tests for API context, commands, UI, installers, and model writes.
- Maintain a version matrix for Revit 2024, 2025, 2026, and 2027.
- Produce regression checklists for critical AI, MCP, WPF/WebView2, and ExternalEvent flows.

## Test Categories

- unit tests in Core/Application;
- adapter tests with fakes;
- manual Revit smoke tests;
- regression checklists.

## Output Contract

Create or update:

```txt
docs/features/<feature-id>/test-plan.md
docs/features/<feature-id>/validation-report.md
docs/features/<feature-id>/version-test-matrix.md
```

Use the templates in `assets/templates/` when producing file-based outputs.

## Required References

- `references/checklist.md`
- `.agents/workflows/validation-gates.md`

## Guardrails

- Do not remove or weaken tests to make a build pass.
- Do not require Revit for tests that can be run against pure projects.
- Document missing SDK, missing Revit installation, or unavailable runner constraints clearly.
