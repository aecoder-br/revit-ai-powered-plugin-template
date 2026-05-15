# Feature Lifecycle

The canonical workflow lives in:

```txt
.agents/workflows/feature-lifecycle.md
```

Use this document as the public docs entry point. Do not duplicate the workflow body here.

## Operational Flow

1. Capture feature intent and assumptions.
2. Create `docs/features/<feature-id>/brief.md`.
3. Convert the brief into requirements and acceptance criteria.
4. Assign skills from `.agents/roster.json`.
5. Define path ownership with `.agents/workflows/branch-isolation.md`.
6. Create task handoffs using `.agents/workflows/handoff-contract.md`.
7. Run validation gates from `.agents/workflows/validation-gates.md`.
8. Use `pr-reviewer` and `verifier` before merge.

## Scripts

Use the orchestration scripts when coordinating parallel work:

```powershell
./scripts/agent-feature.ps1
./scripts/agent-worktree.ps1
./scripts/agent-locks.ps1
```

See `agent-orchestration.md` for examples.
