# Revit AI Plugin dotnet new Template

This folder contains the manifest for the `revit-ai-plugin` dotnet template.

The repository is not moved into this folder. Instead, `scripts/pack-dotnet-template.ps1` creates a staging template under `artifacts/templates/RevitAiPlugin` from the current repository root and copies `.template.config/template.json` into that staged content.

## Pack

From the repository root:

```powershell
./scripts/pack-dotnet-template.ps1 -Force
```

The staged template is created at:

```txt
artifacts/templates/RevitAiPlugin
```

## Install Locally

```powershell
dotnet new install ./artifacts/templates/RevitAiPlugin
```

## Create A Project

```powershell
dotnet new revit-ai-plugin `
  -n SampleRevitPlugin `
  --CompanyName "Contoso" `
  --ProductName "Contoso Revit Assistant" `
  --RootNamespace "Contoso.RevitAssistant" `
  --VendorId "CNTO" `
  --RevitVersions 2024-2027 `
  --AiTools multi
```

## AI Tool Choices

Use `--AiTools` to document the intended AI adapter set:

| Value | Intended setup |
| --- | --- |
| `none` | No AI tool adapter refresh. |
| `codex` | Codex configuration. |
| `claude` | Claude Code configuration. |
| `cursor` | Cursor configuration. |
| `copilot` | GitHub Copilot prompts and instructions. |
| `multi` | All supported AI adapters. |

After generation, run:

```powershell
./scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters
```

For a single tool, map the template choice to the setup script:

```powershell
./scripts/setup-ai-tools.ps1 -Tools Codex -ValidateAdapters
./scripts/setup-ai-tools.ps1 -Tools Claude -Mode Copy -Validate
./scripts/setup-ai-tools.ps1 -Tools Cursor -Mode Copy -Validate
./scripts/setup-ai-tools.ps1 -Tools Copilot -ValidateAdapters
```

Claude and Cursor refresh skill mirrors. Codex and Copilot validate static adapters and create missing files only.

## Revit Version Choices

Use `--RevitVersions` to record the intended Revit version range:

- `2024`
- `2025`
- `2026`
- `2027`
- `2024-2027`

Current limitation: this base template defines the parameter but does not yet remove project files, solution entries, constants, or docs for unselected versions. The generated project still contains the multi-version template and should be refined by a later template-conditioning step.

## Solution Format

Use `--UseSlnFormat sln` for the current supported behavior.

`--UseSlnFormat slnx` is defined as a future-facing option for the Visual Studio multi-project template phase. This stage does not generate a `.slnx` file.

## Security

dotnet templates can include scripts and generated files that may execute after creation. Install templates only from trusted sources and review generated scripts before running them.

This template does not run setup scripts automatically. The AI tool setup command is manual by design.
