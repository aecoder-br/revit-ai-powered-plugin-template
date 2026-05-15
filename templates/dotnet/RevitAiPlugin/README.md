# Revit AI Plugin dotnet new Template

This folder contains the manifest for the `revit-ai-plugin` dotnet template.

The repository is not moved into this folder. Instead, `scripts/pack-dotnet-template.ps1` creates a staging template under `artifacts/templates/RevitAiPlugin` from the current repository root and copies `.template.config/template.json` into that staged content.

The v1 template records selected options in `docs/generated/template-options.md` in every generated project. This makes `AiTools`, `RevitVersions`, and include flags visible after creation while conditional removal is still being refined.

Currently included in every generated project:

- the Visual Studio solution and core multi-project architecture;
- Revit 2024-2027 build structure and validation scripts;
- canonical `.agents/skills`, workflows, and AI setup scripts;
- Revit bridge, WPF UI, MCP server, AI Gateway, and tests.

Only safe non-solution assets are conditionally excluded in v1, such as installer planning files when `IncludeInstaller` is false.

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

Current limitation: selecting `--AiTools none` does not remove every AI-related file. The generated project includes the full professional template surface, and `docs/generated/template-options.md` records the selected intent so teams can prune deliberately.

## Revit Version Choices

Use `--RevitVersions` to record the intended Revit version range:

- `2024`
- `2025`
- `2026`
- `2027`
- `2024-2027`

Current limitation: this base template defines the parameter but does not yet remove project files, solution entries, constants, or docs for unselected versions. The generated project still contains the multi-version template and should be refined by a later template-conditioning step.

The selected value is recorded in `docs/generated/template-options.md`.

## Test Matrix

Validate the template across the supported `AiTools` choices:

```powershell
./scripts/pack-dotnet-template.ps1 -TestMatrix
```

This generates samples under `artifacts/template-test` for `none`, `codex`, `claude`, `cursor`, `copilot`, and `multi`, then checks that `docs/generated/template-options.md` reflects the selected value in each sample.

## Solution Format

Use `--UseSlnFormat sln` for the current supported behavior.

`--UseSlnFormat slnx` is defined as a future-facing option for the Visual Studio multi-project template phase. This stage does not generate a `.slnx` file.

## Security

dotnet templates can include scripts and generated files that may execute after creation. Install templates only from trusted sources and review generated scripts before running them.

This template does not run setup scripts automatically. The AI tool setup command is manual by design.
