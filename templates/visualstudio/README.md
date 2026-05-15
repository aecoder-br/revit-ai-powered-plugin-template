# Visual Studio Template

This folder contains the base for a native Visual Studio multi-project template.

## Roadmap

### v1: dotnet new First

Use the current `dotnet new` template and open the generated solution in Visual Studio:

```powershell
./scripts/pack-dotnet-template.ps1 -Force -Install -Test
dotnet new revit-ai-plugin -n SampleRevitPlugin --AiTools multi
```

Then open `RevitAiTemplate.sln` or the generated solution in Visual Studio 2022 or later.

### v2: Visual Studio ProjectGroup

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

The child project templates are intentionally not complete in this stage. They will be added incrementally so the repository is not duplicated or moved.

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

This is a packaging base. It validates the root `.vstemplate` and creates a zip, but it does not yet produce a complete installable Visual Studio ProjectGroup because child project templates are not implemented.
