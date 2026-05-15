# Feature Plan Template

Use this reference to create the feature planning artifacts for `orchestrator-feature-lead`.

## Feature Id

Use lowercase kebab-case:

```txt
<short-domain>-<short-feature>
```

Examples:

```txt
mcp-read-tools
visual-studio-template-packaging
revit-write-tool-confirmation
```

## `brief.md`

```md
# <Feature Title>

## Summary

<One short paragraph describing the user value and technical goal.>

## Source Request

<Quote or summarize the user request without adding implementation assumptions.>

## In Scope

- ...

## Out of Scope

- ...

## Architecture Constraints

- Revit API boundary:
- ExternalEvent requirement:
- Runtime AI/MCP requirement:
- Multi-version requirement:

## Risks

- ...

## Open Questions

- ...
```

## `requirements.md`

```md
# Requirements

## Functional Requirements

- FR-001:

## Non-Functional Requirements

- NFR-001:

## Validation Requirements

- VR-001:

## Security and Data Handling

- SD-001:

## Acceptance Criteria

- AC-001:
```

## `task-plan.json`

```json
{
  "featureId": "<feature-id>",
  "status": "planned",
  "tasks": [
    {
      "taskId": "task-001",
      "title": "Short task title",
      "role": "role-name",
      "skill": "skill-name",
      "branch": "ai/<feature-id>/task-001-role-name",
      "worktree": ".worktrees/<feature-id>/task-001",
      "ownedPaths": [
        "path/or/file"
      ],
      "blockedPaths": [],
      "dependencies": [],
      "validation": [
        "./scripts/check.ps1"
      ],
      "handoff": "docs/features/<feature-id>/handoffs/task-001.md"
    }
  ],
  "mergeOrder": [
    "task-001"
  ]
}
```

## Task Split Rules

- Split by path ownership first, role second.
- Keep shared files such as `AGENTS.md`, `README.md`, `Directory.Build.props`, solution files, and scripts under a single owner at a time.
- Put Revit API tasks behind architecture and requirements tasks when possible.
- Put verifier tasks after implementation tasks.
- Put `pr-reviewer` last before merge readiness.

## Handoff Directory

Create one handoff file per task:

```txt
docs/features/<feature-id>/handoffs/<task-id>.md
```

Use `.agents/workflows/handoff-contract.md` as the format.
