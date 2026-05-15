# Visual Studio Template v2 Plan

## Status

The current Visual Studio template is a v1 packaging base. It validates as XML and documents the intended `ProjectGroup`, but it is not a complete or production-ready Visual Studio template.

v2 will make the native Visual Studio `ProjectGroup` template installable and useful without duplicating the full repository into every child template.

## Goals

- Create complete child project templates for the 9 repository projects.
- Preserve the current clean architecture boundaries and Revit API isolation rules.
- Preserve the Revit 2024-2027 multi-version build strategy.
- Support safe parameter substitution for product identity and namespaces.
- Support conditional inclusion of optional surfaces where Visual Studio templating can do it safely.
- Keep AI tooling setup explicit and consent-based.

## Child Project Templates

v2 child templates:

| Child template | Source project |
| --- | --- |
| `projects/Core/Core.vstemplate` | `src/RevitAiTemplate.Core/RevitAiTemplate.Core.csproj` |
| `projects/Application/Application.vstemplate` | `src/RevitAiTemplate.Application/RevitAiTemplate.Application.csproj` |
| `projects/Infrastructure/Infrastructure.vstemplate` | `src/RevitAiTemplate.Infrastructure/RevitAiTemplate.Infrastructure.csproj` |
| `projects/Ui.Wpf/Ui.Wpf.vstemplate` | `src/RevitAiTemplate.Ui.Wpf/RevitAiTemplate.Ui.Wpf.csproj` |
| `projects/RevitBridge/RevitBridge.vstemplate` | `src/RevitAiTemplate.RevitBridge/RevitAiTemplate.RevitBridge.csproj` |
| `projects/Revit/Revit.vstemplate` | `src/RevitAiTemplate.Revit/RevitAiTemplate.Revit.csproj` |
| `projects/Mcp.Server/Mcp.Server.vstemplate` | `src/RevitAiTemplate.Mcp.Server/RevitAiTemplate.Mcp.Server.csproj` |
| `projects/AiGateway/AiGateway.vstemplate` | `src/RevitAiTemplate.AiGateway/RevitAiTemplate.AiGateway.csproj` |
| `projects/Tests/Application.Tests.vstemplate` | `tests/RevitAiTemplate.Application.Tests/RevitAiTemplate.Application.Tests.csproj` |

Each child template must include:

- a `.vstemplate` file;
- the project file;
- required source files for that project only;
- template replacement flags on files that contain namespace/product placeholders;
- no copied `bin`, `obj`, user files, secrets, generated artifacts, or Revit install outputs.

## Namespace And Identity Replacement

v2 should support:

- `RootNamespace`: replaces `RevitAiTemplate` in namespaces, project names, assembly names, and `.sln` project display names.
- `CompanyName`: replaces company/package metadata and generated docs.
- `ProductName`: replaces user-facing product labels, docs, add-in metadata, and installer metadata.
- `VendorId`: replaces the four-character Revit add-in vendor id in `.addin` templates and related packaging docs.

Rules:

- Do not rename namespaces manually in this repo before validating template substitution.
- Use Visual Studio template tokens such as `$safeprojectname$`, `$rootnamespace$`, and custom parameters consistently.
- Preserve project references after project renaming.
- Validate generated project names are valid C# identifiers and safe file names.

## Conditional Inclusion

v2 should support conditional inclusion where it does not break the solution graph:

| Option | Behavior |
| --- | --- |
| `IncludeMcp` | Include or exclude `RevitAiTemplate.Mcp.Server`, `.mcp` examples, and MCP docs. |
| `IncludeAiGateway` | Include or exclude `RevitAiTemplate.AiGateway`, AI Gateway docs, and gateway config examples. |
| `IncludeWebView2` | Include or exclude WebView2-specific UI files and docs while preserving WPF shell behavior. |
| `IncludeInstaller` | Include or exclude installer folder, manifest packaging docs, and installer project/assets. |

Implementation order:

1. Start with documentation/assets that do not affect `.sln` references.
2. Add conditional child project inclusion only after ProjectGroup generation is verified.
3. Add tests for each combination before exposing the option as stable.

Do not remove projects conditionally until the generated `.sln`, project references, README links, CI docs, and setup scripts remain valid.

## Revit 2024-2027 Preservation

v2 must preserve:

- Revit 2024 using .NET Framework 4.8.
- Revit 2025 and 2026 using `net8.0-windows`.
- Revit 2027 using `net10.0-windows`.
- `REVIT2024`, `REVIT2025`, `REVIT2026`, and `REVIT2027` constants.
- per-version Revit API references and build outputs.
- no single universal Revit binary.

The Revit child template must keep all Autodesk Revit API references inside the generated Revit host project.

## AI Tooling Integration

The Visual Studio template must generate the canonical `.agents` layer and tool adapters as repository files.

After creation, users should run:

```powershell
./scripts/setup-ai-tools.ps1 -Tools <selected-tools> -Mode Copy -Validate -ValidateAdapters
```

Rules:

- Do not execute setup automatically without explicit user consent.
- Do not create secrets or provider keys.
- Claude/Cursor mirror refresh remains explicit.
- Codex/Copilot static adapter validation remains explicit.
- Generated docs should point to `docs/generated/template-options.md` or an equivalent Visual Studio creation record.

## v3 VSIX And IWizard Strategy

v3 should move advanced choices into a VSIX with an `IWizard`.

The wizard should collect:

- `ProductName`
- `RootNamespace`
- `CompanyName`
- `VendorId`
- `RevitVersions`
- `AiTools`
- `IncludeMcp`
- `IncludeAiGateway`
- `IncludeWebView2`
- `IncludeInstaller`

The wizard should:

- validate identifiers before project creation;
- write a generated options summary;
- control conditional project inclusion;
- show explicit post-create instructions for `setup-ai-tools.ps1`;
- request consent before running any setup action;
- never install dependencies, change user-wide settings, or run destructive commands silently.

## Validation Plan

v2 is complete only when:

- root ProjectGroup XML validates;
- every `ProjectTemplateLink` target exists;
- each child `.vstemplate` validates as XML;
- generated solution opens in Visual Studio;
- generated project references resolve;
- namespace and identity substitutions work;
- selected optional surfaces are documented or conditionally included safely;
- `scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters` works after generation;
- `scripts/check.ps1` runs as far as the local SDK/Revit environment allows.

## Recommended Sequence

1. Complete `Core` child template and verify generated project output.
2. Add `Application` and `Application.Tests` together to validate test project references.
3. Add `RevitBridge` to preserve DTO-only boundary.
4. Add `Infrastructure` and verify it does not reference `Autodesk.Revit.*`.
5. Add `Ui.Wpf` and verify WPF does not call Revit API directly.
6. Add `Revit` last among core add-in projects and verify version-specific build behavior.
7. Add optional `Mcp.Server` and `AiGateway` child templates.
8. Add conditional inclusion tests.
9. Package and test the full ProjectGroup zip.
10. Start v3 VSIX/IWizard after v2 is stable.
