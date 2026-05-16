# Public Beta Validation Record

## 1. Date

- Validation date:
- Start time:
- End time:
- Time zone:

## 2. Machine And Environment

- Machine name or runner label:
- Operating system:
- PowerShell version:
- Git version:
- User context:
- Notes:

## 3. Installed .NET SDKs

Paste `dotnet --list-sdks` output:

```txt
<paste output here>
```

Required interpretation:

| Requirement | Status | Evidence |
| --- | --- | --- |
| .NET SDK 8 | Pending | |
| .NET SDK 10 | Pending | |
| .NET Framework 4.8 Developer Pack | Pending | |

## 4. Installed Revit Versions

| Revit Version | Installed | Install Path | RevitAPI.dll | RevitAPIUI.dll | Notes |
| --- | --- | --- | --- | --- | --- |
| 2024 | Pending | | Pending | Pending | |
| 2025 | Pending | | Pending | Pending | |
| 2026 | Pending | | Pending | Pending | |
| 2027 | Pending | | Pending | Pending | |

## 5. Visual Studio Version

- Visual Studio version:
- Detection method:
- Workloads/components confirmed:
- Notes:

## 6. Commit Hash

```txt
<git rev-parse HEAD>
```

## 7. Commands Executed

| Command | Exit Code | Result | Log/Evidence |
| --- | ---: | --- | --- |
| `git status --short` | Pending | Pending | |
| `dotnet --list-sdks` | Pending | Pending | |
| `./scripts/validate-environment.ps1 -RequireFull` | Pending | Pending | |
| `./scripts/validate-skills.ps1 -RootPath . -IncludeMirrors -FailOnWarnings` | Pending | Pending | |
| `./scripts/validate-ai-adapters.ps1 -RootPath . -Tools All -FailOnWarnings` | Pending | Pending | |
| `./scripts/validate-toml.ps1 -RootPath . -VerboseReport` | Pending | Pending | |
| `./scripts/check.ps1` | Pending | Pending | |
| `./scripts/build.ps1 -RevitVersion all` | Pending | Pending | |

## 8. Results By Command

Summarize each command result here. Include exact failure messages, skipped checks, and remediation status.

```txt
<summary>
```

## 9. Revit Version Builds

| Revit Version | Command | Status | Exit Code | Key Evidence | Blocker |
| --- | --- | --- | ---: | --- | --- |
| 2024 | `./scripts/build.ps1 -RevitVersion 2024` | Pending | | | |
| 2025 | `./scripts/build.ps1 -RevitVersion 2025` | Pending | | | |
| 2026 | `./scripts/build.ps1 -RevitVersion 2026` | Pending | | | |
| 2027 | `./scripts/build.ps1 -RevitVersion 2027` | Pending | | | |
| all | `./scripts/build.ps1 -RevitVersion all` | Pending | | | |

## 10. Dotnet Template Tests

| Test | Command | Status | Evidence |
| --- | --- | --- | --- |
| Template JSON parses | `Get-Content -Raw ./templates/dotnet/RevitAiPlugin/.template.config/template.json \| ConvertFrom-Json \| Out-Null` | Pending | |
| Test matrix | `./scripts/pack-dotnet-template.ps1 -TestMatrix` | Pending | |
| Generated option record | Inspect generated `docs/generated/template-options.md` in samples | Pending | |

## 11. Visual Studio Solution Tests

| Test | Status | Evidence |
| --- | --- | --- |
| `dotnet sln ./RevitAiTemplate.sln list` lists expected projects | Pending | |
| Solution opens in Visual Studio | Pending | |
| Shared/test projects build from Visual Studio or CLI | Pending | |
| Version-specific Revit builds use scripts, not a single universal binary | Pending | |

## 12. AI Tooling Setup Tests

| Tool | Command | Status | Evidence |
| --- | --- | --- | --- |
| Codex | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools Codex -ValidateAdapters` | Pending | |
| Claude Code | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools Claude -Mode Copy -Force -Validate -ValidateAdapters` | Pending | |
| Cursor | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools Cursor -Mode Copy -Force -Validate -ValidateAdapters` | Pending | |
| GitHub Copilot | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools Copilot -ValidateAdapters` | Pending | |
| Multi-tool setup | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools All -Mode Copy -Force -Validate -ValidateAdapters` | Pending | |

## 13. Branch And Worktree Orchestration Tests

| Test | Command/Method | Status | Evidence |
| --- | --- | --- | --- |
| Feature state creation | `./scripts/agent-feature.ps1 -Command new ...` | Pending | |
| Task creation with allowed paths | `./scripts/agent-feature.ps1 -Command add-task ...` | Pending | |
| Lock acquisition inside allowed paths | `./scripts/agent-locks.ps1 -Command acquire ...` | Pending | |
| Lock rejection outside allowed paths | Manual negative test | Pending | |
| Worktree creation | `./scripts/agent-worktree.ps1 -Command create ...` | Pending | |
| Diff validation with `-BaseRef` | `./scripts/agent-locks.ps1 -Command validate-diff ... -BaseRef main` | Pending | |

Record cleanup steps for any temporary branches, worktrees, and `.agents/state` test data.

## 14. MCP Docs And Config Tests

| Test | Status | Evidence |
| --- | --- | --- |
| `docs/security/mcp-security-policy.md` reviewed | Pending | |
| `docs/architecture/mcp-strategy.md` reviewed | Pending | |
| `docs/ai/mcp-development-workflow.md` reviewed | Pending | |
| `.mcp` examples reviewed for secrets | Pending | |
| Read tools remain separated from write tools | Pending | |
| Write tools require confirmation, audit logging, and named Revit `Transaction` | Pending | |

## 15. Failures Found

| ID | Severity | Area | Description | Evidence | Status |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

## 16. Workarounds

| Failure ID | Workaround | Accepted For Beta | Owner | Follow-up |
| --- | --- | --- | --- | --- |
| | | | | |

## 17. Final Decision

Choose exactly one:

- [ ] `fail`
- [ ] `internal rc`
- [ ] `public beta ready`
- [ ] `production ready candidate`

Decision rationale:

```txt
<rationale>
```

Approver:

```txt
<name / role>
```
