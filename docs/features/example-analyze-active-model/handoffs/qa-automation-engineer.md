# QA Automation Engineer Handoff

## Test Strategy

This example is documentation-only. Future implementation should separate unit tests, adapter tests with fakes, and manual Revit smoke testing.

## Unit Tests

- Category summary DTOs contain only approved fields.
- Empty model summary returns a clear result.
- AI Gateway unavailable returns a recoverable error.
- Prompt/request builder redacts disallowed fields.

## Integration-Like Tests Without Revit

- Application use case accepts DTOs without Revit API references.
- AI Gateway client handles timeout, cancellation, and structured error responses.
- ViewModel state transitions cover loading, success, empty, cancelled, and failed states.

## Manual Revit Smoke Tests

- Revit 2024: project document with several categories.
- Revit 2025: empty or minimal project.
- Revit 2026: model with linked files excluded.
- Revit 2027: confirm .NET 10 build and summary behavior.

## Validation Commands

```powershell
./scripts/validate-skills.ps1 -IncludeMirrors
./scripts/check.ps1
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027
```

If a Revit version or SDK is not installed, record the skipped validation explicitly.

## Handoff To Security

Review model data minimization, prompt injection handling, logging, and AI Gateway boundary behavior.
