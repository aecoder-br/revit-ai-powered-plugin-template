# Generated Template Options

This file is generated from the dotnet template parameters selected at project creation time.

## Product

| Option | Selected value |
| --- | --- |
| CompanyName | TemplateCompany |
| ProductName | Revit AI-Powered Plugin Template |
| RootNamespace | RevitAiTemplate |
| VendorId | RATP |

## Template Choices

| Option | Selected value |
| --- | --- |
| RevitVersions | __RevitVersions__ |
| AiTools | __AiTools__ |
| IncludeMcpServer | __IncludeMcpServer__ |
| IncludeAutodeskProductHelpMcp | __IncludeAutodeskProductHelpMcp__ |
| IncludeAiGateway | __IncludeAiGateway__ |
| IncludeWebView2 | __IncludeWebView2__ |
| IncludeInstaller | __IncludeInstaller__ |

## Current v1 Behavior

These options are recorded for transparency and follow-up setup. This v1 dotnet template does not yet remove every file, solution entry, or project reference based on the selected values.

The generated repository still starts from the professional multi-version template surface. Use this file as the creation record when deciding which projects, adapters, docs, and deployment assets to keep or remove in a later hardening step.

## Recommended Follow-Up

- Run `./scripts/setup-ai-tools.ps1` with the tool set that matches `AiTools`.
- Validate selected Revit versions with `./scripts/build.ps1 -RevitVersion <year>`.
- Remove unused optional surfaces only after checking the solution, project references, docs links, and CI.
