# Requirements

## Functional Requirements

- FR-001: The future feature must analyze only the active Revit document.
- FR-002: The future feature must collect a read-only category summary with counts and safe display names.
- FR-003: The future feature must pass DTOs from the Revit layer to Application or Infrastructure boundaries.
- FR-004: The future feature must send minimized category summary data to the AI Gateway.
- FR-005: The future feature must display a concise AI-assisted summary to the user.
- FR-006: The future feature must report when no active document is available.

## Non-Functional Requirements

- NFR-001: The feature must not write to the Revit model.
- NFR-002: The feature must avoid long UI blocking operations.
- NFR-003: The feature must support cancellation or clear busy state if the AI Gateway call is slow.
- NFR-004: The feature must avoid provider-specific AI SDK dependencies in the Revit add-in.
- NFR-005: The feature must be testable without Revit where logic is outside the Revit adapter.

## Revit Version Matrix

| Version | Runtime | Requirement |
| --- | --- | --- |
| Revit 2024 | .NET Framework 4.8 | Use Revit API only in `RevitAiTemplate.Revit`; avoid .NET 8-only APIs in shared Revit-facing code. |
| Revit 2025 | .NET 8 Windows | Validate category summary behavior with Revit 2025 API references. |
| Revit 2026 | .NET 8 Windows | Validate category summary behavior with Revit 2026 API references. |
| Revit 2027 | .NET 10 Windows | Validate category summary behavior with Revit 2027 API references and `REVIT2027` guards if needed. |

## Security and Privacy Requirements

- SD-001: The AI Gateway request must not include geometry, customer secrets, file paths, or model exports.
- SD-002: Logs must include operation status and input summary only, not raw model data.
- SD-003: Prompt injection from model names, category names, or parameters must be treated as untrusted input.
- SD-004: AI output must be presented as advisory, not as authoritative Revit validation.

## Validation Requirements

- VR-001: Run `./scripts/validate-skills.ps1 -IncludeMirrors`.
- VR-002: Run `./scripts/check.ps1` where the local SDK supports the repository target frameworks.
- VR-003: Validate that any implementation diff stays within each task's `allowedPaths`.
- VR-004: Validate that no production code is changed by this documentation-only example.

## Assumptions

- The initial implementation would summarize categories in the active project document only.
- Linked documents, family documents, schedules, worksets, phases, and design options require explicit future scope.
- AI Gateway request and response DTOs already belong outside the Revit API project.
