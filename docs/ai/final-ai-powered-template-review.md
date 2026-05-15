# Final AI-Powered Template Review

## Summary

Review date: 2026-05-15.

Review perspective: `verifier`, `pr-reviewer`, `cybersecurity-privacy-engineer`, `revit-api-senior`, and `visual-studio-template-engineer`.

Overall status: the repository now has the expected foundation for a professional AI-powered Revit add-in template: Visual Studio solution, canonical skills, tool adapters, Copilot prompts, branch/worktree orchestration scripts, dotnet and Visual Studio template bases, CI workflows, MCP security docs, and operational README guidance.

The main residual risks are not architectural direction problems. They are validation and drift-control problems:

- `scripts/check.ps1` and `scripts/build.ps1` can report command output from failed `dotnet` builds while still returning exit code `0`.
- `scripts/agent-locks.ps1 validate-diff` checks staged and unstaged tracked diffs only; it does not check untracked files or already-committed branch changes unless callers supply the right base reference and keep changes uncommitted.
- `scripts/setup-ai-tools.ps1` refreshes Claude/Cursor skill mirrors only; agent adapter files, Codex config, and Copilot prompt files can drift from `.agents/roster.json` and `.agents/skills`.
- Template parameters for selected Revit versions and AI tools are currently mostly declarative. They do not yet remove or conditionally include projects/files.
- The Visual Studio ProjectGroup template is documented as a base, not a complete installable native Visual Studio template.

## Passed Checks

- AGENTS.md remains concise and canonical: `AGENTS.md` points to `.agents/skills`, `.agents/workflows`, `docs/ai/ai-tooling-setup.md`, and `docs/security/mcp-security-policy.md` without duplicating long skill content.
- `.agents/skills` is documented as the canonical source in `.agents/README.md` and `.agents/roster.json`.
- Canonical skills exist for all planned roles in `.agents/roster.json`, including product, engineering, delivery, verification, review, and template roles.
- Claude and Cursor skill mirrors exist under `.claude/skills` and `.cursor/skills`.
- Claude and Cursor agent adapter files are lightweight and reference canonical skills instead of copying full skill content.
- Copilot prompt files exist under `.github/prompts/*.prompt.md` and reference `AGENTS.md`, `.agents/workflows`, and `.agents/skills`.
- `RevitAiTemplate.sln` exists and `dotnet sln ... list` reports the 9 expected projects.
- `templates/dotnet/RevitAiPlugin/.template.config/template.json` exists and validates as JSON.
- The dotnet template defines `AiTools`, `RevitVersions`, `CompanyName`, `ProductName`, `RootNamespace`, `VendorId`, and include flags.
- `templates/visualstudio/RevitAiPlugin.ProjectGroup.vstemplate` validates as XML, has `Type="ProjectGroup"`, and declares 9 `ProjectTemplateLink` entries.
- Visual Studio template limitations are documented in `templates/visualstudio/README.md` and `docs/ai/visual-studio-template.md`.
- Revit API guardrails appear in `AGENTS.md`, `.agents/skills/revit-api-senior/SKILL.md`, `.agents/skills/wpf-webview2-ux-ui/SKILL.md`, `.agents/workflows/validation-gates.md`, and Copilot review prompts.
- MCP write-tool controls are documented in `docs/security/mcp-security-policy.md` and `.agents/skills/ai-runtime-mcp-engineer/SKILL.md`.
- `scripts/validate-skills.ps1 -IncludeMirrors -FailOnWarnings` passed with 60 skills and no warnings.
- Secret-like value scan across `.agents`, `.claude`, `.cursor`, `.github/prompts`, `.codex`, `.mcp`, `docs/ai`, and `docs/security` found no credential-like values with a word-boundary token pattern.
- CI workflows exist for standard validation, AI config validation, and template packaging: `.github/workflows/ci.yml`, `.github/workflows/ai-config-validation.yml`, and `.github/workflows/template-pack.yml`.
- README explains Visual Studio, AI-powered development workflow, AI tool choices, Codex, Claude Code, Cursor, Copilot, template creation, MCP, and AI Gateway usage.

## Findings by Severity

### Critical

No critical findings found in this review.

### High

#### HIGH-001: Build/check scripts can mask failed dotnet builds

Paths:

- `scripts/check.ps1`
- `scripts/build.ps1`
- `.github/workflows/ci.yml`

Evidence:

- `scripts/check.ps1` invokes `dotnet test`, `dotnet build`, and `scripts/build.ps1`, but does not check `$LASTEXITCODE` after the `dotnet` commands.
- `scripts/build.ps1` invokes `dotnet build` inside the Revit-version loop, but does not check `$LASTEXITCODE`.
- Local `scripts/check.ps1` returned exit code `0` while multiple inner `dotnet` commands emitted `NETSDK1045` failures because this machine does not have .NET SDK 10.0.

Impact:

- Local validation can look successful even when builds fail.
- CI has separate explicit `dotnet test/build` steps for shared tests, AI Gateway, and MCP Server, so some failures are still caught there.
- Full Revit builds on a specialized Windows runner could still be falsely reported as successful by `scripts/build.ps1` if `dotnet build` fails after a Revit install is detected.

Recommended fix:

- After every `dotnet` invocation in `scripts/check.ps1` and `scripts/build.ps1`, throw when `$LASTEXITCODE -ne 0`.
- Make `scripts/build.ps1 -RevitVersion all` track whether each installed version passed, failed, or was skipped.
- Update CI to call version-specific Revit builds only on a self-hosted Revit runner and fail hard for installed-version build failures.

#### HIGH-002: `validate-diff` does not fully enforce path ownership

Path:

- `scripts/agent-locks.ps1`

Evidence:

- `validate-diff` checks `git diff --name-only` and `git diff --cached --name-only`.
- It does not inspect untracked files.
- It does not inspect committed changes on the task branch unless the caller supplies and uses a meaningful `-BaseRef`.
- The default examples in `docs/ai/agent-orchestration.md` call `validate-diff` without `-BaseRef`.

Impact:

- An agent can create an untracked file outside `allowedPaths` and still pass validation.
- An agent can commit files outside `allowedPaths`; a later `validate-diff` with no base ref can miss them.
- This weakens the stated goal of preventing concurrent or out-of-scope edits.

Recommended fix:

- Include untracked files with `git ls-files --others --exclude-standard`.
- Require `-BaseRef` for branch/worktree validation or derive the task branch base from state.
- Compare committed branch changes with `git diff --name-only <base>...HEAD`.
- Document the required base-ref workflow in `.agents/workflows/branch-isolation.md` and `docs/ai/agent-orchestration.md`.

### Medium

#### MEDIUM-001: Setup script does not regenerate all adapters from the canonical roster

Path:

- `scripts/setup-ai-tools.ps1`
- `.claude/agents/*.md`
- `.cursor/agents/*.md`
- `.codex/config.toml`
- `.github/prompts/*.prompt.md`

Evidence:

- `scripts/setup-ai-tools.ps1` supports only `All`, `Claude`, and `Cursor`.
- It refreshes `.claude/skills` and `.cursor/skills` mirrors, but does not regenerate `.claude/agents`, `.cursor/agents`, `.codex/config.toml`, or `.github/prompts`.
- Running `setup-ai-tools.ps1 -Tools All -Mode Copy -Validate` without `-Force` skipped existing mirrors and validated successfully, but did not verify adapter parity with `.agents/roster.json`.

Impact:

- Adding or renaming a role in `.agents/roster.json` can leave Claude, Cursor, Codex, and Copilot adapter surfaces stale.
- Mirrors remain canonical copies, but tool-specific agent launch surfaces can become incomplete or contradictory over time.

Recommended fix:

- Add a non-destructive adapter validation mode that checks expected Claude/Cursor agent files, Codex profiles, and Copilot prompts against `.agents/roster.json`.
- Optionally add explicit generation commands for adapter files with generated markers and no overwrite unless `-Force`.

#### MEDIUM-002: Lock acquisition is not constrained to task `allowedPaths`

Path:

- `scripts/agent-locks.ps1`

Evidence:

- `acquire` checks path conflicts against existing locks.
- It does not verify that requested lock paths are within the task's `allowedPaths`.

Impact:

- A task can acquire a lock for a path it was not authorized to edit.
- This can block legitimate tasks or create misleading coordination state.

Recommended fix:

- During `acquire`, load the task's `allowedPaths` and reject requested lock paths outside that list.
- Keep read-only paths separate and reject locks on `readOnlyPaths`.

#### MEDIUM-003: dotnet template choices are mostly declarative

Path:

- `templates/dotnet/RevitAiPlugin/.template.config/template.json`
- `scripts/pack-dotnet-template.ps1`

Evidence:

- `AiTools`, `RevitVersions`, `IncludeMcpServer`, `IncludeAiGateway`, `IncludeWebView2`, and `IncludeInstaller` are defined as symbols.
- The template currently stages the repository content and config, but there is no conditional source mapping that removes projects/files based on those choices.

Impact:

- Users can select `--AiTools none` or a narrower Revit version set and still receive the full template surface.
- This is acceptable for the current base, but it is not yet a fully parameterized product template.

Recommended fix:

- Add `sources`, `modifiers`, or post-generation documentation that explicitly records selected options.
- Add tests that generate samples for `none`, `codex`, `claude`, `cursor`, `copilot`, and `multi`.

#### MEDIUM-004: CI validates workflow content but not GitHub Actions syntax with actionlint

Path:

- `.github/workflows/ci.yml`
- `.github/workflows/ai-config-validation.yml`
- `.github/workflows/template-pack.yml`

Evidence:

- Local `actionlint -version` failed because `actionlint` is not installed.
- The CI workflows use PowerShell structural checks and script execution, but no dedicated GitHub Actions workflow linter.

Impact:

- YAML syntax and GitHub Actions expression errors may only surface after pushing to GitHub.

Recommended fix:

- Add an optional lightweight workflow-lint job using `actionlint` if the project accepts that dependency.
- Alternatively document manual GitHub Actions validation as a release checklist item.

### Low

#### LOW-001: Visual Studio ProjectGroup template is a documented base, not an installable complete template

Path:

- `templates/visualstudio/RevitAiPlugin.ProjectGroup.vstemplate`
- `templates/visualstudio/projects/README.md`
- `templates/visualstudio/README.md`

Evidence:

- The root `.vstemplate` references planned child templates.
- The README explicitly says child project templates are intentionally not complete in this stage.

Impact:

- Users expecting a native Visual Studio Create Project experience will not get a complete ProjectGroup template yet.

Recommended fix:

- Keep README wording explicit.
- Add child project templates in a later v2 task before advertising native Visual Studio template support as complete.

#### LOW-002: Codex config syntax validation is intentionally shallow

Path:

- `.github/workflows/ai-config-validation.yml`
- `.codex/config.toml`

Evidence:

- The workflow checks `.codex/config.toml` with a simple text pattern for section headers and assignments.

Impact:

- Some invalid TOML forms could pass the basic textual check.

Recommended fix:

- Use a real TOML parser when an acceptable lightweight parser is available in the runner environment.
- Until then, keep the textual check as a smoke test only.

#### LOW-003: `scripts/setup-ai-tools.ps1 -Tools All` naming can imply more setup than it performs

Path:

- `scripts/setup-ai-tools.ps1`
- `docs/ai/ai-tooling-setup.md`

Evidence:

- `All` means Claude and Cursor skill mirrors only.
- Codex and Copilot adapters are static files and not modified by setup.

Impact:

- Users may expect `All` to configure Codex and Copilot outputs too.

Recommended fix:

- Rename documentation language to "refresh mirrors" where appropriate.
- Add `-Tools Codex` and `-Tools Copilot` validation-only branches or explicitly document why they are static.

## Recommended Follow-Up Tasks

1. Fix `scripts/check.ps1` and `scripts/build.ps1` to fail when any inner `dotnet` build/test fails.
2. Harden `scripts/agent-locks.ps1 validate-diff` to include untracked files and branch commits against a required base ref.
3. Constrain `scripts/agent-locks.ps1 acquire` to each task's `allowedPaths`.
4. Add adapter parity validation against `.agents/roster.json` for Claude agents, Cursor agents, Codex profiles, and Copilot prompts.
5. Add dotnet template conditional behavior or explicit generated documentation for selected `AiTools` and `RevitVersions`.
6. Add complete Visual Studio child project templates before presenting the Visual Studio ProjectGroup template as production-ready.
7. Add optional workflow linting with `actionlint` or a documented equivalent.

## Commands Run

```powershell
Get-ChildItem -Force -LiteralPath 'C:\Users\MayconFreitas\Documents\source\AECoder\revit-ai-powered-plugin-template'
Get-ChildItem -Recurse -File -LiteralPath 'C:\Users\MayconFreitas\Documents\source\AECoder\revit-ai-powered-plugin-template\.agents'
Get-ChildItem -Recurse -File -LiteralPath 'C:\Users\MayconFreitas\Documents\source\AECoder\revit-ai-powered-plugin-template\.github\prompts'
Get-ChildItem -Recurse -File -LiteralPath 'C:\Users\MayconFreitas\Documents\source\AECoder\revit-ai-powered-plugin-template\templates'
Get-Content -Raw -LiteralPath '...\scripts\setup-ai-tools.ps1'
Get-Content -Raw -LiteralPath '...\scripts\agent-locks.ps1'
Get-Content -Raw -LiteralPath '...\scripts\agent-worktree.ps1'
Get-Content -Raw -LiteralPath '...\scripts\agent-feature.ps1'
Get-Content -Raw -LiteralPath '...\scripts\validate-skills.ps1'
Get-Content -Raw -LiteralPath '...\.agents\README.md'
Get-Content -Raw -LiteralPath '...\AGENTS.md'
Get-Content -Raw -LiteralPath '...\.agents\roster.json'
Get-Content -Raw -LiteralPath '...\.claude\agents\revit-api-senior.md'
Get-Content -Raw -LiteralPath '...\.cursor\agents\verifier.md'
Get-Content -Raw -LiteralPath '...\.github\prompts\revit-api-review.prompt.md'
Get-Content -Raw -LiteralPath '...\.cursor\rules\agent-team.mdc'
Get-Content -Raw -LiteralPath '...\templates\dotnet\RevitAiPlugin\.template.config\template.json'
Get-Content -Raw -LiteralPath '...\templates\visualstudio\RevitAiPlugin.ProjectGroup.vstemplate'
Get-Content -Raw -LiteralPath '...\templates\visualstudio\README.md'
Get-Content -Raw -LiteralPath '...\scripts\pack-dotnet-template.ps1'
Get-Content -Raw -LiteralPath '...\RevitAiTemplate.sln'
Get-Content -Raw -LiteralPath '...\.github\workflows\ci.yml'
Get-Content -Raw -LiteralPath '...\.github\workflows\ai-config-validation.yml'
Get-Content -Raw -LiteralPath '...\.github\workflows\template-pack.yml'
Get-Content -Raw -LiteralPath '...\docs\security\mcp-security-policy.md'
Get-Content -Raw -LiteralPath '...\.agents\skills\ai-runtime-mcp-engineer\SKILL.md'
Get-Content -Raw -LiteralPath '...\.agents\skills\revit-api-senior\SKILL.md'
Get-Content -Raw -LiteralPath '...\.agents\skills\cybersecurity-privacy-engineer\SKILL.md'
powershell -NoProfile -ExecutionPolicy Bypass -File '...\scripts\validate-skills.ps1' -RootPath '...' -IncludeMirrors
powershell -NoProfile -ExecutionPolicy Bypass -File '...\scripts\setup-ai-tools.ps1' -RootPath '...' -Tools All -Mode Copy -Validate
dotnet sln '...\RevitAiTemplate.sln' list
powershell -NoProfile -ExecutionPolicy Bypass -File '...\scripts\validate-skills.ps1' -RootPath '...' -IncludeMirrors -FailOnWarnings
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Content -Raw -LiteralPath '...\templates\dotnet\RevitAiPlugin\.template.config\template.json' | ConvertFrom-Json | Out-Null"
powershell XML validation for '...\templates\visualstudio\RevitAiPlugin.ProjectGroup.vstemplate'
powershell -NoProfile -ExecutionPolicy Bypass -File '...\scripts\check.ps1'
dotnet --list-sdks
rg secret-like value scan across .agents, .claude, .cursor, .github/prompts, .codex, .mcp, docs/ai, docs/security
rg guardrail scan for allowedPaths, validate-diff, ExternalEvent, Transaction, human confirmation, and arbitrary Revit API
git status --short
```

Command outcomes:

- `validate-skills.ps1 -IncludeMirrors`: passed, 60 skills.
- `validate-skills.ps1 -IncludeMirrors -FailOnWarnings`: passed, 60 skills, no warnings.
- `setup-ai-tools.ps1 -Tools All -Mode Copy -Validate`: passed; skipped existing mirrors without `-Force`, then validated.
- `dotnet sln ... list`: passed and listed the 9 expected projects.
- Dotnet template JSON validation: passed.
- Visual Studio `.vstemplate` XML validation: passed with 9 project links.
- Secret-like value scan: passed with no credential-like values after using word-boundary matching.
- `scripts/check.ps1`: returned exit code `0`, but inner `dotnet` commands emitted `NETSDK1045` because the local machine has SDKs `8.0.204` and `9.0.300`, not .NET SDK 10.0.
- `dotnet --list-sdks`: reported `8.0.204` and `9.0.300`.
- `git status --short`: clean before creating this review document.

## Commands Not Run and Why

- `actionlint`: not run successfully because `actionlint` is not installed on this machine.
- Full Revit builds for 2024, 2025, 2026, and 2027: not validated successfully because the local environment lacks .NET SDK 10.0, and Revit 2026/2027 install folders are not present.
- `scripts/pack-dotnet-template.ps1 -Force -Install -Test`: not run in this review because it writes under `artifacts/`, installs a local dotnet template, and generates a sample project. The template JSON and pack script were reviewed instead.
- `scripts/pack-vs-template.ps1 -Force`: not run in this review because it rewrites template artifacts. The `.vstemplate` XML and documentation were validated instead.
- Real branch/worktree orchestration with `.agents/state/<feature-id>`: not run because this review is read-only except for the review document and should not create operational state, branches, or worktrees.
