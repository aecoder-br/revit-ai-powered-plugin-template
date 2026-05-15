# AI Tooling Index

Use this folder to understand how AI tools, repository skills, MCP policy, and template creation fit together.

## Start Here

- `ai-tooling-setup.md`: configure Codex, Claude Code, Cursor, and GitHub Copilot.
- `team-skills.md`: understand the canonical skill roster and mirrors.
- `feature-lifecycle.md`: use the feature lifecycle workflow without duplicating `.agents` content.
- `agent-orchestration.md`: operate feature/task/lock/worktree scripts.
- `mcp-development-workflow.md`: design safe MCP tools.
- `visual-studio-template.md`: understand dotnet and Visual Studio template phases.

## Canonical Sources

- `../../AGENTS.md`: repository safety and architecture contract.
- `../../.agents/roster.json`: agent role roster.
- `../../.agents/skills`: canonical skills.
- `../../.agents/workflows`: canonical multi-agent workflows.
- `../../docs/security/mcp-security-policy.md`: MCP security policy.

## Validation

Run:

```powershell
./scripts/validate-skills.ps1 -IncludeMirrors
./scripts/check.ps1
```

If the .NET 10 SDK or local Revit installations are missing, document the exact validation gap.
