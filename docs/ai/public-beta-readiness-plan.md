# Public Beta Readiness Plan

## Objective

Move the AI-powered Revit add-in template from **Internal RC** to **Public Beta** with explicit validation evidence, clear productization limits, and no claim of production readiness.

Public Beta means the repository is usable by early adopters who accept documented limitations and can run validation on a Windows workstation with the required Autodesk Revit installations and .NET SDKs. It does not mean the template is ready for broad production rollout, unattended customer delivery, or complete Visual Studio native template packaging.

Release state definitions:

- **Internal RC**: suitable for internal dogfooding, remediation verification, and controlled template trials.
- **Public Beta**: suitable for external early adopters after the required validation matrix passes or has documented acceptable skips.
- **Production-ready**: requires complete productization, full installer/template behavior, blocking CI linting, full Revit version validation, and no known beta limitations.

## Entry Criteria

Public Beta validation can start only when all items below are true:

- `docs/ai/post-remediation-review.md` recommends **Internal RC** or better.
- `docs/ai/review-remediation.md` marks HIGH-001 and HIGH-002 as remediated.
- The validation machine is Windows-based and has PowerShell available.
- .NET SDK 10.0 is installed because Revit 2027 targets `net10.0-windows`.
- Revit 2024, 2025, 2026, and 2027 validation status is known for the target beta environment.
- The repository working tree is clean before validation begins, except for explicitly documented evidence files.
- No release messaging calls the Visual Studio ProjectGroup template complete or production-ready.

## Exit Criteria

The template can be labeled **Public Beta** only when all items below are satisfied:

- `scripts/validate-skills.ps1 -IncludeMirrors -FailOnWarnings` passes.
- `scripts/validate-ai-adapters.ps1 -Tools All -FailOnWarnings` passes.
- `scripts/validate-toml.ps1 -VerboseReport` passes.
- `scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters` passes.
- `scripts/check.ps1` passes on a machine with the required SDKs, or any failure is documented as an accepted beta limitation and not a masked script failure.
- `scripts/build.ps1 -RevitVersion all` reports each installed and attempted Revit version as `Passed`; missing versions may be `Skipped` only for non-release local checks, not for final Public Beta sign-off.
- The dotnet template test matrix validates generated `docs/generated/template-options.md` for all supported `AiTools` values.
- Visual Studio solution opening and build instructions are verified.
- Visual Studio ProjectGroup v1 packaging is validated only as a base artifact and is not advertised as complete.
- Evidence is recorded under a dedicated validation evidence folder.

## Required Validation Environment

Use a dedicated Windows workstation or self-hosted runner with:

- Windows 10/11 or Windows Server runner compatible with Visual Studio and Revit tooling.
- PowerShell 5.1 and, preferably, PowerShell 7.
- Git.
- .NET SDK 8.0 for Revit 2025 and 2026 projects.
- .NET SDK 10.0 for Revit 2027 projects.
- .NET Framework 4.8 targeting pack for Revit 2024.
- Visual Studio 2022 or newer with .NET desktop workload.
- Autodesk Revit 2024, 2025, 2026, and 2027 installed for final Public Beta sign-off.
- Internet access only where required for normal package restore or optional tool installation.

Do not treat a machine without .NET SDK 10.0 as sufficient for Public Beta sign-off.

## Revit Validation Matrix

| Revit Version | Target Framework | Required For Public Beta | Command | Expected Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| Revit 2024 | `net48` | Yes | `./scripts/build.ps1 -RevitVersion 2024` | `Passed` on final beta machine | Build log, SDK list, Revit install path |
| Revit 2025 | `net8.0-windows` | Yes | `./scripts/build.ps1 -RevitVersion 2025` | `Passed` on final beta machine | Build log, SDK list, Revit install path |
| Revit 2026 | `net8.0-windows` | Yes | `./scripts/build.ps1 -RevitVersion 2026` | `Passed` on final beta machine | Build log, SDK list, Revit install path |
| Revit 2027 | `net10.0-windows` | Yes | `./scripts/build.ps1 -RevitVersion 2027` | `Passed` with .NET SDK 10.0 installed | Build log, SDK list, Revit install path |
| All versions | Mixed | Yes | `./scripts/build.ps1 -RevitVersion all` | All installed versions `Passed`; no final sign-off skips | Combined build log |

Final Public Beta sign-off should not rely on `Skipped` Revit versions. Skips are acceptable only for developer-local prechecks and must be documented as incomplete validation.

## AI Tool Validation Matrix

| Tool | Validation Scope | Commands | Expected Result | Evidence |
| --- | --- | --- | --- | --- |
| Codex | Static adapter, `.codex/config.toml`, canonical `.agents/skills` usage | `./scripts/setup-ai-tools.ps1 -Tools Codex -ValidateAdapters`; `./scripts/validate-toml.ps1 -VerboseReport` | Codex files exist, config smoke validation passes, README points to canonical skills | Command logs, `.codex/README.md`, `.codex/config.toml` |
| Claude Code | `.claude/skills` mirror and selected `.claude/agents` references | `./scripts/setup-ai-tools.ps1 -Tools Claude -Mode Copy -Force -Validate -ValidateAdapters` | Mirrors refresh from `.agents/skills`; agents reference canonical skills | Command logs, generated markers |
| Cursor | `.cursor/skills` mirror, selected `.cursor/agents`, and rules | `./scripts/setup-ai-tools.ps1 -Tools Cursor -Mode Copy -Force -Validate -ValidateAdapters` | Mirrors refresh from `.agents/skills`; agents/rules reference canonical workflows | Command logs, generated markers |
| GitHub Copilot | `.github/copilot-instructions.md` and prompt files | `./scripts/setup-ai-tools.ps1 -Tools Copilot -ValidateAdapters`; `./scripts/validate-ai-adapters.ps1 -Tools Copilot -FailOnWarnings` | Required prompts exist and reference canonical guidance | Command logs, prompt file list |
| Multi-tool setup | Combined static adapters and mirrors | `./scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Force -Validate -ValidateAdapters`; `./scripts/validate-ai-adapters.ps1 -Tools All -FailOnWarnings` | All supported tool surfaces validate without drift | Full setup log |

Symlink mode is not required for Public Beta unless it is advertised. If symlink mode is included in beta documentation, it must be tested separately with Windows symlink privileges enabled.

## Template Validation Matrix

| Template Surface | Scope | Commands | Public Beta Expectation | Evidence |
| --- | --- | --- | --- | --- |
| `dotnet new` | Template JSON, option recording, sample generation matrix | `./scripts/pack-dotnet-template.ps1 -TestMatrix` | Samples are generated for `none`, `codex`, `claude`, `cursor`, `copilot`, and `multi`; `docs/generated/template-options.md` records selected options | Matrix log, sample paths |
| Visual Studio solution | Root `.sln` and project inclusion | `dotnet sln ./RevitAiTemplate.sln list`; open solution in Visual Studio | All 9 expected projects are listed; solution opens; version-specific builds are documented | Solution list, screenshot or notes |
| Visual Studio ProjectGroup v1 | XML validity and documented v1/base limitation | XML parse command below; `./scripts/pack-vs-template.ps1` if artifact packaging is needed | XML validates; package is described as base v1 only; no production-ready claim | XML validation log, packaged zip path |

The Visual Studio ProjectGroup template must remain labeled as v1/base until all child project templates are complete and verified through the Visual Studio Create Project dialog.

## Accepted Beta Limitations

The following limitations are acceptable for Public Beta if they are clearly documented in release notes:

- Dotnet template options record selected values but do not fully remove every optional project, solution entry, adapter, or documentation file.
- Visual Studio ProjectGroup template is v1/base and not a complete native Visual Studio template.
- `actionlint` is non-blocking in CI, provided workflow lint status is reviewed before release.
- `.codex/config.toml` validation is subset-based and repository-focused, not a full TOML 1.0 parser.
- Symlink mode can remain optional and unadvertised if only copy mode is recommended.
- Public Beta users may need to run version-specific Revit validation on their own installed Revit versions.

## Beta Blockers

The following issues block Public Beta:

- `scripts/check.ps1` masks a failed command or exits `0` after an executed critical command fails.
- `scripts/build.ps1` reports a failed attempted build as `Passed`.
- Any final sign-off Revit version cannot be validated because .NET SDK 10.0 or the required Revit installation is missing.
- `validate-diff` allows committed, staged, unstaged, or untracked changes outside `allowedPaths`.
- `agent-locks.ps1 acquire` allows locks outside task `allowedPaths` or inside `readOnlyPaths`.
- `validate-ai-adapters.ps1 -Tools All -FailOnWarnings` fails.
- `validate-skills.ps1 -IncludeMirrors -FailOnWarnings` fails.
- Copilot prompts, Claude agents, Cursor agents, or Codex config contradict `.agents/skills` or `AGENTS.md`.
- Any skill, adapter, prompt, or MCP doc includes secrets, broad arbitrary Revit API execution, or instructions to bypass review, tests, or human confirmation.
- Public-facing documentation calls the Visual Studio native template complete or production-ready.

## Final Release Checklist

- Confirm clean working tree before validation.
- Capture `git rev-parse HEAD`.
- Capture `dotnet --list-sdks`.
- Capture Revit install status for 2024, 2025, 2026, and 2027.
- Run skill, adapter, and TOML validation.
- Run `scripts/check.ps1`.
- Run all version-specific Revit builds.
- Run `scripts/build.ps1 -RevitVersion all`.
- Run AI tool setup validation for Codex, Claude, Cursor, Copilot, and All.
- Run dotnet template test matrix.
- Validate Visual Studio solution project list.
- Validate Visual Studio ProjectGroup XML.
- Review actionlint CI output or run `actionlint` locally if available.
- Review release notes for beta wording.
- Confirm accepted beta limitations are listed.
- Confirm beta blockers are absent.

## Exact PowerShell Commands

Run from the repository root:

```powershell
git status --short
git rev-parse HEAD
dotnet --list-sdks

powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-skills.ps1 -RootPath . -IncludeMirrors -FailOnWarnings
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -RootPath . -Tools All -FailOnWarnings
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-toml.ps1 -RootPath . -VerboseReport

powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/setup-ai-tools.ps1 -RootPath . -Tools Codex -ValidateAdapters
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/setup-ai-tools.ps1 -RootPath . -Tools Claude -Mode Copy -Force -Validate -ValidateAdapters
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/setup-ai-tools.ps1 -RootPath . -Tools Cursor -Mode Copy -Force -Validate -ValidateAdapters
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/setup-ai-tools.ps1 -RootPath . -Tools Copilot -ValidateAdapters
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/setup-ai-tools.ps1 -RootPath . -Tools All -Mode Copy -Force -Validate -ValidateAdapters

powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/build.ps1 -RevitVersion 2024
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/build.ps1 -RevitVersion 2025
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/build.ps1 -RevitVersion 2026
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/build.ps1 -RevitVersion 2027
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/build.ps1 -RevitVersion all

powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/pack-dotnet-template.ps1 -TestMatrix
dotnet sln ./RevitAiTemplate.sln list

powershell -NoProfile -ExecutionPolicy Bypass -Command "[xml](Get-Content -Raw ./templates/visualstudio/RevitAiPlugin.ProjectGroup.vstemplate) | Out-Null"
powershell -NoProfile -ExecutionPolicy Bypass -Command "[xml](Get-Content -Raw ./templates/visualstudio/projects/Core/Core.vstemplate) | Out-Null"
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/pack-vs-template.ps1

git diff --check
git status --short
```

If `actionlint` is installed locally, also run:

```powershell
actionlint
```

If `actionlint` is not installed locally, record that limitation and review the non-blocking `lint-workflows` job in GitHub Actions.

## Evidence Recording

Create a validation evidence folder for each beta candidate:

```txt
docs/ai/evidence/public-beta/<yyyy-mm-dd>-<short-sha>/
```

Recommended files:

```txt
environment.md
commands.md
skills-validation.log
adapter-validation.log
toml-validation.log
setup-ai-tools.log
check.log
build-2024.log
build-2025.log
build-2026.log
build-2027.log
build-all.log
dotnet-template-matrix.log
visual-studio-solution.md
visual-studio-projectgroup.md
actionlint.md
release-decision.md
```

`environment.md` should include:

- date and time;
- machine name or runner label;
- operating system;
- PowerShell version;
- `git rev-parse HEAD`;
- `dotnet --list-sdks`;
- installed Revit versions and installation paths;
- Visual Studio version.

`commands.md` should list every command executed and its exit code.

`release-decision.md` should state one of:

- `Blocked`
- `Internal RC`
- `Public Beta`
- `Production-ready`

For this stage, the expected target is **Public Beta** only after the matrices above pass. Production-ready must remain out of scope until conditional template behavior, full Visual Studio ProjectGroup packaging, blocking workflow linting, and complete release packaging are finished.
