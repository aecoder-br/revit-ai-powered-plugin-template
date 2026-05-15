# Cybersecurity and Privacy Handoff

## Security Review Scope

Review the future feature as a read-only Revit-to-AI Gateway workflow. No write operation, MCP write tool, or arbitrary Revit API execution is allowed.

## Data Classification

- Category names: potentially customer-sensitive.
- Element counts: low sensitivity but still model metadata.
- File paths, usernames, project numbers, geometry, parameter values, and exports: disallowed by default.

## Risks

- Model data leakage through overbroad AI Gateway request payloads.
- Prompt injection through category names, model names, or user-provided notes.
- Logging raw model metadata or prompts.
- Treating AI output as deterministic validation.

## Required Controls

- Minimize request payloads before calling AI Gateway.
- Sanitize model-derived text before prompt composition.
- Log tool name, operation status, and safe summaries only.
- Keep provider credentials out of the Revit process.
- Require human confirmation for any future write expansion.

## Handoff To PR Reviewer

Verify that final documentation and future implementation plans keep the feature read-only, preserve project boundaries, and avoid broad MCP or AI provider permissions.
