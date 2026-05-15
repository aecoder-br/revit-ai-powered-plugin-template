# AGENTS.md

## Role

You are working on a professional Autodesk Revit add-in template. Treat Revit API code as high-risk desktop automation code.

## Canonical architecture

- Domain and application code must not reference `Autodesk.Revit.*`.
- WPF UI must not call Revit API directly.
- Revit API calls must happen only inside a valid Revit API context: `IExternalCommand`, `IExternalApplication`, events, updaters, or `ExternalEvent` handlers.
- Modeless UI, WebView2, MCP, background tasks, and named pipes must use the ExternalEvent queue before touching Revit.
- Prefer read-only tools first. Any write tool must require explicit confirmation and use a named `Transaction`.

## Version rules

- Revit 2024 builds against .NET Framework 4.8.
- Revit 2025 and 2026 build against .NET 8 Windows.
- Revit 2027 builds against .NET 10 Windows.
- Never assume APIs are available across all versions. Use `REVIT2024`, `REVIT2025`, `REVIT2026`, `REVIT2027` constants.
- Do not collapse all versions into a single binary.

## Build commands

```powershell
./scripts/check.ps1
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027
```

If a Revit version is not installed, explain that the corresponding build could not be validated.

## Coding rules

- Keep diffs small and reviewable.
- Avoid new production dependencies unless justified.
- Do not store secrets, API keys, tokens, customer data, or model exports in the repository.
- Do not pass `Autodesk.Revit.DB.Element`, `Document`, or `UIDocument` into domain/application/UI projects.
- Pass DTOs, `ElementId` values, `UniqueId` values, or stable identifiers instead.
- Do not start transactions outside supported Revit API workflows.
- Always name transactions with a user-visible, auditable action name.
- Never remove tests to make a build pass.

## AI/MCP rules

- Runtime LLM calls should go through the AI Gateway, not directly from the Revit add-in.
- MCP tools must be declared in docs and be deterministic.
- Read-only MCP tools may run without confirmation.
- Write MCP tools require user confirmation, audit logging, and transaction rollback behavior.
- Do not expose broad "execute arbitrary Revit API" tools.

## Repository agent skills

- `.agents/skills` is the canonical source for repository-local agent skills.
- `.agents/workflows` contains shared feature lifecycle, branch isolation, handoff, and validation workflows.
- Keep `AGENTS.md` concise; place detailed agent procedures in `.agents` instead of duplicating them here.

## Done means

- Requested behavior implemented.
- Relevant tests added or updated.
- Build/check command run or inability to run explained.
- Revit API context/threading reviewed.
- Security and data handling reviewed.
- Docs updated when architecture, public behavior, AI tools, or MCP tools change.
