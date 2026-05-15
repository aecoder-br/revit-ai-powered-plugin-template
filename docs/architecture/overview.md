# Architecture overview

## Layers

```txt
User / AI Assistant / MCP Client
        ↓
WPF or MCP Server
        ↓
Application use cases
        ↓
Ports / DTOs
        ↓
Revit adapter layer
        ↓
Autodesk Revit API
```

## Design goals

- Versioned Revit builds without duplicating domain logic.
- No Revit API leakage into pure projects.
- Safe modeless UI via ExternalEvent.
- Runtime AI through gateway/bridge instead of provider SDKs inside Revit.
- MCP-compatible development and automation workflow.

## Project responsibilities

| Project | Responsibility |
|---|---|
| `Core` | Domain concepts, DTOs, ports |
| `Application` | Use cases and orchestration |
| `Infrastructure` | AI Gateway client, logging, configuration |
| `Ui.Wpf` | Desktop UI and MVVM |
| `Revit` | Revit API boundary, ribbon, commands, ExternalEvent queue |
| `RevitBridge` | Local bridge DTOs between Revit and MCP |
| `Mcp.Server` | Exposes safe tools to AI clients |
| `AiGateway` | Provider abstraction, redaction, policy and audit placeholder |
