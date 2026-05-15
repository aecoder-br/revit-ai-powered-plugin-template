# Handoff Contract

Use this format when work moves from one agent, role, or branch to another.

## Required Fields

```md
## Handoff

Task:
Owner:
Branch:
Worktree:
Owned paths:
Next owner:

## Completed

- ...

## Changed files

- ...

## Validation

- Command:
  Result:
  Notes:

## Revit API and threading review

- Revit API touched:
- Valid context:
- ExternalEvent required:
- Transaction required:
- Transaction name:

## Security and data handling

- Secrets touched:
- External data sharing:
- Model data exported:
- Audit/logging impact:

## Open risks

- ...

## Next steps

- ...
```

## Rules

- Be specific about file paths.
- Include exact validation commands and outcomes.
- State skipped validation clearly.
- Include environment blockers such as missing SDKs or missing Revit installations.
- Do not claim a build passed if it only skipped the relevant target.
- Do not hide unresolved merge conflicts or generated file churn.

## Minimal Handoff Example

```md
## Handoff

Task: Add Visual Studio solution
Owner: visual-studio-template-engineer
Branch: agent/visual-studio-template-engineer/add-sln
Worktree: C:\worktrees\revit-ai-template-add-sln
Owned paths: RevitAiTemplate.sln, README.md, scripts/check.ps1
Next owner: verifier

## Completed

- Added root solution with existing projects.
- Documented Visual Studio opening instructions.

## Validation

- Command: dotnet sln RevitAiTemplate.sln list
  Result: Passed.
  Notes: Listed all expected projects.
```
