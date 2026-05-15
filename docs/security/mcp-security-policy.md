# MCP Security Policy

## Default Stance

MCP tools run near sensitive repository, model, and user data. Treat every MCP server as untrusted until reviewed.

Read tools are allowed for research and documentation when deterministic and low risk. Write tools require explicit human confirmation and must never execute arbitrary Revit API, arbitrary shell commands, or broad file system actions.

## Required Controls

Every MCP tool must define:

- tool name;
- purpose;
- input schema;
- output schema;
- read/write classification;
- confirmation requirement;
- audit logging behavior;
- data handling notes;
- validation strategy.

## Input Validation

Validate all inputs before tool execution.

Reject:

- unknown tool names;
- missing required fields;
- unsupported enum values;
- path traversal;
- raw commands;
- raw Revit API instructions;
- unbounded selectors that could export the full model.

## Output Sanitization

Sanitize outputs before they enter model prompts.

Remove or reduce:

- secrets;
- tokens;
- usernames;
- full file paths;
- customer names;
- project addresses;
- sensitive parameter values;
- full model dumps.

Prefer summaries, counts, IDs, and explicit user-approved snippets.

## Logging Policy

Logs must include:

- tool name;
- input summary;
- user confirmation state;
- result summary;
- correlation identifier when available;
- failure category when applicable.

Logs must never include:

- API keys;
- tokens;
- passwords;
- provider secrets;
- full prompts with sensitive model data;
- raw model exports.

## Revit Model Write Policy

Tools that alter the Revit model must:

- map to a specific command;
- require human confirmation;
- enter the add-in through bridge DTOs;
- execute through `ExternalEvent`;
- run inside a named Revit `Transaction`;
- define rollback or compensation behavior;
- produce an audit record.

No tool may execute arbitrary Revit API.

## External MCP Servers

Before enabling external MCP servers:

- identify provider, endpoint, and transport;
- review available tools and scopes;
- disable write tools by default when possible;
- document any server-specific risk;
- keep credentials outside the repository.

Autodesk Product Help MCP is approved only as a documentation research source unless a future review expands its scope:

```txt
https://developer.api.autodesk.com/knowledge/public/v1/mcp
```

## Custom Template MCP Server

The custom MCP server must not reference `Autodesk.Revit.*`.

Any model access must cross the bridge into the Revit add-in and use `ExternalEvent`. Start with read-only tools:

- `get_active_model_summary`
- `list_categories`
- `get_selected_elements_summary`
- `get_element_parameters_summary`
- `validate_model_rules`
