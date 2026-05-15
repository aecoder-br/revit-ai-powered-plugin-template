# MCP Development Workflow

## Goal

Use MCP to improve Revit AI development while keeping model access safe, explicit, and auditable.

## Default Workflow

1. Use `AGENTS.md` to confirm repository constraints.
2. Use `.agents/skills/ai-runtime-mcp-engineer/SKILL.md` for MCP design work.
3. Use Autodesk Product Help MCP for documentation research when available.
4. Classify proposed tools as read-only or write.
5. Start with read-only tools in the custom MCP server.
6. Route any model-touching action through bridge DTOs and `ExternalEvent`.
7. Validate inputs and sanitize outputs before they enter model prompts.
8. Run repository validation.

Autodesk Product Help MCP endpoint:

```txt
https://developer.api.autodesk.com/knowledge/public/v1/mcp
```

## Research Flow

Use documentation MCPs for:

- Revit API behavior research;
- version-specific API checks;
- ExternalEvent and transaction guidance;
- add-in deployment and manifest research;
- ADR and implementation plan evidence.

Record documentation uncertainty when an MCP server is unavailable or when documentation does not cover the exact Revit version.

## Custom MCP Tool Design

Each custom tool needs:

- deterministic name;
- explicit input schema;
- structured output schema;
- safety classification;
- confirmation policy;
- audit policy;
- bridge DTO contract;
- validation plan.

Initial read-only tools:

| Tool | Purpose | Model access |
| --- | --- | --- |
| `get_active_model_summary` | Return active model metadata and coarse counts. | ExternalEvent read request |
| `list_categories` | Return available categories relevant to the model. | ExternalEvent read request |
| `get_selected_elements_summary` | Return sanitized selection summaries. | ExternalEvent read request |
| `get_element_parameters_summary` | Return selected/approved parameter summaries. | ExternalEvent read request |
| `validate_model_rules` | Evaluate deterministic model rules and return findings. | ExternalEvent read request |

## Write Tool Gate

Do not implement write tools in this stage.

Future write tools require:

- feature-level requirements;
- threat model;
- human confirmation UX;
- named Revit `Transaction`;
- rollback or compensation design;
- audit log design;
- tests and manual Revit smoke validation.

## Validation Commands

Run when possible:

```powershell
./scripts/validate-skills.ps1 -IncludeMirrors
./scripts/check.ps1
```

If Revit or a required SDK is unavailable, document the exact blocker and the validation that could not run.
