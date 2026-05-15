# Verification Checklist

Use this checklist to verify a task.

## Inputs

- User request.
- Task plan or handoff.
- Owned paths.
- Changed files.
- Validation requirements.
- Known environment constraints.

## Completion Check

- Confirm each acceptance criterion is addressed.
- Confirm no explicit non-goal was implemented.
- Confirm docs were updated when public behavior, architecture, AI tools, MCP tools, or workflows changed.

## Path Ownership Check

- List changed files.
- Compare each changed file against owned paths.
- Fail if any file is outside owned paths and no approved handoff exists.
- Fail if Revit API references appear outside `src/RevitAiTemplate.Revit`.

## Revit API and Threading Check

Apply when any Revit, WPF, MCP, bridge, named pipe, WebView2, or background task code changed.

- Confirm Revit API calls happen only inside valid Revit API contexts.
- Confirm modeless UI, WebView2, MCP, background tasks, and named pipes use the ExternalEvent queue before touching Revit.
- Confirm write operations use named transactions.
- Confirm version-specific APIs are guarded by `REVIT2024`, `REVIT2025`, `REVIT2026`, or `REVIT2027` as needed.

## Security and Data Handling Check

- Confirm no secrets, API keys, tokens, customer data, or model exports were added.
- Confirm runtime LLM calls go through the AI Gateway.
- Confirm MCP tools are deterministic and narrowly scoped.
- Confirm write tools require confirmation, audit logging, and rollback behavior.

## Validation Commands

Prefer:

```powershell
./scripts/validate-skills.ps1
./scripts/check.ps1
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027
```

Record exact failures and skipped Revit versions.

## Report Format

```md
# Verification Report

Status: Pass | Fail

## Evidence

- ...

## Checks Run

- Command:
  Result:
  Notes:

## Path Ownership

- ...

## Revit API and Threading

- ...

## Security and Data Handling

- ...

## Failures

- ...

## Residual Risk

- ...
```
