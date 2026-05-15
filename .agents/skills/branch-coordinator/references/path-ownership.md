# Path Ownership

Path ownership prevents agents from editing the same area concurrently.

## Ownership Record

Use this shape in `.agents/state/<feature-id>/tasks/<task-id>.json`:

```json
{
  "featureId": "<feature-id>",
  "taskId": "<task-id>",
  "role": "<role-slug>",
  "branch": "ai/<feature-id>/<task-id>-<role-slug>",
  "worktree": ".worktrees/<feature-id>/<task-id>",
  "ownedPaths": [
    "path/or/file"
  ],
  "readOnlyPaths": [],
  "blockedPaths": [],
  "status": "planned"
}
```

## Lock Rules

- A file can have only one writer.
- A folder can have only one writer unless child paths are explicitly split.
- Shared repository files require explicit ownership.
- Generated files must be declared before creation.
- Cross-path refactors require a feature lead plan.

## High-Risk Paths

Require explicit coordination for:

- `AGENTS.md`
- `README.md`
- `Directory.Build.props`
- `Directory.Packages.props`
- `RevitAiTemplate.sln`
- `scripts/`
- `.github/workflows/`
- `.agents/`
- `src/RevitAiTemplate.Revit/`
- `.template.config/`
- `templates/`

## Diff Validation

Before handoff, compare changed files against `ownedPaths`.

Pass when:

- every changed file is inside an owned path;
- every generated file was declared;
- no blocked path was edited.

Fail when:

- any changed file is outside ownership;
- Revit API changes appear outside `src/RevitAiTemplate.Revit`;
- shared files changed without explicit ownership.
