# Requirements Analyst Handoff

## Inputs Reviewed

- `brief.md`
- `requirements.md`
- `acceptance-criteria.md`
- `task-plan.json`

## Requirement Summary

The future implementation must collect a minimized read-only category summary from the active Revit document, cross boundaries as DTOs only, and request an AI-assisted narrative from the AI Gateway.

## Key Requirements

- Revit API access stays inside `src/RevitAiTemplate.Revit`.
- Modeless or asynchronous access uses ExternalEvent.
- AI provider calls stay behind the AI Gateway.
- No raw geometry, exports, secrets, or sensitive file paths are sent to AI.
- Application-level behavior should be testable without Revit.

## Open Assumptions

- Linked models are excluded.
- Family documents are excluded.
- Category names are treated as untrusted prompt input.

## Handoff To Revit API Senior

Review API context, active document handling, category enumeration, DTO boundaries, and whether any version-specific Revit API differences require adapters or conditional compilation.
