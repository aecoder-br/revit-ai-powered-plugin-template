# Post-Remediation AI-Powered Workflow Review

## Summary

Review date: 2026-05-15.

Scope reviewed:

- `docs/ai/final-ai-powered-template-review.md`
- `docs/ai/review-remediation.md`
- `scripts/check.ps1`
- `scripts/build.ps1`
- `scripts/agent-locks.ps1`
- `scripts/setup-ai-tools.ps1`
- `scripts/validate-ai-adapters.ps1`
- `scripts/validate-skills.ps1`
- `.agents/roster.json`
- `.claude/agents`
- `.cursor/agents`
- `.codex/config.toml`
- `.github/prompts`
- `templates/dotnet/RevitAiPlugin/.template.config/template.json`
- `templates/visualstudio`

Overall status: the high-risk workflow defects from the previous review are fixed. The repository now has explicit validation for command exit codes, path ownership, AI adapter parity, Codex TOML smoke validation, and template option recording.

The remaining issues are productization gaps, not hidden correctness failures: the dotnet template still does not fully conditionally remove all optional surfaces, the Visual Studio ProjectGroup template remains a documented v1 base, actionlint is non-blocking, and full clean `scripts/check.ps1` validation could not complete on this machine because .NET SDK 10.0 is not installed.

## Fixed Findings

### HIGH-001: build/check scripts masked failed dotnet commands

Status: fixed.

Evidence:

- `scripts/check.ps1` uses `Invoke-CheckedExternalCommand` and `Invoke-CheckedScriptBlock`.
- `scripts/check.ps1` now throws when `$LASTEXITCODE` is non-zero.
- `scripts/build.ps1` captures `$LASTEXITCODE` after each attempted `dotnet build`.
- `scripts/build.ps1 -RevitVersion all` reports `Passed`, `Failed`, and `Skipped`.

Validation result:

- `scripts/build.ps1 -RevitVersion all` returned exit code `1` after attempted Revit 2024 and 2025 builds failed with `NETSDK1045`.
- Revit 2026 and 2027 were reported as `Skipped` when their install folders were absent.
- `scripts/build.ps1 -RevitVersion 2026` returned success and reported `Skipped`, not `Passed`, because Revit 2026 is not installed.
- `scripts/check.ps1` failed at the executed `dotnet test` step with `NETSDK1045`, proving it no longer masks executed command failures.

### HIGH-002: validate-diff did not fully enforce path ownership

Status: fixed.

Evidence in `scripts/agent-locks.ps1`:

- committed branch changes: `git diff --name-only <BaseRef>...HEAD`;
- staged changes: `git diff --cached --name-only`;
- unstaged changes: `git diff --name-only`;
- untracked files: `git ls-files --others --exclude-standard`;
- duplicate normalization with `Sort-Object -Unique`;
- required `-BaseRef`, task `baseRef`, or explicit `-WorkingTreeOnly`;
- validation against both `allowedPaths` and `readOnlyPaths`.

Residual note: `-WorkingTreeOnly` is still available and useful for pre-commit checks, but the docs now warn that final branch/worktree validation should use a base ref.

### MEDIUM-001: adapter drift was not detectable

Status: fixed operationally.

Evidence:

- `scripts/validate-ai-adapters.ps1` exists.
- It loads `.agents/roster.json`.
- It verifies canonical skills for roster roles.
- It validates Claude and Cursor mirrors when present.
- It validates primary Claude/Cursor agent files reference canonical skills.
- It validates Codex static adapter files.
- It validates required Copilot prompt files reference canonical guidance.
- `scripts/check.ps1` calls the adapter validator when `.agents/roster.json` exists.

Validation result:

- `scripts/validate-ai-adapters.ps1 -Tools All -FailOnWarnings` passed with 84 passed checks, 0 warnings, and 0 failures.

### MEDIUM-002: lock acquisition did not enforce task allowed paths

Status: fixed.

Evidence in `scripts/agent-locks.ps1`:

- `acquire` loads task state from `.agents/state/<feature-id>/tasks.json`.
- It rejects lock requests when the task has no `allowedPaths`.
- It rejects requested paths outside `allowedPaths`.
- It rejects requested paths overlapping `readOnlyPaths`.
- It still checks conflicts against active locks held by other tasks.

### LOW-003: setup-ai-tools All behavior was ambiguous

Status: fixed.

Evidence:

- `scripts/setup-ai-tools.ps1` accepts `All`, `Codex`, `Claude`, `Cursor`, `Copilot`, and `None`.
- `All` expands to Codex, Claude, Cursor, and Copilot.
- Claude/Cursor refresh skill mirrors.
- Codex validates/creates static `.codex` files and states that Codex reads `.agents/skills` directly.
- Copilot validates/creates static instructions/prompts and states that Copilot does not use skill mirrors.
- `-ValidateAdapters` calls `scripts/validate-ai-adapters.ps1`.
- `-Validate` runs skill validation and adapter validation.

Validation result:

- `scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters` passed.

## Partially Mitigated Findings

### MEDIUM-003: dotnet template choices were mostly declarative

Status: mitigated for v1, not fully fixed.

Evidence:

- `docs/generated/template-options.md` records selected template options in generated projects.
- `templates/dotnet/RevitAiPlugin/.template.config/template.json` replaces `AiTools`, `RevitVersions`, and include flag placeholders.
- The template JSON now includes computed symbols for future conditional behavior.
- Safe modifiers exist for non-solution assets such as installer planning files and Autodesk Product Help MCP examples.
- `templates/dotnet/RevitAiPlugin/README.md` and `README.md` explicitly state that v1 does not fully remove every unused project, solution entry, adapter, or documentation file.
- `scripts/pack-dotnet-template.ps1 -TestMatrix` exists and validates generated option records for `none`, `codex`, `claude`, `cursor`, `copilot`, and `multi`.

Remaining gap:

- Selecting `--AiTools none` or a narrower `--RevitVersions` still leaves most of the full professional template surface in place.
- This is now honest and testable, but not a complete conditional template implementation.

### MEDIUM-004: CI did not use actionlint

Status: mitigated, not fully blocking.

Evidence:

- `.github/workflows/ai-config-validation.yml` has a `lint-workflows` job.
- The job uses `rhysd/actionlint@v1`.
- The job is `continue-on-error: true`.
- `docs/ai/ci-validation.md` documents the dependency and manual fallback.

Remaining gap:

- `actionlint` is not installed locally in this environment, so local actionlint validation was not run.
- Because the job is non-blocking, workflow lint failures provide signal but do not block the AI config validation workflow.

### LOW-001: Visual Studio ProjectGroup child templates were incomplete

Status: mitigated by documentation and roadmap, not fully implemented.

Evidence:

- `templates/visualstudio/README.md` clearly states the current Visual Studio template is a v1 base and not production-ready.
- `docs/ai/visual-studio-template-v2-plan.md` defines the v2 plan for all 9 child templates.
- `templates/visualstudio/projects/Core/Core.vstemplate` exists as a minimal reference skeleton.
- `templates/visualstudio/projects/Core/RevitAiPlugin.Core.csproj` exists as the skeleton project file.

Remaining gap:

- The ProjectGroup still references child templates that are not all implemented.
- Native Visual Studio Create Project support should not be advertised as complete.

### LOW-002: Codex TOML validation was shallow

Status: mitigated with repository-focused smoke validation.

Evidence:

- `scripts/validate-toml.ps1` exists.
- `scripts/check.ps1` calls it when `.codex/config.toml` exists.
- `.github/workflows/ai-config-validation.yml` calls it.
- `docs/ai/ci-validation.md` documents that this is not a full TOML 1.0 parser.

Validation result:

- `scripts/validate-toml.ps1 -VerboseReport` passed with 14 passed checks, 0 warnings, and 0 failures.

Remaining gap:

- The validator intentionally supports the repository's current TOML subset. If `.codex/config.toml` grows to use advanced TOML constructs, a pinned real TOML parser should replace or supplement it.

## Remaining Risks

- Full `scripts/check.ps1` still cannot complete on this machine because only .NET SDK 8.0.204 and 9.0.300 are available; projects targeting .NET 10 fail with `NETSDK1045`.
- Full Revit build coverage was not proven because Revit 2026 and 2027 install folders are absent, while Revit 2024/2025 attempted builds fail before completion due to the SDK gap.
- `scripts/validate-ai-adapters.ps1` detects expected adapter drift for current surfaces, but it does not deeply parse `.codex/config.toml` profile semantics against every roster role.
- `scripts/setup-ai-tools.ps1 -Mode Symlink` was reviewed but not executed; Windows symlink privileges and behavior remain environment-dependent.
- `scripts/pack-dotnet-template.ps1 -TestMatrix` was not rerun during this post-remediation review because it installs a local dotnet template and rewrites `artifacts/`; it is already documented in remediation evidence.
- Visual Studio native template support remains a roadmap item until all child templates are implemented and generated solutions are opened/tested in Visual Studio.
- `actionlint` is non-blocking in CI and unavailable locally here; workflow lint coverage is advisory, not a release gate.

## Commands Run

```powershell
Select-String -LiteralPath 'C:\Users\MayconFreitas.AECODER-MAYCON\.codex\memories\MEMORY.md' -Pattern 'revit-ai-powered-plugin-template|AI-powered template|adapter parity|validate-ai' -Context 0,2
Get-Content -Raw -LiteralPath 'docs/ai/final-ai-powered-template-review.md'
Get-Content -Raw -LiteralPath 'docs/ai/review-remediation.md'
Get-Content -Raw -LiteralPath 'scripts/check.ps1'
Get-Content -Raw -LiteralPath 'scripts/build.ps1'
Get-Content -Raw -LiteralPath 'scripts/agent-locks.ps1'
Get-Content -Raw -LiteralPath 'scripts/setup-ai-tools.ps1'
Get-Content -Raw -LiteralPath 'scripts/validate-ai-adapters.ps1'
Get-Content -Raw -LiteralPath 'scripts/validate-toml.ps1'
Get-Content -Raw -LiteralPath 'templates/dotnet/RevitAiPlugin/.template.config/template.json'
Get-Content -Raw -LiteralPath 'templates/visualstudio/README.md'
powershell -NoProfile -ExecutionPolicy Bypass -File 'scripts/validate-skills.ps1' -RootPath '<repo>' -IncludeMirrors -FailOnWarnings
powershell -NoProfile -ExecutionPolicy Bypass -File 'scripts/validate-ai-adapters.ps1' -RootPath '<repo>' -Tools All -FailOnWarnings
powershell -NoProfile -ExecutionPolicy Bypass -File 'scripts/validate-toml.ps1' -RootPath '<repo>' -VerboseReport
Get-Command actionlint -ErrorAction SilentlyContinue
Get-Content -Raw -LiteralPath 'templates/dotnet/RevitAiPlugin/.template.config/template.json' | ConvertFrom-Json | Out-Null
[xml](Get-Content -Raw -LiteralPath 'templates/visualstudio/RevitAiPlugin.ProjectGroup.vstemplate') | Out-Null
[xml](Get-Content -Raw -LiteralPath 'templates/visualstudio/projects/Core/Core.vstemplate') | Out-Null
powershell -NoProfile -ExecutionPolicy Bypass -File 'scripts/build.ps1' -RevitVersion all
powershell -NoProfile -ExecutionPolicy Bypass -File 'scripts/build.ps1' -RevitVersion 2026
powershell -NoProfile -ExecutionPolicy Bypass -File 'scripts/setup-ai-tools.ps1' -RootPath '<repo>' -Tools All -Mode Copy -Validate -ValidateAdapters
powershell -NoProfile -ExecutionPolicy Bypass -File 'scripts/check.ps1'
git status --short
```

Command outcomes:

- `validate-skills.ps1 -IncludeMirrors -FailOnWarnings`: passed, 60 skills.
- `validate-ai-adapters.ps1 -Tools All -FailOnWarnings`: passed, 84 checks, 0 warnings, 0 failures.
- `validate-toml.ps1 -VerboseReport`: passed, 14 checks, 0 warnings, 0 failures.
- `template.json` parsed as JSON.
- Root Visual Studio ProjectGroup `.vstemplate` parsed as XML.
- Core child `.vstemplate` parsed as XML.
- `setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters`: passed; existing mirrors were skipped without `-Force`.
- `build.ps1 -RevitVersion all`: failed as expected after Revit 2024 and 2025 attempted builds returned `NETSDK1045`; Revit 2026 and 2027 were reported as `Skipped`.
- `build.ps1 -RevitVersion 2026`: returned success and reported `Skipped` because Revit 2026 is not installed.
- `check.ps1`: passed skills, adapter parity, and TOML validation, then failed at `dotnet test` with `NETSDK1045` due to missing .NET SDK 10.0.
- `actionlint`: not found locally.

## Commands Not Run And Why

- `actionlint`: not run because it is not installed locally. The repository now has a non-blocking CI job for it.
- `scripts/pack-dotnet-template.ps1 -TestMatrix`: not rerun in this post-remediation review because it rewrites `artifacts/` and installs a local dotnet template. The remediation document records the successful matrix run.
- Full Revit 2024-2027 runtime validation inside Revit: not run because this environment does not have all Revit versions installed and lacks .NET SDK 10.0.
- Visual Studio interactive template creation: not run because the current ProjectGroup template is explicitly v1/base and not complete.
- Manual branch/worktree lock simulations: not rerun because this review avoids creating temporary `.agents/state`, branches, or worktrees; the script implementation and prior remediation evidence were reviewed.

## Release Recommendation

Recommendation: **Internal RC**.

Rationale:

- Not `Blocked`: high-severity workflow issues are fixed, and core validators now fail on real failures.
- Not `Production-ready`: full clean validation cannot complete in this local environment, the native Visual Studio template is still v1/base, TOML parsing is intentionally subset-based, and template conditional removal is incomplete.
- Not yet `Public beta`: public users would still hit documented-but-real productization gaps in Visual Studio native templates and conditional dotnet template generation.
- `Internal RC` is appropriate for internal dogfooding, CI hardening, and template-generation trials on a Windows machine with .NET SDK 10.0 and the intended Revit versions installed.
