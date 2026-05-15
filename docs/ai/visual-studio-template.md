# Visual Studio Template

## Goal

Provide a native Visual Studio multi-project template path for the Revit AI-powered add-in template while keeping the current repository stable.

## Phase v1: dotnet new + Solution

Use the `dotnet new` template as the current creation path:

```powershell
./scripts/pack-dotnet-template.ps1 -Force -Install -Test
dotnet new revit-ai-plugin -n SampleRevitPlugin --AiTools multi
```

Then open the generated `.sln` in Visual Studio 2022 or later.

This phase is supported now and avoids duplicating the repository into Visual Studio child templates.

## Phase v2: Visual Studio ProjectGroup

Use `templates/visualstudio/RevitAiPlugin.ProjectGroup.vstemplate` as the root ProjectGroup template.

The root template contains planned `ProjectTemplateLink` entries for:

- Core
- Application
- Infrastructure
- Ui.Wpf
- RevitBridge
- Revit
- Mcp.Server
- AiGateway
- Tests

Child project templates will be added under `templates/visualstudio/projects` in a later step.

Package the current base with:

```powershell
./scripts/pack-vs-template.ps1 -Force
```

Output:

```txt
artifacts/templates/visualstudio/
artifacts/templates/visualstudio/RevitAiPlugin.VisualStudioTemplate.zip
```

Current limitation: the generated zip validates and stages the ProjectGroup base, but it is not a complete installable Visual Studio template until child project templates are implemented.

## Phase v3: VSIX + IWizard

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

After creation, the wizard should either explicitly ask before running setup or show this manual instruction:

```powershell
./scripts/setup-ai-tools.ps1 -Tools <selected-tools> -Mode Copy -Validate
```

The wizard must not run sensitive actions, install external dependencies, mutate user settings, or execute destructive commands without explicit consent.

## Validation

For the current base:

```powershell
./scripts/pack-vs-template.ps1 -Force
./scripts/check.ps1
```

If `.NET 10` SDK or local Revit installations are missing, document the exact validation gap.
