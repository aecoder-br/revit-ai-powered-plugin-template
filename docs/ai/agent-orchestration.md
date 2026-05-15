# Agent Orchestration

This repository uses PowerShell scripts and JSON state to coordinate feature planning, task ownership, locks, and git worktrees for AI-agent work.

The scripts are intentionally local-first and do not perform automatic merges.

## Files and State

Feature state lives under:

```txt
.agents/state/<feature-id>/
  feature.json
  tasks.json
  locks.json
```

Feature documentation lives under:

```txt
docs/features/<feature-id>/
  brief.md
  requirements.md
  handoffs/
```

Worktrees live under:

```txt
.worktrees/<feature-id>/<task-id>
```

`.worktrees/` is ignored by git because worktrees are local execution environments, not source files.

## Create a Feature

```powershell
./scripts/agent-feature.ps1 `
  -Command new `
  -FeatureId mcp-read-tools `
  -Title "MCP read tools" `
  -Owner maycon `
  -TargetRevitVersions 2024,2025,2026,2027 `
  -AiTools Codex,Claude,Cursor
```

This creates:

- `.agents/state/mcp-read-tools/feature.json`
- `.agents/state/mcp-read-tools/tasks.json`
- `.agents/state/mcp-read-tools/locks.json`
- `docs/features/mcp-read-tools/brief.md`
- `docs/features/mcp-read-tools/requirements.md`
- `docs/features/mcp-read-tools/handoffs/`

## Add a Task

```powershell
./scripts/agent-feature.ps1 `
  -Command add-task `
  -FeatureId mcp-read-tools `
  -TaskId task-001 `
  -Title "Define read tool requirements" `
  -AssignedRole requirements-analyst `
  -AllowedPaths docs/features/mcp-read-tools `
  -ValidationCommands "./scripts/validate-skills.ps1","./scripts/check.ps1"
```

The task record includes:

- `id`
- `title`
- `assignedRole`
- `branch`
- `worktreePath`
- `status`
- `allowedPaths`
- `readOnlyPaths`
- `validationCommands`
- `handoffPath`
- optional `baseRef` for branch diff validation

## Acquire Locks

```powershell
./scripts/agent-locks.ps1 `
  -Command acquire `
  -FeatureId mcp-read-tools `
  -TaskId task-001 `
  -Paths docs/features/mcp-read-tools
```

Lock acquisition fails if another active task already owns the same path, a parent path, or a child path.

Lock acquisition also fails when the requested path is outside the task's `allowedPaths` or overlaps `readOnlyPaths`.

List locks:

```powershell
./scripts/agent-locks.ps1 -Command list -FeatureId mcp-read-tools
```

Release locks:

```powershell
./scripts/agent-locks.ps1 `
  -Command release `
  -FeatureId mcp-read-tools `
  -TaskId task-001
```

## Create a Worktree

```powershell
./scripts/agent-worktree.ps1 `
  -Command create `
  -FeatureId mcp-read-tools `
  -TaskId task-001 `
  -AssignedRole requirements-analyst
```

This creates:

```txt
branch: ai/mcp-read-tools/task-001-requirements-analyst
worktree: .worktrees/mcp-read-tools/task-001
```

The command also records the branch and worktree in `tasks.json`.

## Validate a Diff

```powershell
./scripts/agent-locks.ps1 `
  -Command validate-diff `
  -FeatureId mcp-read-tools `
  -TaskId task-001 `
  -BaseRef main
```

The script validates all changed file sets against the task's `allowedPaths` and `readOnlyPaths`.

It includes:

- tracked changes: committed files changed on the task branch via `git diff --name-only <BaseRef>...HEAD`;
- staged changes: files staged for commit via `git diff --cached --name-only`;
- unstaged changes: tracked files modified locally via `git diff --name-only`;
- untracked files: new files not yet tracked via `git ls-files --others --exclude-standard`.

The validation fails when any changed file falls outside `allowedPaths` or inside `readOnlyPaths`.

Use `-WorkingTreeOnly` only for pre-commit local checks when branch history is intentionally out of scope:

```powershell
./scripts/agent-locks.ps1 `
  -Command validate-diff `
  -FeatureId mcp-read-tools `
  -TaskId task-001 `
  -WorkingTreeOnly
```

Final branch/worktree validation should use `-BaseRef` or a task state `baseRef`.

## Complete a Task

```powershell
./scripts/agent-feature.ps1 `
  -Command complete-task `
  -FeatureId mcp-read-tools `
  -TaskId task-001
```

Task completion updates `tasks.json`. It does not release locks automatically and does not merge branches.

## Remove a Worktree

Worktree removal is destructive and requires `-Force`.

```powershell
./scripts/agent-worktree.ps1 `
  -Command remove `
  -FeatureId mcp-read-tools `
  -TaskId task-001 `
  -Force
```

The script refuses to remove paths outside `.worktrees/`.

## Help

Every script supports `-Help`:

```powershell
./scripts/agent-feature.ps1 -Help
./scripts/agent-locks.ps1 -Help
./scripts/agent-worktree.ps1 -Help
```

## Validation

Use:

```powershell
./scripts/agent-feature.ps1 -Command validate -FeatureId <feature-id>
./scripts/agent-worktree.ps1 -Command validate -FeatureId <feature-id>
./scripts/agent-locks.ps1 -Command validate-diff -FeatureId <feature-id> -TaskId <task-id> -BaseRef main
```

Repository-level validation remains:

```powershell
./scripts/check.ps1
```

## Documented Example

See `docs/features/example-analyze-active-model/` for a documentation-only feature example: "Analyze active model and summarize categories using AI Gateway."

The example includes:

- a product brief, requirements, and acceptance criteria;
- a `task-plan.json` with `allowedPaths`, `readOnlyPaths`, validation commands, and handoff paths;
- role handoffs for product, requirements, Revit API review, QA, security, and PR review;
- a safe read-only Revit workflow that does not create real branches, worktrees, locks, or production code changes.

Use it as a reference for path ownership: each planned task owns a narrow write surface, and reviewers can reject any diff outside the task's `allowedPaths`.
