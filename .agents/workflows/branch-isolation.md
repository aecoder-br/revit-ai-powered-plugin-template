# Branch Isolation

Use this workflow whenever multiple agents or workstreams may operate in parallel.

## Branch Naming

Use short, scoped branch names:

```txt
agent/<role>/<task-slug>
```

Examples:

```txt
agent/visual-studio-template-engineer/add-sln
agent/revit-api-senior/external-event-write-tool
agent/technical-writer/update-mcp-docs
```

## Worktree Rules

- Create one worktree per independent task.
- Do not share a worktree between agents.
- Do not use the main working tree for parallel implementation.
- Keep worktrees outside generated template output folders.
- Delete or archive completed worktrees only after the branch is merged or intentionally abandoned.

## Path Ownership

Each task must declare owned paths before editing.

Use the narrowest practical ownership path:

```txt
src/RevitAiTemplate.Revit/ExternalEvents/
.agents/skills/<skill-name>/
scripts/ai/
templates/visual-studio/
```

Avoid broad ownership such as `src/` unless the task is an intentional cross-cutting refactor.

## Conflict Rules

- Two agents must not edit the same file concurrently.
- Two agents must not edit overlapping folders unless a feature lead explicitly coordinates ordering.
- Shared files such as `AGENTS.md`, `README.md`, `Directory.Build.props`, `Directory.Packages.props`, and solution/template files require explicit ownership.
- If ownership changes, create a handoff before the next agent edits.

## Revit-Specific Isolation

- Revit API work belongs in `src/RevitAiTemplate.Revit`.
- Non-Revit projects must not receive `Autodesk.Revit.*` references.
- Revit 2024, 2025, 2026, and 2027 compatibility must be reviewed when changing build props or adapter code.
- Version-specific code must use the existing constants: `REVIT2024`, `REVIT2025`, `REVIT2026`, `REVIT2027`.

## Merge Order

Merge in this order when possible:

1. Documentation and planning.
2. Shared contracts and DTOs.
3. Application/domain changes.
4. Revit adapter changes.
5. UI/MCP/Gateway integration.
6. Tests and validation fixes.
7. Packaging, installer, and template updates.

The feature lead may change the order, but must document why.
