# PR Reviewer Handoff

## Review Focus

This example should demonstrate the agent workflow without production code changes.

## Findings Checklist

- `docs/features/example-analyze-active-model/` contains brief, requirements, acceptance criteria, task plan, and handoffs.
- `task-plan.json` is valid JSON.
- Each task has `allowedPaths`, `readOnlyPaths`, `validationCommands`, and `handoffPath`.
- The plan does not create real branches or worktrees.
- Path ownership prevents concurrent writes to the same files.
- Revit API rules are stated clearly.
- AI Gateway privacy and prompt-injection risks are called out.

## Validation Record

Record the exact commands run and any local environment limitations, especially missing .NET 10 SDK or missing Revit installations.

## PR Summary Draft

Adds a documentation-only example feature showing how the agent team should plan a safe read-only Revit AI workflow, including path ownership, handoffs, validation commands, Revit API boundaries, and AI Gateway privacy controls.
