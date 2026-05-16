# Revit AI-Powered Plugin Template

Professional template for multi-version Revit plugins, with clean architecture, WPF, local MCP bridge, AI gateway, and agent-ready documentation.

## Objective

This template was designed to be a safe starting point for professional Revit 2024, 2025, 2026, and 2027 add-ins.

It separates:

- domain and use cases without Revit API dependencies;
- versioned Revit API layer;
- decoupled WPF/WebView2 UI;
- local bridge for MCP;
- AI gateway outside the Revit process;
- documentation and instructions for AI agents.

## Multi-version strategy

| Revit | Recommended runtime | Add-in build |
|---|---:|---|
| 2024 | .NET Framework 4.8 | `-p:RevitVersion=2024` |
| 2025 | .NET 8 Windows | `-p:RevitVersion=2025` |
| 2026 | .NET 8 Windows | `-p:RevitVersion=2026` |
| 2027 | .NET 10 Windows | `-p:RevitVersion=2027` |

Do not use a single binary for all versions. Generate one binary per version and keep domain, application services, DTOs, and contracts shared.

## Requirements

- Windows 10/11.
- Visual Studio 2022 or later, with the .NET desktop workload.
- Revit installed for each version you want to build/test.
- .NET SDK 8 for Revit 2025/2026.
- .NET SDK 10 for Revit 2027, MCP server, and AI Gateway.
- .NET Framework 4.8 Developer Pack for Revit 2024.

## Opening in Visual Studio

Open `RevitAiTemplate.sln` from the repository root in Visual Studio 2022 or later.

The solution groups projects into:

- `src`: shared domain/application/infrastructure/UI/bridge projects and the Revit add-in host.
- `tools`: the local MCP server and AI Gateway.
- `tests`: application test projects.

Use the solution for navigation, editing, tests, and shared project builds. For Revit add-in binaries, prefer the version-aware PowerShell scripts so the correct Revit API references, target framework, constants, and output folder are selected:

```powershell
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027
```

If a Revit version is not installed, the build script skips that version and reports the missing install folder.

## AI-powered development workflow

Use `AGENTS.md` as the repository-wide safety contract. Use `.agents/skills` as the canonical skill layer and `.agents/workflows` for feature lifecycle, branch isolation, handoffs, and validation.

Recommended flow:

1. Plan the feature with `.agents/workflows/feature-lifecycle.md`.
2. Assign skills from `.agents/roster.json`.
3. Isolate parallel work with `.agents/workflows/branch-isolation.md`.
4. Validate with `./scripts/validate-skills.ps1 -IncludeMirrors` and `./scripts/check.ps1`.

See `docs/ai/index.md` for the full AI tooling guide.

For Public Beta validation evidence, use `docs/validation/public-beta/README.md`.

## Choosing AI tools

Choose the smallest tool set that your team will actually use:

| Choice | Use when |
| --- | --- |
| `none` | You only want the Revit template and docs. |
| `codex` | You use Codex with repo-local `.agents/skills` and `.codex/config.toml`. |
| `claude` | You use Claude Code subagents and `.claude/skills` mirrors. |
| `cursor` | You use Cursor agents, rules, and `.cursor/skills` mirrors. |
| `copilot` | You use GitHub Copilot prompts under `.github/prompts`. |
| `multi` | You want all supported adapters available. |

Run the full AI tooling setup with:

```powershell
./scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters
```

`All` covers Codex, Claude Code, Cursor, and GitHub Copilot. Claude/Cursor refresh skill mirrors; Codex/Copilot validate static adapters and create missing files only.

## Using Codex

Codex should read `AGENTS.md`, `.agents/skills`, `.agents/workflows`, and `.codex/config.toml`.

Use repository skills for planning, Revit API review, MCP design, QA, and PR review. Keep permissions restricted and require confirmation before destructive commands, worktree deletion, model writes, or external setup.

For a documentation-only example of the agent workflow, see `docs/features/example-analyze-active-model/`. It demonstrates a safe read-only feature plan, path ownership, and handoffs without creating branches or worktrees.

## Using Claude Code

Claude Code should use `CLAUDE.md`, `AGENTS.md`, `.claude/agents`, and `.claude/skills`.

Regenerate Claude skill mirrors from the canonical `.agents/skills` layer:

```powershell
./scripts/setup-ai-tools.ps1 -Tools Claude -Mode Copy -Validate
```

Use worktrees and path ownership before running parallel agents.

## Using Cursor

Cursor should use `.cursor/rules`, `.cursor/agents`, and `.cursor/skills`.

Regenerate Cursor skill mirrors from the canonical `.agents/skills` layer:

```powershell
./scripts/setup-ai-tools.ps1 -Tools Cursor -Mode Copy -Validate
```

Use `.cursor/rules/agent-team.mdc` for agent routing and `.agents/workflows` for coordination.

## Using GitHub Copilot

GitHub Copilot should use `.github/copilot-instructions.md` and prompt files in `.github/prompts`.

Available prompts include feature planning, Revit API review, security review, QA validation, and PR summary. Prompts point back to `AGENTS.md` and `.agents/workflows` instead of duplicating long rules.

## Creating a new plugin from the template

Use the `dotnet new` template first:

```powershell
./scripts/pack-dotnet-template.ps1 -Force -Install
dotnet new revit-ai-plugin -n MyRevitPlugin --AiTools multi
```

The v1 dotnet template records selected options in `docs/generated/template-options.md` inside the generated project. `AiTools`, `RevitVersions`, and include flags are currently declarative setup choices; they do not yet remove every unused project, solution entry, adapter, or documentation file.

Currently included in every generated project:

- the Visual Studio solution and core multi-project architecture;
- Revit 2024-2027 build structure and validation scripts;
- canonical `.agents/skills`, workflows, and AI setup scripts;
- Revit bridge, WPF UI, MCP server, AI Gateway, and tests.

Only safe non-solution assets are conditionally excluded in v1, such as installer planning files when `IncludeInstaller` is false.

Then open the generated `.sln` in Visual Studio and run the relevant setup:

```powershell
./scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters
```

The native Visual Studio template base is documented in `docs/ai/visual-studio-template.md` and staged from `templates/visualstudio`.

Roadmap:

- v1: use `dotnet new` and open the generated `.sln`.
- v2: package a complete Visual Studio `ProjectGroup` template.
- v3: ship a VSIX with an `IWizard` for product name, namespace, Revit versions, AI tools, MCP, AI Gateway, WebView2, and installer choices.

## Build

```powershell
# Build a specific version
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027

# Build all installed versions
./scripts/build.ps1 -RevitVersion all
```

## Development-mode installation

```powershell
./scripts/dev-install.ps1 -RevitVersion 2026
```

This script builds the selected version and writes a `.addin` file to:

```txt
%APPDATA%\Autodesk\Revit\Addins\<year>
```

## Opening the plugin

1. Install in development mode.
2. Open the corresponding Revit version.
3. Look for the `AI Template` tab.
4. Click `Assistant`.

## Local MCP

This template includes an external MCP server at:

```txt
src/RevitAiTemplate.Mcp.Server
```

Flow:

```txt
Claude/Cursor/Copilot Agent
        -> MCP stdio
RevitAiTemplate.Mcp.Server
        -> local named pipe
RevitAiTemplate.Revit add-in
        -> ExternalEvent
Valid Revit API on the Revit thread/context
```

The MCP server should only execute tools that you have declared and tested. Start with read-only tools.

## Runtime AI

The add-in does not call OpenAI/Anthropic/Azure directly by default. It calls a local/remote AI Gateway:

```txt
src/RevitAiTemplate.AiGateway
```

Reasons:

- avoids API keys inside Revit;
- reduces dependency conflicts in the Revit process;
- enables rate limiting, auditing, policy, and fallback;
- makes it easier to switch AI providers.

Configure:

```powershell
$env:REVIT_AI_GATEWAY_URL = "http://localhost:5088"
```

Run:

```powershell
dotnet run --project src/RevitAiTemplate.AiGateway/RevitAiTemplate.AiGateway.csproj
```

## Structure

```txt
src/
  RevitAiTemplate.Core/              Domain, DTOs, and ports
  RevitAiTemplate.Application/       Use cases
  RevitAiTemplate.Infrastructure/    AI Gateway client, logging, configuration
  RevitAiTemplate.Ui.Wpf/            WPF/MVVM UI without Revit API
  RevitAiTemplate.Revit/             Host Revit, ExternalApplication, ExternalCommand, adapters
  RevitAiTemplate.RevitBridge/       Local bridge contracts between MCP and Revit
  RevitAiTemplate.Mcp.Server/        Local MCP server via stdio
  RevitAiTemplate.AiGateway/         Optional AI Gateway

tests/
  RevitAiTemplate.Application.Tests/

docs/
  architecture/
  adr/
  ai/
  domain/
  security/
  testing/
```

## Next steps to turn it into a product

1. Replace names, GUIDs, VendorId, and namespaces.
2. Define read-only and write MCP tools separately.
3. Add tests with real fixtures.
4. Create an installer per version.
5. Sign binaries.
6. Enable CI, secret scanning, dependency scanning, and branch protection.
7. Publish support documentation, version documentation, changelog, and data/AI policy.
