# Domain invariants

- Core/Application/UI projects must remain Revit-API-free.
- Runtime AI must not receive full model data by default.
- Write operations must be transactional.
- MCP tools must be declared and documented.
- Read-only tools must not modify the model.
- Write tools must require user confirmation before production use.
- Version-specific Revit API code must stay in adapter code.
