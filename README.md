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
