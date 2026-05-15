# Validation Gates

Use these gates to select validation by task type.

## Always

- Inspect the final diff.
- Verify no unexpected generated files were added.
- Verify no secrets, API keys, tokens, customer data, or model exports were added.
- Verify `AGENTS.md` remains concise and delegates long workflow detail to canonical docs.

## Documentation Only

- Verify links and paths are accurate.
- Verify docs match the current repository structure.
- Run `git diff --check` when available.

## C# Domain or Application

- Run:

```powershell
./scripts/check.ps1
```

- Add or update tests when behavior changes.
- Confirm no `Autodesk.Revit.*` dependency was introduced outside `src/RevitAiTemplate.Revit`.

## Revit API Adapter

- Run:

```powershell
./scripts/check.ps1
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027
```

- If a Revit version is not installed, record the skipped version and install path.
- Confirm Revit API calls happen in a valid Revit API context.
- Confirm modeless UI, MCP, named pipes, WebView2, and background work use the ExternalEvent queue before touching Revit.
- Confirm write operations use named transactions and a rollback strategy.

## WPF or WebView2

- Run `./scripts/check.ps1`.
- Confirm UI code does not call Revit API directly.
- Confirm ViewModels use application ports, DTOs, or ExternalEvent-routed services.
- Review modeless threading behavior.

## MCP Tooling

- Run `./scripts/check.ps1`.
- Confirm tools are deterministic and documented.
- Confirm read-only and write tools are separated.
- Confirm write tools require confirmation, audit logging, and transaction rollback behavior.
- Confirm no broad arbitrary Revit API execution tool was introduced.

## AI Gateway

- Run `./scripts/check.ps1`.
- Confirm runtime LLM calls go through the AI Gateway.
- Confirm secrets are not stored in the repository.
- Confirm redaction, policy, audit, and provider routing implications are documented when behavior changes.

## Build, Installer, Template, or Release

- Run `./scripts/check.ps1`.
- Run affected `./scripts/build.ps1 -RevitVersion <year>` commands.
- Validate generated output in a temporary directory when changing templates.
- Confirm `.sln` remains the compatibility solution format unless a task explicitly adds another format.

## Agent Skill or Workflow

- Validate JSON files with a parser.
- Verify skill names are lowercase kebab-case.
- Verify each `SKILL.md` has frontmatter with `name` and `description`.
- Keep long process detail in references or workflows, not `AGENTS.md`.
