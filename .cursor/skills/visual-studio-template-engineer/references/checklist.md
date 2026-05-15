# Visual Studio Template Checklist

## Template Scope

- Identify projects included in the solution and template package.
- Confirm supported Revit versions and target frameworks.
- Decide whether generated output should include MCP, AI Gateway, WebView2, installer, and AI tool mirrors.

## Parameters

- Define `company`, `productName`, `rootNamespace`, `revitVersions`, `aiTools`, `includeMcp`, `includeAiGateway`, `includeWebView2`, and `includeInstaller`.
- Define defaults and allowed values.
- Define replacement scope per parameter.
- Avoid replacing strings in binary outputs, generated caches, or unrelated docs.

## dotnet new Template

- Plan `.template.config/template.json`.
- Plan symbol definitions, source modifiers, primary outputs, and post actions.
- Validate generation in a temporary directory.

## Visual Studio Multi-Project Template

- Plan `.vstemplate` structure and project grouping.
- Keep solution folders and project references consistent.
- Validate opening and building in Visual Studio.

## AI Tool Setup

- Run repository setup scripts after generation when requested.
- Keep `.agents/skills` canonical and mirror `.claude/skills` and `.cursor/skills` through setup scripts.

## Validation

- Run `./scripts/check.ps1`.
- Run version-specific builds when Revit references and SDKs are available.
