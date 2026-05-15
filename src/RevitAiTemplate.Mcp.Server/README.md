# RevitAiTemplate MCP Server

Local stdio MCP server that exposes safe Revit add-in tools through a named pipe bridge.

Requires:

- Revit running with the RevitAiTemplate add-in loaded.
- The named pipe bridge started by the add-in.

Start:

```powershell
dotnet run --project src/RevitAiTemplate.Mcp.Server/RevitAiTemplate.Mcp.Server.csproj
```
