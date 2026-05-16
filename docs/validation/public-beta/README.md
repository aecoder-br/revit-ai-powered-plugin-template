# Public Beta Validation Evidence

Use this folder to record evidence for moving the template from **Internal RC** to **Public Beta**.

Public Beta validation is not complete unless a real machine has executed the required checks and recorded the results. These templates do not claim that validation has already passed.

## How To Use

1. Start from a clean working tree.
2. Record the commit hash.
3. Copy `VALIDATION_TEMPLATE.md` to a run-specific folder:

```txt
docs/validation/public-beta/runs/<yyyy-mm-dd>-<short-sha>/validation.md
```

4. Fill every section with observed results.
5. Attach or summarize logs for environment, commands, Revit builds, AI tooling, templates, MCP docs/config, and branch/worktree orchestration.
6. Record the final decision as one of:
   - `fail`
   - `internal rc`
   - `public beta ready`
   - `production ready candidate`

## Required References

- `docs/ai/public-beta-readiness-plan.md`
- `docs/ai/environment-validation.md`
- `docs/ai/post-remediation-review.md`
- `docs/ai/review-remediation.md`
- `scripts/validate-environment.ps1`

## Example Files

The `.example.md` files show section formats only. They are not real evidence:

- `environment.example.md`
- `commands.example.md`
- `revit-version-matrix.example.md`
- `ai-tools-matrix.example.md`
- `template-generation-matrix.example.md`
- `issues-found.example.md`
