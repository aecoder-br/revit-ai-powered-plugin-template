# Review Remediation

## HIGH-001: Build/check scripts masked failed dotnet commands

Status: remediated.

## Problem

The final AI-powered template review found that `scripts/check.ps1` and `scripts/build.ps1` could print failing `dotnet` command output while still returning exit code `0`.

This was risky because local and CI validation could appear successful even when `dotnet test` or `dotnet build` failed.

## Changes

- `scripts/check.ps1` now uses checked command helpers for external commands and nested PowerShell scripts.
- `scripts/check.ps1` throws when any executed command returns a non-zero exit code.
- `scripts/build.ps1` checks `$LASTEXITCODE` after each attempted `dotnet build`.
- `scripts/build.ps1 -RevitVersion all` now reports each version as:
  - `Passed`
  - `Failed`
  - `Skipped`
- Missing Revit install folders are explicit `Skipped` results and do not fail the script.
- Any failed build attempt now makes `scripts/build.ps1` return a failing exit code.

## Validation Notes

Use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/build.ps1 -RevitVersion all
```

In environments without .NET SDK 10.0, `scripts/check.ps1` is expected to fail when it executes projects targeting `net10.0`.

In environments without a given Revit version installed, `scripts/build.ps1 -RevitVersion all` is expected to report that version as `Skipped`, not `Passed`.

## Validation Results

Environment observed during remediation:

```txt
.NET SDKs:
8.0.204
9.0.300
```

Commands executed:

```powershell
git diff --check -- scripts/check.ps1 scripts/build.ps1 docs/ai/review-remediation.md
powershell -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell parser check for scripts/check.ps1 and scripts/build.ps1>"
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-skills.ps1 -RootPath . -IncludeMirrors
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/build.ps1 -RevitVersion all
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/build.ps1 -RevitVersion 2026
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
dotnet __codex_invalid_command__
dotnet --list-sdks
```

Results:

- PowerShell parser check passed for `scripts/check.ps1` and `scripts/build.ps1`.
- `validate-skills.ps1 -IncludeMirrors` passed with 60 validated skills.
- `scripts/build.ps1 -RevitVersion all` returned exit code `1` because Revit 2024 and 2025 builds were attempted and failed with `NETSDK1045` due to missing .NET SDK 10.0 support in the local environment.
- `scripts/build.ps1 -RevitVersion all` reported Revit 2026 and Revit 2027 as `Skipped` because their install folders were not present.
- `scripts/build.ps1 -RevitVersion 2026` returned exit code `0` and reported Revit 2026 as `Skipped` because the install folder was not present.
- `scripts/check.ps1` returned exit code `1` at the first failing executed external command: `dotnet test` for `tests/RevitAiTemplate.Application.Tests`.
- `dotnet __codex_invalid_command__` returned exit code `1`, confirming a simple safe invalid `dotnet` command produces a non-zero exit code.

CI update:

- No workflow change was required for HIGH-001 because `.github/workflows/ci.yml` already runs `scripts/check.ps1` through `powershell -NoProfile -ExecutionPolicy Bypass -File`.
- The corrected script exit codes are now sufficient for CI to fail when an executed command fails.

## HIGH-002: validate-diff missed untracked files and committed branch changes

Status: remediated.

## MEDIUM-002: acquire did not enforce task path ownership

Status: remediated.

## Problem

The final AI-powered template review found that `scripts/agent-locks.ps1 validate-diff` validated only tracked working-tree and staged changes. It did not include untracked files and could miss committed branch changes when no base ref was supplied.

The review also found that `scripts/agent-locks.ps1 acquire` checked lock conflicts, but did not reject requested lock paths outside the task's `allowedPaths` or inside `readOnlyPaths`.

## Changes

- `validate-diff` now includes committed branch changes with `git diff --name-only <BaseRef>...HEAD`.
- `validate-diff` now includes staged changes with `git diff --cached --name-only`.
- `validate-diff` now includes unstaged tracked changes with `git diff --name-only`.
- `validate-diff` now includes untracked files with `git ls-files --others --exclude-standard`.
- `validate-diff` now de-duplicates and normalizes changed paths before validation.
- `validate-diff` now requires `-BaseRef`, a task `baseRef`, or explicit `-WorkingTreeOnly`.
- `validate-diff` now fails when a changed file is outside `allowedPaths` or inside `readOnlyPaths`.
- `acquire` now rejects lock paths outside the task's `allowedPaths`.
- `acquire` now rejects lock paths that overlap the task's `readOnlyPaths`.
- `acquire` error messages now include the requested path, `allowedPaths`, `readOnlyPaths`, and conflicting task when applicable.

## Validation Notes

Use branch validation with a base ref:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Command validate-diff -FeatureId <feature-id> -TaskId <task-id> -BaseRef main
```

Use working-tree-only validation only for pre-commit checks:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Command validate-diff -FeatureId <feature-id> -TaskId <task-id> -WorkingTreeOnly
```

The final branch/worktree validation gate should not use `-WorkingTreeOnly`.

## Validation Results

Temporary state was created under `.agents/state/manual-lock-test/` and removed after validation. No branch or worktree was created.

Commands executed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Help
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Command validate-diff -FeatureId manual-lock-test -TaskId task-001 -WorkingTreeOnly
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Command validate-diff -FeatureId manual-lock-test -TaskId task-002 -WorkingTreeOnly
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Command validate-diff -FeatureId manual-lock-test -TaskId task-001 -WorkingTreeOnly
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Command validate-diff -FeatureId manual-lock-test -TaskId task-005
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Command acquire -FeatureId manual-lock-test -TaskId task-001 -Paths scripts/agent-locks.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Command acquire -FeatureId manual-lock-test -TaskId task-003 -Paths README.md
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/agent-locks.ps1 -Command acquire -FeatureId manual-lock-test -TaskId task-004 -Paths scripts/agent-locks.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-skills.ps1 -RootPath . -IncludeMirrors
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
```

Results:

- PowerShell parser check passed for `scripts/agent-locks.ps1`.
- `validate-diff -WorkingTreeOnly` passed when all current changes were inside `allowedPaths`.
- `validate-diff -WorkingTreeOnly` failed for tracked changes outside `allowedPaths`.
- `validate-diff -WorkingTreeOnly` failed for an untracked file outside `allowedPaths`.
- `validate-diff` without `-BaseRef`, task `baseRef`, or `-WorkingTreeOnly` failed with the expected BaseRef error.
- `acquire` succeeded for a path inside `allowedPaths`.
- `acquire` failed for a path overlapping `readOnlyPaths`.
- `acquire` failed for a lock conflict and reported the conflicting task.
- `validate-skills.ps1 -IncludeMirrors` passed with 60 validated skills after the lock-script change.
- `scripts/check.ps1` was run after the lock-script change and failed at `dotnet test` with `NETSDK1045` because the local environment still lacks .NET SDK 10.0. This confirms the corrected check script propagates executed command failures.
- Temporary test artifacts were removed after validation.
