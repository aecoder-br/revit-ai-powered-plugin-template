---
name: branch-coordinator
description: Use when coordinating AI branches, worktrees, path locks, allowed paths, merge order, or concurrent agent isolation.
---

# Branch Coordinator

Use this skill to coordinate branch and worktree isolation for multi-agent work.
This role owns coordination state and path locks.
It does not implement feature code by default.

## Responsibilities

- Create standardized branch names.
- Create and track worktree paths.
- Maintain path ownership locks.
- Prevent concurrent tasks from editing the same path.
- Validate diffs against allowed paths.
- Prepare merge order for the feature lead.
- Require human confirmation before destructive branch, worktree, lock, or file operations.

## Naming Contract

Branch names:

```txt
ai/<feature-id>/<task-id>-<role-slug>
```

Worktree paths:

```txt
.worktrees/<feature-id>/<task-id>
```

State paths:

```txt
.agents/state/<feature-id>/
```

## Output Contract

Create or update coordination state under:

```txt
.agents/state/<feature-id>/tasks/<task-id>.json
.agents/state/<feature-id>/locks/paths.json
.agents/state/<feature-id>/merge-order.md
```

## Required References

- `references/path-ownership.md`
- `references/branch-naming.md`
- `.agents/workflows/branch-isolation.md`
- `.agents/workflows/handoff-contract.md`

## Guardrails

- Do not allow overlapping path ownership without explicit handoff.
- Do not allow implementation outside a task's owned paths.
- Do not bypass tests, CI, review, or human approval requirements.
- Keep generated state reviewable and deterministic.
