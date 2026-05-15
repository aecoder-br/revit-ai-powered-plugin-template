# Branch Naming

Use deterministic branch and worktree names so work can be audited and merged predictably.

## Branch Format

```txt
ai/<feature-id>/<task-id>-<role-slug>
```

Rules:

- Use lowercase kebab-case for every segment.
- Keep names short and readable.
- Use stable task ids such as `task-001`.
- Use the role slug from `.agents/roster.json`.

Examples:

```txt
ai/mcp-write-tools/task-001-requirements-analyst
ai/mcp-write-tools/task-002-ai-runtime-mcp-engineer
ai/mcp-write-tools/task-003-verifier
```

## Worktree Format

```txt
.worktrees/<feature-id>/<task-id>
```

Examples:

```txt
.worktrees/mcp-write-tools/task-001
.worktrees/mcp-write-tools/task-002
```

## State Format

```txt
.agents/state/<feature-id>/
```

Recommended files:

```txt
.agents/state/<feature-id>/tasks/<task-id>.json
.agents/state/<feature-id>/locks/paths.json
.agents/state/<feature-id>/merge-order.md
```

## Merge Order

Prefer this order:

1. Requirements and design.
2. Shared contracts and DTOs.
3. Application/domain changes.
4. Revit adapter changes.
5. UI/MCP/Gateway integration.
6. Tests and validation fixes.
7. Packaging and documentation.
8. Verification.
9. PR review.
