# Repository Agent Layer

`.agents/skills` is the canonical source for repository-specific agent skills.

Use this layer to define reusable AI-agent behavior for this Revit add-in template without duplicating long instructions across Codex, Claude Code, Cursor, GitHub Copilot, or MCP clients.

## Canonical Sources

- `AGENTS.md`: repository-wide safety and architecture contract.
- `.agents/skills`: canonical skill definitions and reusable references.
- `.agents/workflows`: shared multi-agent operating workflows.
- `.agents/roster.json`: planned agent roles and their intended ownership areas.
- `.agents/state`: local or reviewable task state for agent coordination.

## Rules

- Keep skill names in lowercase kebab-case.
- Keep each skill description short and specific.
- Keep detailed process content in `.agents/workflows` or skill `references`.
- Keep `AGENTS.md` short; reference this layer instead of duplicating it.
- Do not place secrets, customer data, model exports, API keys, or local credentials in `.agents`.
- Treat Revit API work as high-risk. Agents must respect the `src/RevitAiTemplate.Revit` boundary and the `ExternalEvent` rule.

## Skill Structure

New skills should start from:

```txt
.agents/skills/_template/
```

A production skill should normally contain:

```txt
.agents/skills/<skill-name>/
  SKILL.md
  references/
  assets/
```

Only add scripts inside a skill when deterministic execution is safer than repeatedly asking an agent to rewrite the same logic.
