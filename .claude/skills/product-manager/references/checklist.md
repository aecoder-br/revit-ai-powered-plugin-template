# Product Manager Checklist

Use this checklist before producing `docs/features/<feature-id>/brief.md`.

## Intake

- Capture the source user request.
- Identify the business outcome in one sentence.
- Identify the target user or persona.
- Identify the Revit workflow context:
  - project;
  - family;
  - view;
  - selection;
  - schedule;
  - parameters;
  - export;
  - ACC/APS;
  - documentation.

## Discovery

- Define the problem statement.
- Describe current workflow and pain points.
- Describe proposed workflow at a product level.
- Identify success metrics.
- Identify constraints and out-of-scope items.
- List assumptions separately from confirmed requirements.
- List open questions when the request is ambiguous.

## Revit and AI Safety

- Identify whether the feature reads or writes the Revit model.
- Identify whether it needs `ExternalEvent`.
- Identify impacted Revit versions: 2024, 2025, 2026, 2027.
- Identify whether runtime AI, MCP, or AI Gateway behavior is involved.
- Identify privacy or model-data-sharing concerns.

## Handoff

- Save the brief under `docs/features/<feature-id>/brief.md`.
- Recommend the next skill, normally `requirements-analyst`.
- Tell `orchestrator-feature-lead` which paths should be owned next.
- Request an ADR draft when the feature changes architecture, public workflow, runtime AI, MCP behavior, or version strategy.
