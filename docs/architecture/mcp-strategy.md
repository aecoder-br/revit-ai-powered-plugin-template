# MCP strategy

## Local MCP

The template includes a local MCP server that exposes safe Revit tools through stdio and talks to the running Revit add-in through a named pipe.

```txt
AI client → MCP stdio → RevitAiTemplate.Mcp.Server → named pipe → Revit add-in → ExternalEvent → Revit API
```

## Tool categories

### Read-only tools

- Get active model summary.
- Count elements by category.
- Get selected element summaries.
- Read warnings summary.

### Write tools

- Set parameter values.
- Create views/schedules.
- Rename sheets.
- Apply standards.

Write tools are disabled by default. They require confirmation, audit logging, and transaction rollback strategy.

## Autodesk MCPs

Use Autodesk Product Help MCP during development to ground agents in current Autodesk documentation. For Revit 2027, evaluate Autodesk's Revit MCP tech preview, but keep your own plugin tools separately versioned and governed.

## Do not expose

- Raw arbitrary code execution.
- Arbitrary transaction execution.
- Full model export without explicit consent.
- File system write access unrelated to the task.
