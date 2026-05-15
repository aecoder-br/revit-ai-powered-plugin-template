# Visual Studio Template

This folder contains the v1 base for a native Visual Studio multi-project template.

It is not a complete or production-ready Visual Studio template yet. The root `ProjectGroup` file is present and XML-valid, but most child project templates are still planned work.

See `../../docs/ai/visual-studio-template-v2-plan.md` for the v2 implementation plan.

## Roadmap

### v1: dotnet new First

Use the current `dotnet new` template and open the generated solution in Visual Studio:

```powershell
./scripts/pack-dotnet-template.ps1 -Force -Install -Test
dotnet new revit-ai-plugin -n SampleRevitPlugin --AiTools multi
```

Then open `RevitAiTemplate.sln` or the generated solution in Visual Studio 2022 or later.

### v2: Complete Visual Studio ProjectGroup

Package `RevitAiPlugin.ProjectGroup.vstemplate` with child project templates under `templates/visualstudio/projects`.

The root `.vstemplate` is already defined as a `ProjectGroup` and includes planned `ProjectTemplateLink` entries for:

- Core
- Application
- Infrastructure
- Ui.Wpf
- RevitBridge
- Revit
- Mcp.Server
- AiGateway
- Tests

The child project templates are intentionally not complete in v1. `projects/Core` contains only a small reference skeleton for the v2 implementation pattern. The remaining children will be added incrementally so the repository is not duplicated or moved.

Do not present v1 output as an installable production Visual Studio template.

### v3: VSIX Wizard

Create a VSIX with an `IWizard` implementation for the Visual Studio Create Project dialog.

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

After project creation, the wizard may show instructions for:

```powershell
./scripts/setup-ai-tools.ps1 -Tools <selected-tools> -Mode Copy -Validate
```

The wizard must not execute sensitive setup actions without explicit user consent.

## Pack

From the repository root:

```powershell
./scripts/pack-vs-template.ps1 -Force
```

Output:

```txt
artifacts/templates/visualstudio/
artifacts/templates/visualstudio/RevitAiPlugin.VisualStudioTemplate.zip
```

## Current Limitation

This is a packaging base. It validates the root `.vstemplate` and creates a zip, but it does not yet produce a complete installable Visual Studio ProjectGroup because child project templates are not complete.

The concrete v2/v3 roadmap is documented in `../../docs/ai/visual-studio-template-v2-plan.md`.
