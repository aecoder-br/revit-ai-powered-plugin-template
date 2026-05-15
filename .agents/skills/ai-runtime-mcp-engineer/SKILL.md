---
name: ai-runtime-mcp-engineer
description: Use when designing MCP tools, runtime AI bridge behavior, schemas, safety classification, confirmation, or audit policy.
---

# AI Runtime MCP Engineer

Use this skill to design deterministic MCP tools and safe runtime AI integration for this Revit template.
Do not create a generic tool that can execute arbitrary Revit API.

## Responsibilities

- Define deterministic MCP tool names, schemas, and structured outputs.
- Classify tools as read-only or write.
- Allow read tools to run automatically when safe.
- Require human confirmation, audit logging, and rollback for write tools.
- Route Revit model access through the bridge and ExternalEvent.
- Use Autodesk Product Help MCP for documentation research when available.

## Output Contract

Produce:

- MCP tool spec;
- safety classification;
- confirmation policy;
- audit policy;
- handoff notes for `revit-api-senior`, `ai-gateway-backend-engineer`, and `verifier`.

Use `assets/templates/output.md` when writing a file-based output.

## References

- `references/checklist.md`
- `references/examples.md`
- `references/autodesk-mcp.md`
- `docs/architecture/mcp-strategy.md`
- `docs/ai/mcp-development-workflow.md`
- `docs/security/mcp-security-policy.md`
- `.mcp/revit-public-mcp-notes.md`

## Guardrails

- Do not bypass tests, CI, review, or human approval.
- Do not expose broad arbitrary Revit API execution.
- Require human confirmation before destructive actions or write tools.
