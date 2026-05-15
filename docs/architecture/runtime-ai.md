# Runtime AI strategy

## Separation

There are two different AI concerns:

1. **AI-powered codebase**: AGENTS.md, Copilot instructions, Claude/Cursor rules, MCP docs, tests and architecture docs.
2. **AI-powered plugin runtime**: assistant UI, MCP tools, AI Gateway, model query/report tools.

Do not mix these concerns.

## Provider strategy

The Revit add-in should not embed provider SDKs or API keys by default. Use an AI Gateway:

```txt
Revit add-in → AI Gateway → OpenAI / Azure OpenAI / Anthropic / local model / enterprise proxy
```

The gateway is where you implement:

- authentication;
- redaction;
- policy;
- tenant/user permissions;
- prompt templates;
- model/provider routing;
- audit logs;
- cost limits;
- evals.

## Data minimization

Send summaries, not full model dumps. Start with counts, categories, selected parameters and user-approved snippets.

## Production guardrails

- Never send secrets or credentials.
- Avoid sending personally identifiable information.
- Make data sharing visible to the user.
- Log tool calls and policy decisions, not full sensitive payloads.
- Keep prompts and tool schemas versioned.
