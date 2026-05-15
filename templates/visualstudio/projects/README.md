# Child Project Templates

This folder is reserved for Visual Studio child project templates used by `RevitAiPlugin.ProjectGroup.vstemplate`.

Planned child templates:

- `Core/Core.vstemplate`
- `Application/Application.vstemplate`
- `Infrastructure/Infrastructure.vstemplate`
- `Ui.Wpf/Ui.Wpf.vstemplate`
- `RevitBridge/RevitBridge.vstemplate`
- `Revit/Revit.vstemplate`
- `Mcp.Server/Mcp.Server.vstemplate`
- `AiGateway/AiGateway.vstemplate`
- `Tests/Application.Tests.vstemplate`

Do not copy the full repository into each child template. Build these incrementally from the current project layout and validate each child template before enabling the ProjectGroup as an installable Visual Studio template.
