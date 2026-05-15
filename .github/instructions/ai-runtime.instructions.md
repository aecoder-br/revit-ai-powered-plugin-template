---
applyTo: "src/RevitAiTemplate.Mcp.Server/**/*.cs,src/RevitAiTemplate.AiGateway/**/*.cs,src/RevitAiTemplate.Infrastructure/Ai/**/*.cs"
---

# Runtime AI and MCP instructions

- Do not send model data to an external provider unless the gateway policy allows it.
- Keep MCP tool descriptions accurate and minimal.
- Prefer deterministic tools with explicit inputs and outputs.
- Separate read-only tools from write tools.
- Write tools require confirmation and audit logging before production.
