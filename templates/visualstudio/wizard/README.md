# Visual Studio Wizard

This folder is reserved for a future VSIX and `IWizard` implementation.

## Parameters

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

## Safety

The wizard must not execute sensitive actions without explicit user consent.

After creation, it may either ask for consent to run setup or show this manual instruction:

```powershell
./scripts/setup-ai-tools.ps1 -Tools <selected-tools> -Mode Copy -Validate
```

It must not:

- install external dependencies silently;
- modify user-wide settings silently;
- run destructive commands;
- store secrets in generated files;
- bypass Revit API, MCP, or AI security policies.

## Future Work

The wizard should map selected parameters to template replacements and conditional project inclusion after the child project templates are complete.
