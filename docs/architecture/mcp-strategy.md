# MCP Strategy

## Purpose

This repository supports MCP as a development and runtime integration layer for AI-powered Revit workflows. MCP must remain narrow, deterministic, auditable, and safe for desktop automation.

The strategy covers:

- Autodesk Product Help MCP for documentation research;
- Revit Public MCP Server / Revit MCP when available;
- the custom template MCP server in `src/RevitAiTemplate.Mcp.Server`;
- security policy for MCP tools.

## Autodesk Product Help MCP

Use Autodesk Product Help MCP during development to ground agents in Autodesk documentation before designing Revit API behavior, version-specific differences, or ExternalEvent workflows.

Endpoint:

```txt
https://developer.api.autodesk.com/knowledge/public/v1/mcp
```

This MCP is a read-oriented documentation source. It must not be treated as a runtime authority for model changes.

Recommended use cases:

- research Revit API concepts and product documentation;
- compare documentation across Revit versions;
- collect citations for implementation plans and ADR drafts;
- clarify ExternalEvent, transactions, UI, and add-in deployment behavior.

## Revit Public MCP / Revit MCP

If a public Autodesk or community Revit MCP server is available, treat it as an external MCP server with unknown permissions until reviewed.

Before enabling it:

- document the server origin and version;
- inspect tool names, schemas, and permission model;
- classify each tool as read-only or write;
- disable or block broad arbitrary execution tools;
- require human confirmation for every tool that can alter the model;
- validate that model-touching requests still enter Revit through a valid API context.

Do not rely on an external Revit MCP server for production behavior without a security review in `docs/security/mcp-security-policy.md`.

## Custom Template MCP Server

The custom MCP server belongs in `src/RevitAiTemplate.Mcp.Server`. It should expose deterministic tools and communicate with the Revit add-in through the bridge layer.

Runtime flow:

```txt
AI client -> MCP stdio/http -> RevitAiTemplate.Mcp.Server -> bridge DTOs -> Revit add-in -> ExternalEvent -> Revit API
```

The external MCP server process must not reference `Autodesk.Revit.*`. Any action that touches the active Revit model must enter the add-in through the bridge and be executed by an `ExternalEvent` handler inside a valid Revit API context.

### Initial Tool Set

Start with read-only tools:

- `get_active_model_summary`
- `list_categories`
- `get_selected_elements_summary`
- `get_element_parameters_summary`
- `validate_model_rules`

These tools must return structured DTOs and sanitized summaries, not raw Revit API objects.

## Tool Classification

### Read Tools

Read tools may be used for research, inspection, documentation, and validation when they are deterministic and low risk.

Read tools must:

- validate inputs;
- return structured outputs;
- avoid full model export by default;
- sanitize outputs before they are inserted into model prompts;
- log tool name, input summary, and result summary without secrets.

### Write Tools

Do not implement new write tools in this stage.

When write tools are introduced later, they must:

- require explicit human confirmation;
- map to specific business commands, not arbitrary Revit API execution;
- use bridge DTOs and `ExternalEvent`;
- run model changes inside named Revit `Transaction` boundaries;
- define rollback or failure compensation behavior;
- log tool name, input summary, confirmation state, and result summary.

## Forbidden Tool Shapes

Do not expose:

- arbitrary Revit API execution;
- arbitrary shell command execution;
- arbitrary transaction execution;
- unrestricted file system access;
- full model exports without explicit approval;
- tools that accept raw prompt text and convert it directly into model writes.

## Related Documents

- `docs/ai/mcp-development-workflow.md`
- `docs/security/mcp-security-policy.md`
- `.agents/skills/ai-runtime-mcp-engineer/references/autodesk-mcp.md`
- `.mcp/revit-public-mcp-notes.md`
