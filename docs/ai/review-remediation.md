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

## MEDIUM-001: AI tool adapters could drift from the canonical roster

Status: remediated operationally.

## Problem

The final AI-powered template review found that `scripts/setup-ai-tools.ps1` refreshes Claude and Cursor skill mirrors, but did not validate all tool-specific adapter surfaces against `.agents/roster.json`.

This meant `.claude/agents`, `.cursor/agents`, `.codex/config.toml`, `.github/prompts`, and tool documentation could drift from the canonical `.agents/skills` layer.

## Changes

- Added `scripts/validate-ai-adapters.ps1`.
- Added `.codex/README.md` to document that Codex uses `.agents/skills` as the canonical skill source.
- Added `docs/ai/adapter-parity-validation.md`.
- Updated `scripts/check.ps1` to call adapter parity validation when `.agents/roster.json` exists.
- Updated `.github/workflows/ai-config-validation.yml` to run adapter parity validation in CI.

## Validation Notes

Use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -Tools All
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -Tools All -FailOnWarnings
```

The validator reports drift only. It does not generate, overwrite, or delete adapters.

## Validation Results

Commands executed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell parser check for scripts/validate-ai-adapters.ps1 and scripts/check.ps1>"
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -Tools All
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -Tools All -FailOnWarnings
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -Tools All -VerboseReport
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
```

Results:

- PowerShell parser check passed for `scripts/validate-ai-adapters.ps1` and `scripts/check.ps1`.
- `validate-ai-adapters.ps1 -Tools All` passed with 84 passed checks, 0 warnings, and 0 failures.
- `validate-ai-adapters.ps1 -Tools All -FailOnWarnings` passed with 84 passed checks, 0 warnings, and 0 failures.
- `validate-ai-adapters.ps1 -Tools All -VerboseReport` passed and listed canonical skills, Claude mirrors, Cursor mirrors, primary agent adapter references, Codex files, and Copilot prompts.
- `scripts/check.ps1` now runs adapter parity validation after skill validation. It passed adapter parity validation, then failed at `dotnet test` with `NETSDK1045` because the local environment still lacks .NET SDK 10.0.

## LOW-003: `setup-ai-tools.ps1 -Tools All` could imply every adapter is dynamically refreshed

Status: remediated.

## Problem

The final AI-powered template review found that `scripts/setup-ai-tools.ps1 -Tools All` refreshed Claude and Cursor mirrors, while Codex and GitHub Copilot remained static repository adapters.

This could make users think all four tools were being regenerated dynamically.

## Changes

- `scripts/setup-ai-tools.ps1 -Tools` now accepts `All`, `Codex`, `Claude`, `Cursor`, `Copilot`, and `None`.
- `-Tools All` now covers all four supported tools explicitly.
- Claude and Cursor continue to refresh `.claude/skills` and `.cursor/skills` from `.agents/skills`.
- Codex now has an explicit validation/create branch for `.codex/README.md` and `.codex/config.toml`.
- Copilot now has an explicit validation/create branch for `.github/copilot-instructions.md` and `.github/prompts`.
- Added `-ValidateAdapters` to run `scripts/validate-ai-adapters.ps1`.
- `-Validate` now runs both `scripts/validate-skills.ps1` and `scripts/validate-ai-adapters.ps1`.
- Setup documentation now distinguishes "refresh mirrors" for Claude/Cursor from "validate static adapters" for Codex/Copilot.

## Validation Notes

Use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/setup-ai-tools.ps1 -Tools Codex,Copilot -ValidateAdapters
```

## Validation Results

Commands executed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell parser check for scripts/setup-ai-tools.ps1>"
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/setup-ai-tools.ps1 -Tools Codex,Copilot -ValidateAdapters
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
```

Results:

- PowerShell parser check passed for `scripts/setup-ai-tools.ps1`.
- `setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters` passed. Existing Claude/Cursor mirrors were skipped without `-Force`, Codex/Copilot static adapters were validated, skill validation passed with 60 skills, and adapter parity passed with 84 checks.
- `setup-ai-tools.ps1 -Tools Codex,Copilot -ValidateAdapters` passed. The script accepts the comma-separated tool list used by `powershell -File`, validated Codex/Copilot static adapters, and adapter parity passed with 32 checks.
- `scripts/check.ps1` passed skill validation and adapter parity validation, then failed at `dotnet test` with `NETSDK1045` because the local environment still lacks .NET SDK 10.0.

## MEDIUM-003: dotnet template choices were mostly declarative

Status: mitigated for v1.

## Problem

The final AI-powered template review found that `AiTools`, `RevitVersions`, and include flags existed as dotnet template symbols, but did not yet remove or include projects and files conditionally.

This could confuse users who selected a narrow option such as `--AiTools none` and still received the full professional template surface.

## Changes

- Added `docs/generated/template-options.md` as a generated creation record.
- Added replacements for `RevitVersions`, `AiTools`, `IncludeMcpServer`, `IncludeAutodeskProductHelpMcp`, `IncludeAiGateway`, `IncludeWebView2`, and `IncludeInstaller`.
- Added computed symbols in `template.json` to prepare future conditional template modifiers.
- Added safe conditional modifiers for non-solution assets:
  - exclude `installer/**` when `IncludeInstaller` is false;
  - exclude Autodesk Product Help MCP examples when `IncludeAutodeskProductHelpMcp` is false.
- Updated `scripts/pack-dotnet-template.ps1` with `-TestMatrix`.
- The test matrix generates samples for `AiTools` values `none`, `codex`, `claude`, `cursor`, `copilot`, and `multi`.
- Each generated sample is checked for `docs/generated/template-options.md` and the selected `AiTools` value.
- README documentation now states that v1 records selected options but does not yet perform complete conditional removal of projects, solution entries, adapters, or docs.

## Validation Notes

Use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Content -Raw ./templates/dotnet/RevitAiPlugin/.template.config/template.json | ConvertFrom-Json | Out-Null"
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/pack-dotnet-template.ps1 -TestMatrix
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
```

## Validation Results

Commands executed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Content -Raw ./templates/dotnet/RevitAiPlugin/.template.config/template.json | ConvertFrom-Json | Out-Null"
powershell -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell parser check for scripts/pack-dotnet-template.ps1>"
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/pack-dotnet-template.ps1 -TestMatrix
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
```

Results:

- `template.json` parsed successfully as JSON.
- PowerShell parser check passed for `scripts/pack-dotnet-template.ps1`.
- `pack-dotnet-template.ps1 -TestMatrix` passed after recreating the staged template under `artifacts/templates/RevitAiPlugin`.
- The matrix generated and validated samples for `AiTools` values `none`, `codex`, `claude`, `cursor`, `copilot`, and `multi`.
- Each sample contained `docs/generated/template-options.md` with the expected selected `AiTools` value and no unreplaced `AiTools` or `RevitVersions` placeholders.
- `scripts/check.ps1` passed skill validation and adapter parity validation, then failed at `dotnet test` with `NETSDK1045` because the local environment still lacks .NET SDK 10.0.

## MEDIUM-004: CI did not lint GitHub Actions workflows with actionlint

Status: mitigated.

## Problem

The final AI-powered template review found that CI validated repository content, but did not lint GitHub Actions workflow syntax with `actionlint`.

This left workflow expression, shell, and indentation issues to manual review.

## Changes

- Added a non-blocking `lint-workflows` job to `.github/workflows/ai-config-validation.yml`.
- The job uses `rhysd/actionlint@v1`.
- The job is marked `continue-on-error: true` so the external dependency provides signal without making AI config validation fragile.
- Added `docs/ai/ci-validation.md` to document the dependency and local/manual fallback.

## Validation Notes

Use:

```powershell
actionlint
```

If `actionlint` is not installed locally, review `.github/workflows/ai-config-validation.yml` manually and rely on the non-blocking CI job for additional feedback.

## Validation Results

Commands executed:

```powershell
Get-Command actionlint -ErrorAction SilentlyContinue
powershell -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell parser check for scripts/validate-toml.ps1 and scripts/check.ps1>"
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-toml.ps1 -VerboseReport
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
```

Results:

- `actionlint` was not installed in the local environment, so workflow linting was reviewed by reading `.github/workflows/ai-config-validation.yml` and is delegated to the non-blocking CI job.
- PowerShell parser checks passed for `scripts/validate-toml.ps1` and `scripts/check.ps1`.
- `validate-toml.ps1 -VerboseReport` passed with 14 passed checks, 0 warnings, and 0 failures.
- `scripts/check.ps1` passed skill validation, adapter parity validation, and Codex TOML validation, then failed at `dotnet test` with `NETSDK1045` because the local environment still lacks .NET SDK 10.0.

## LOW-002: Codex config syntax validation was intentionally shallow

Status: mitigated with repository-focused validation.

## Problem

The final AI-powered template review found that `.codex/config.toml` validation was a shallow textual check.

PowerShell does not include a native full TOML parser, and adding a heavy dependency would make the default CI more fragile.

## Changes

- Added `scripts/validate-toml.ps1`.
- Replaced the inline TOML text check in `.github/workflows/ai-config-validation.yml` with the new script.
- Updated `scripts/check.ps1` to call `scripts/validate-toml.ps1` when `.codex/config.toml` exists.
- Added `docs/ai/ci-validation.md` documenting TOML validation scope and limitations.

The validator checks section syntax, key/value syntax, duplicate sections, duplicate keys, balanced quoted strings, required Codex root keys, recognized conservative policy values, profile sections, and obvious secret-related terms.

It remains a smoke parser for the repository's TOML subset, not a full TOML 1.0 parser.

## Validation Notes

Use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-toml.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
```

## Validation Results

Commands executed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-toml.ps1 -VerboseReport
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
```

Results:

- `validate-toml.ps1 -VerboseReport` passed with 14 passed checks, 0 warnings, and 0 failures.
- `scripts/check.ps1` now calls `scripts/validate-toml.ps1` when `.codex/config.toml` exists.
- `scripts/check.ps1` passed Codex TOML validation and then failed at `dotnet test` with `NETSDK1045` because the local environment still lacks .NET SDK 10.0.
