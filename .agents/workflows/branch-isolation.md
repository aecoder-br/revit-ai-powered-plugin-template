# Branch Isolation

Use this workflow whenever multiple agents or workstreams may operate in parallel.

## Branch Naming

Use short, scoped branch names:

```txt
ai/<feature-id>/<task-id>-<role-slug>
```

Examples:

```txt
ai/visual-studio-template/task-001-visual-studio-template-engineer
ai/mcp-read-tools/task-002-ai-runtime-mcp-engineer
ai/docs-refresh/task-003-technical-writer
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

The task's `allowedPaths` are the only paths an agent may write. `readOnlyPaths` are context paths only and must not be locked or edited.

Path locks must be acquired only inside `allowedPaths`. A lock request for a parent folder that would include paths outside `allowedPaths` must be rejected.

## Conflict Rules

- Two agents must not edit the same file concurrently.
- Two agents must not edit overlapping folders unless a feature lead explicitly coordinates ordering.
- Shared files such as `AGENTS.md`, `README.md`, `Directory.Build.props`, `Directory.Packages.props`, and solution/template files require explicit ownership.
- If ownership changes, create a handoff before the next agent edits.

## Diff Validation

Validate each task branch or worktree against path ownership before handoff.

For branch validation, provide a base ref:

```powershell
./scripts/agent-locks.ps1 `
  -Command validate-diff `
  -FeatureId <feature-id> `
  -TaskId <task-id> `
  -BaseRef main
```

`validate-diff` checks:

- committed branch changes: `git diff --name-only <BaseRef>...HEAD`;
- staged changes: `git diff --cached --name-only`;
- unstaged tracked changes: `git diff --name-only`;
- untracked files: `git ls-files --others --exclude-standard`.

The command fails when any changed file is outside `allowedPaths` or inside `readOnlyPaths`.

Use working-tree-only mode only before commits, when intentionally validating local staged/unstaged/untracked changes without branch history:

```powershell
./scripts/agent-locks.ps1 `
  -Command validate-diff `
  -FeatureId <feature-id> `
  -TaskId <task-id> `
  -WorkingTreeOnly
```

Do not use `-WorkingTreeOnly` as the final branch validation gate.

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
