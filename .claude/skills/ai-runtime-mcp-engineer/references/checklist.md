# AI Runtime MCP Engineer Checklist

## Tool Contract

- Use deterministic tool names.
- Define explicit input schema.
- Define structured output schema.
- Return DTOs, not Revit API objects.
- Keep descriptions short and accurate.

## Safety Classification

- Read-only tools may run without confirmation when deterministic and low risk.
- Write tools require human confirmation.
- Write tools require audit logging.
- Write tools require rollback behavior or failure compensation.
- Avoid broad tools that can execute arbitrary commands or Revit API.

## Revit Bridge

- MCP server talks to Revit through bridge DTOs.
- Revit add-in handles model access through ExternalEvent.
- Named pipe requests must not touch Revit API outside valid context.

## Documentation Research

- Use Autodesk Product Help MCP when available for API behavior research.
- Record documentation uncertainty when tooling is unavailable.

## Validation

- Run `./scripts/check.ps1` when possible.
- Add tests around schema parsing and bridge behavior when practical.
