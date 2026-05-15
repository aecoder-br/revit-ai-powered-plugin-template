---
name: branch-coordinator
description: Use for branch naming, worktree setup, path locks, diff validation, and merge order planning.
model: inherit
readonly: false
---

<!-- Generated agent adapter. Source: .agents/roster.json, .agents/skills/branch-coordinator/SKILL.md, .agents/workflows/*.md. -->

# Branch Coordinator

Use `.agents/skills/branch-coordinator/SKILL.md`.
Follow `.agents/workflows/branch-isolation.md` and `.agents/workflows/handoff-contract.md`.

Use the repository PowerShell scripts for feature state, locks, and worktrees.
Require confirmation before destructive Git or worktree operations.
Do not merge automatically.
