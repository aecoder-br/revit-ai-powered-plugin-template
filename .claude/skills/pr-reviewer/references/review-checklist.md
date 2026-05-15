# Review Checklist

Use this checklist for final diff and PR review.

## Diff Scope

- Identify all changed files.
- Confirm each changed file belongs to the task scope.
- Confirm generated files are intentional.
- Confirm no unrelated formatting churn is present.

## Architecture

- Confirm Core and Application do not reference `Autodesk.Revit.*`.
- Confirm WPF UI does not call Revit API directly.
- Confirm Revit API work stays in `src/RevitAiTemplate.Revit`.
- Confirm DTOs, stable ids, or ports cross project boundaries instead of Revit objects.
- Confirm runtime LLM calls go through the AI Gateway.

## Revit Safety

- Confirm Revit API calls run inside a valid Revit API context.
- Confirm modeless UI, WebView2, MCP, background tasks, and named pipes use ExternalEvent before touching Revit.
- Confirm write operations use named transactions.
- Confirm rollback behavior exists for write tools.
- Confirm version-specific code is guarded for Revit 2024, 2025, 2026, and 2027.

## Security and Privacy

- Confirm no secrets, API keys, tokens, customer data, or model exports are committed.
- Confirm MCP tools are deterministic and narrow.
- Confirm write tools require confirmation and audit logging.
- Confirm external network or file-system behavior is documented and justified.

## Tests and Validation

- Confirm tests were added or updated for behavior changes.
- Confirm validation commands were run.
- Confirm failed or skipped validation is reported.
- Confirm missing SDKs or Revit installations are called out.

## Documentation

- Confirm docs changed when architecture, public behavior, AI tools, MCP tools, setup, or workflows changed.
- Confirm README and AGENTS changes are concise.
- Confirm long process detail lives in docs or `.agents`, not in `AGENTS.md`.

## PR Summary Template

```md
## Summary

- ...

## Validation

- ...

## Risk

- ...

## Notes for reviewers

- ...
```

## Review Result

Use:

- `Pass` when no blocking findings remain.
- `Fail` when correctness, architecture, safety, validation, or scope problems remain.
- `Pass with risks` only when risks are documented and acceptable for the requested task.
