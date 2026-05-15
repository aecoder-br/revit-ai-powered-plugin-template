# Agent skills implementation plan

## Scope

This plan covers the implementation work needed to turn this repository into a Visual Studio and AI-agent-ready Revit add-in template. It is intentionally a plan only; no production code, namespaces, project files, solution files, templates, scripts, or agent adapters are implemented here.

The current repository is already structured as a professional multi-version Revit template with:

- canonical agent instructions in `AGENTS.md`;
- Claude guidance in `CLAUDE.md`;
- Cursor rules in `.cursor/rules`;
- GitHub Copilot instructions in `.github/copilot-instructions.md` and `.github/instructions`;
- MCP examples in `.mcp`;
- architecture, ADR, AI, security, testing, and domain docs under `docs`;
- PowerShell validation/build scripts under `scripts`;
- layered source projects under `src`;
- application tests under `tests`.

## Current repository findings

There is no checked-in Visual Studio solution or `.slnx` file. Visual Studio state exists only under `.vs`, which should remain ignored/local and must not become part of the template.

The current project graph is:

| Project | Current role | Revit API allowed |
|---|---|---:|
| `src/RevitAiTemplate.Core` | Domain, DTOs, ports | No |
| `src/RevitAiTemplate.Application` | Use cases and orchestration | No |
| `src/RevitAiTemplate.Infrastructure` | AI Gateway client, logging, configuration | No |
| `src/RevitAiTemplate.Ui.Wpf` | WPF/MVVM UI | No |
| `src/RevitAiTemplate.RevitBridge` | Bridge DTOs/contracts between MCP and Revit | No |
| `src/RevitAiTemplate.Mcp.Server` | Local MCP server via stdio | No direct Revit API |
| `src/RevitAiTemplate.AiGateway` | Provider abstraction and policy boundary | No |
| `src/RevitAiTemplate.Revit` | Revit host, commands, adapters, ExternalEvent queue | Yes |
| `tests/RevitAiTemplate.Application.Tests` | Shared application tests | No |

The multi-version build is centralized in `Directory.Build.props`:

| Revit | Target framework | Symbols |
|---|---|---|
| 2024 | `net48` | `REVIT2024;REVIT_NET48` |
| 2025 | `net8.0-windows` | `REVIT2025;REVIT_NET8` |
| 2026 | `net8.0-windows` | `REVIT2026;REVIT_NET8` |
| 2027 | `net10.0-windows` | `REVIT2027;REVIT_NET10` |

The existing validation entry points are:

```powershell
./scripts/check.ps1
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027
```

`scripts/check.ps1` currently runs application tests, builds the AI Gateway, builds the MCP Server, and delegates installed Revit builds to `scripts/build.ps1 -RevitVersion all`.

`scripts/build.ps1` builds `src/RevitAiTemplate.Revit/RevitAiTemplate.Revit.csproj` with the selected `RevitVersion` and skips versions whose Revit install folder is missing.

## Implementation goals

1. Add a checked-in Visual Studio solution that opens the whole template without relying on `.vs`.
2. Add a canonical `.agents/skills` layer for reusable agent workflows.
3. Add thin adapters for Codex, Claude Code, Cursor, and GitHub Copilot that point back to the canonical skills and `AGENTS.md`.
4. Add Windows/PowerShell setup scripts for supported AI tools.
5. Add an agent orchestration system that prevents concurrent agents from editing the same files or branches.
6. Add `dotnet new` template support.
7. Add Visual Studio multi-project template support.

## Folder structure to create

```txt
.agents/
  README.md
  skills/
    revit-template-architect/
      SKILL.md
      agents/
        openai.yaml
      references/
        architecture-map.md
        revit-version-matrix.md
    revit-api-boundary-reviewer/
      SKILL.md
      agents/
        openai.yaml
      references/
        boundary-checklist.md
    revit-mcp-tool-designer/
      SKILL.md
      agents/
        openai.yaml
      references/
        mcp-tool-contracts.md
    revit-ai-runtime-reviewer/
      SKILL.md
      agents/
        openai.yaml
      references/
        ai-gateway-policy.md
    revit-template-packager/
      SKILL.md
      agents/
        openai.yaml
      references/
        dotnet-template-rules.md
        visual-studio-template-rules.md
    revit-test-build-validator/
      SKILL.md
      agents/
        openai.yaml
      references/
        validation-commands.md
    agent-orchestrator/
      SKILL.md
      agents/
        openai.yaml
      references/
        ownership-model.md
        branch-worktree-model.md

.agents/adapters/
  codex/
    README.md
    skills-map.md
  claude/
    README.md
    skills-map.md
  cursor/
    README.md
    skills-map.md
  copilot/
    README.md
    skills-map.md

.agents/orchestration/
  README.md
  tasks/
    README.md
  locks/
    .gitkeep
  manifests/
    .gitkeep
  worktrees/
    README.md

.template.config/
  template.json
  dotnetcli.host.json
  ide.host.json

templates/
  visual-studio/
    RevitAiTemplate.vstemplate
    RevitAiTemplate.Core.vstemplate
    RevitAiTemplate.Application.vstemplate
    RevitAiTemplate.Infrastructure.vstemplate
    RevitAiTemplate.Ui.Wpf.vstemplate
    RevitAiTemplate.RevitBridge.vstemplate
    RevitAiTemplate.Mcp.Server.vstemplate
    RevitAiTemplate.AiGateway.vstemplate
    RevitAiTemplate.Revit.vstemplate
    RevitAiTemplate.Application.Tests.vstemplate
    RevitAiTemplate.root.vstemplate

scripts/
  ai/
    setup-ai-tools.ps1
    setup-codex.ps1
    setup-claude.ps1
    setup-cursor.ps1
    setup-copilot.ps1
    validate-agent-skills.ps1
    new-agent-task.ps1
    start-agent-worktree.ps1
    complete-agent-task.ps1
    test-template-pack.ps1

RevitAiTemplate.sln
```

The exact `.vstemplate` layout may be adjusted during implementation after validating Visual Studio import behavior, but it should stay under `templates/visual-studio` and should not duplicate source files unnecessarily.

## Visual Studio solution plan

Add `RevitAiTemplate.sln` at the repository root with the current projects grouped by solution folders:

- `src`
  - `RevitAiTemplate.Core`
  - `RevitAiTemplate.Application`
  - `RevitAiTemplate.Infrastructure`
  - `RevitAiTemplate.Ui.Wpf`
  - `RevitAiTemplate.RevitBridge`
  - `RevitAiTemplate.Mcp.Server`
  - `RevitAiTemplate.AiGateway`
  - `RevitAiTemplate.Revit`
- `tests`
  - `RevitAiTemplate.Application.Tests`
- `docs`
  - documentation files as solution items
- `scripts`
  - PowerShell scripts as solution items

The solution must not replace the existing script-based build path. `scripts/build.ps1` remains the source of truth for Revit-version builds because it selects installed Revit versions and passes `-p:RevitVersion=...`.

Implementation should create the solution using `dotnet new sln` and `dotnet sln add` where possible, then manually add solution folders only if needed. Before committing, verify that the solution does not include `.vs` state.

## Canonical Agent Skills

Skills should be repository-local and specific to this template. Each skill should be concise, instruction-first, and should load detailed references only when needed.

Required skills:

| Skill | Purpose |
|---|---|
| `revit-template-architect` | Plan architecture changes across `Core`, `Application`, `Infrastructure`, `Ui.Wpf`, `RevitBridge`, `Mcp.Server`, `AiGateway`, and `Revit`. |
| `revit-api-boundary-reviewer` | Review whether Revit API usage is limited to `src/RevitAiTemplate.Revit` and whether DTOs cross boundaries. |
| `revit-mcp-tool-designer` | Design deterministic read/write MCP tools, confirmation requirements, audit logging, and ExternalEvent routing. |
| `revit-ai-runtime-reviewer` | Review AI Gateway usage, provider isolation, data minimization, redaction, secrets, and audit posture. |
| `revit-template-packager` | Guide `dotnet new` and Visual Studio multi-project template packaging without breaking source layout. |
| `revit-test-build-validator` | Select and run validation commands, including `scripts/check.ps1` and versioned `scripts/build.ps1`. |
| `agent-orchestrator` | Coordinate multi-agent work with branch/worktree isolation, file ownership, locks, and merge order. |

Each skill should include:

- `SKILL.md` with YAML frontmatter containing only `name` and `description`;
- `agents/openai.yaml` for Codex UI metadata;
- small `references/*.md` files for checklists and repo-specific maps;
- no extra README inside individual skill folders unless a tool strictly requires it.

## Tool adapter plan

### Codex

Add `.agents/adapters/codex/skills-map.md` that maps task types to `.agents/skills/<skill-name>`.

Recommended behavior:

- keep `AGENTS.md` as the canonical repository contract;
- prefer explicit skill invocation for high-impact flows;
- use `revit-api-boundary-reviewer` before code touching `src/RevitAiTemplate.Revit`;
- use `agent-orchestrator` before parallel work;
- document validation in final responses with the exact command run or why it could not run.

Optional Codex metadata should live under each skill's `agents/openai.yaml`, not duplicated in global docs.

### Claude Code

Update `CLAUDE.md` in a later implementation step to reference `.agents/adapters/claude/skills-map.md`.

Recommended behavior:

- keep `AGENTS.md` canonical;
- tell Claude to load the relevant skill map before changing architecture, MCP, runtime AI, Revit API adapters, templates, or build scripts;
- keep Claude-specific instructions thin to avoid drift from `.agents/skills`;
- route MCP or background Revit interactions through the documented ExternalEvent path.

### Cursor

Add Cursor-facing pointers in `.cursor/rules` only after the canonical skills exist.

Recommended behavior:

- keep `alwaysApply` rules small and canonical;
- add targeted rules for `.agents/skills/**/*.md`, `templates/**/*.vstemplate`, `.template.config/**/*.json`, and `scripts/ai/**/*.ps1`;
- point Cursor to `.agents/adapters/cursor/skills-map.md` instead of duplicating long skill bodies.

### GitHub Copilot

Extend `.github/copilot-instructions.md` and `.github/instructions/*.instructions.md` only after the canonical skills exist.

Recommended behavior:

- keep Copilot instructions as routing guidance;
- avoid embedding full skill content;
- add `applyTo` scoped instruction files for template packaging, agent skills, and orchestration scripts;
- preserve the current rule that Revit API changes stay in `src/RevitAiTemplate.Revit`.

## Scripts required

All scripts should be PowerShell-first and Windows-compatible.

| Script | Purpose |
|---|---|
| `scripts/ai/setup-ai-tools.ps1` | Top-level setup entry point for AI tool adapters. Should call tool-specific setup scripts with explicit switches. |
| `scripts/ai/setup-codex.ps1` | Validate `.agents/skills`, Codex metadata, and local adapter docs. Should not write global Codex config by default. |
| `scripts/ai/setup-claude.ps1` | Validate `CLAUDE.md`, Claude skill map, and MCP examples. Should not overwrite user machine Claude config without confirmation. |
| `scripts/ai/setup-cursor.ps1` | Validate `.cursor/rules` and Cursor MCP example config. |
| `scripts/ai/setup-copilot.ps1` | Validate `.github/copilot-instructions.md` and `.github/instructions`. |
| `scripts/ai/validate-agent-skills.ps1` | Validate every `.agents/skills/*/SKILL.md` and required metadata/reference files. |
| `scripts/ai/new-agent-task.ps1` | Create an orchestration task manifest with owner, scope, files, branch name, and validation plan. |
| `scripts/ai/start-agent-worktree.ps1` | Create a branch/worktree for a task and check for file ownership conflicts before work starts. |
| `scripts/ai/complete-agent-task.ps1` | Run requested validation, summarize changed files, release locks, and record task completion. |
| `scripts/ai/test-template-pack.ps1` | Pack/install/test the `dotnet new` template and verify generated output builds where possible. |

Existing scripts must remain authoritative for build validation:

```powershell
./scripts/check.ps1
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027
```

The new scripts should call these commands instead of duplicating build logic.

## Agent orchestration and concurrency model

Concurrent agents should never edit the same ownership area without an explicit handoff.

Recommended model:

1. Every unit of parallel work starts with a task manifest in `.agents/orchestration/tasks/<task-id>.json`.
2. The manifest declares:
   - task id;
   - branch name;
   - worktree path;
   - owner agent/tool;
   - file or folder ownership scope;
   - forbidden files;
   - validation commands;
   - merge dependencies.
3. `scripts/ai/start-agent-worktree.ps1` checks existing active manifests before creating a branch/worktree.
4. If scopes overlap, the script blocks by default and requires a human-approved handoff.
5. Each agent works on a branch named from the task, for example `agent/<task-id>-<short-topic>`.
6. Each agent writes only inside its declared scope.
7. Completion requires `scripts/ai/complete-agent-task.ps1`, which records validation status and releases the manifest lock.
8. Integration happens in a separate merge task, not inside worker branches.

Suggested ownership scopes:

| Scope | Owner examples | Notes |
|---|---|---|
| `.agents/skills/<skill>` | Skill author | One skill per task to avoid overlapping edits. |
| `.agents/adapters/<tool>` | Tool adapter author | Tool-specific docs only. |
| `scripts/ai/*.ps1` | Tooling author | Avoid concurrent edits to shared helper functions. |
| `.template.config` and `templates/visual-studio` | Template packaging author | Keep template packing in one branch. |
| `src/RevitAiTemplate.Revit` | Revit adapter author | Requires Revit API boundary review. |
| non-Revit projects under `src` | Application/domain authors | Must not introduce `Autodesk.Revit.*`. |

The orchestration system should avoid hidden global state. Manifest and lock files should be plain JSON or Markdown so they can be reviewed in PRs when appropriate. Long-lived local worktree folders should remain ignored if they are generated under the repo.

## dotnet new template plan

Add `.template.config/template.json` for a multi-project template.

Template parameters should include:

- `ProjectName`;
- `RootNamespace`;
- `Company`;
- `Authors`;
- `VendorId`;
- `AddinName`;
- `DefaultRevitVersion`;
- optional `IncludeMcp`;
- optional `IncludeAiGateway`;
- optional `IncludeWpf`;
- optional `IncludeAgentSkills`.

The template must rename source namespaces only in generated output. It must not rename namespaces in this repository during implementation.

Validation should use `scripts/ai/test-template-pack.ps1` to:

1. run `dotnet new install` from a local package/folder;
2. generate a project into a temporary directory;
3. run `dotnet restore`;
4. run shared tests when generated;
5. run versioned Revit builds only for installed Revit versions;
6. uninstall the local template.

The template must preserve:

- separate Revit-version binaries;
- `REVIT2024`, `REVIT2025`, `REVIT2026`, `REVIT2027` constants;
- no Revit API reference outside the generated Revit project;
- AI Gateway as the runtime LLM boundary.

## Visual Studio multi-project template plan

Visual Studio template support should be added separately from `dotnet new` support because `.vstemplate` has different behavior and packaging constraints.

Recommended structure:

- a root multi-project `.vstemplate`;
- one project template descriptor per project;
- template parameters aligned with `.template.config/template.json`;
- no duplicated source code unless Visual Studio requires a packaging copy step;
- a script-generated zip artifact rather than a committed binary zip.

The Visual Studio template should generate the same layered architecture as the repository:

- Core;
- Application;
- Infrastructure;
- Ui.Wpf;
- RevitBridge;
- Mcp.Server;
- AiGateway;
- Revit;
- Application.Tests.

Revit version compatibility must remain controlled by generated `Directory.Build.props`, not by per-project one-off target framework edits.

## Risks and mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Revit API leaks into non-Revit projects | Runtime crashes, invalid contexts, untestable code | Add boundary checks in `revit-api-boundary-reviewer` and validation scripts using source scans. |
| Visual Studio solution gives false confidence for Revit builds | Developers build default `RevitVersion` only | Keep `scripts/build.ps1` and versioned commands documented as authoritative. |
| Agents edit overlapping files in parallel | Conflicts, lost work, inconsistent docs | Require manifests, branch/worktree isolation, ownership scopes, and explicit handoff. |
| Tool adapters drift from canonical skills | Conflicting instructions across Codex, Claude, Cursor, Copilot | Keep adapters as thin maps that reference `.agents/skills` and `AGENTS.md`. |
| Setup scripts overwrite user global AI configs | User machine breakage | Default to validation and example generation; require explicit `-Apply` or `-Confirm` for writes outside the repo. |
| `dotnet new` token replacement breaks source files | Broken generated namespaces or project references | Use a temp generation test and compare expected project graph before accepting changes. |
| Visual Studio template packaging duplicates stale source | Template output diverges from repo | Prefer generation from current source and validate generated output. |
| Revit 2024/net48 and Revit 2027/net10 differences get flattened | Version-specific build failures | Keep `Directory.Build.props` version matrix and conditional constants intact. |
| AI runtime guidance mixes with code-assistant guidance | Security and architecture confusion | Keep runtime AI docs under architecture/security and agent workflow docs under `.agents`/`docs/ai`. |
| MCP write tools are added too broadly | Unsafe model mutation | Keep write tools disabled by default, require confirmation, audit logging, named transactions, and rollback. |

## Recommended implementation sequence

1. Add `RevitAiTemplate.sln` with existing projects and solution folders.
2. Add `.agents/README.md` and the canonical `.agents/skills` folder structure.
3. Implement the first two skills only:
   - `revit-template-architect`;
   - `revit-api-boundary-reviewer`.
4. Add `scripts/ai/validate-agent-skills.ps1` and validate the first skills.
5. Add remaining skills one at a time, validating after each:
   - `revit-mcp-tool-designer`;
   - `revit-ai-runtime-reviewer`;
   - `revit-template-packager`;
   - `revit-test-build-validator`;
   - `agent-orchestrator`.
6. Add adapter docs for Codex, Claude Code, Cursor, and GitHub Copilot as thin routing layers.
7. Update existing tool instruction files to point to the adapter docs without duplicating canonical skill content.
8. Add orchestration manifests and scripts:
   - `new-agent-task.ps1`;
   - `start-agent-worktree.ps1`;
   - `complete-agent-task.ps1`.
9. Add `dotnet new` template metadata under `.template.config`.
10. Add `scripts/ai/test-template-pack.ps1` and validate generated output in a temp directory.
11. Add Visual Studio multi-project template descriptors under `templates/visual-studio`.
12. Add packaging validation for Visual Studio template zip generation.
13. Run final validation:

```powershell
./scripts/check.ps1
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027
```

If a Revit version is not installed, record the skipped version exactly as `scripts/build.ps1` reports it.

## Acceptance criteria for the future implementation

- `RevitAiTemplate.sln` exists and opens all current projects.
- `.agents/skills` contains the required canonical skills.
- Codex, Claude Code, Cursor, and GitHub Copilot adapters reference canonical skills instead of duplicating instructions.
- AI setup scripts are PowerShell-compatible and do not overwrite user global config by default.
- Agent orchestration blocks overlapping ownership scopes unless explicitly handed off.
- `dotnet new` generates a working copy with replaced project identity values.
- Visual Studio multi-project template generates the same project graph as `dotnet new`.
- Existing architecture boundaries remain intact.
- Existing validation commands continue to be the source of truth.
