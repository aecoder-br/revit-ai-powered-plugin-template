# AI Tooling Setup

## Canonical Model

`.agents/skills` is the source of truth for repository skills. Tool-specific folders are adapters or mirrors.

| Tool | Files |
| --- | --- |
| Codex | `.codex/config.toml`, `.agents/skills`, `.agents/workflows` |
| Claude Code | `CLAUDE.md`, `.claude/agents`, `.claude/skills` |
| Cursor | `.cursor/agents`, `.cursor/rules`, `.cursor/skills` |
| GitHub Copilot | `.github/copilot-instructions.md`, `.github/prompts` |

## Choosing AI Tools

Use the `AiTools` template option to record the intended tooling:

| Value | Meaning |
| --- | --- |
| `none` | No AI adapter setup. |
| `codex` | Codex configuration and canonical skills. |
| `claude` | Claude Code agents and skill mirrors. |
| `cursor` | Cursor agents, rules, and skill mirrors. |
| `copilot` | GitHub Copilot instructions and prompts. |
| `multi` | All supported adapters. |

## Setup Commands

Refresh Claude and Cursor mirrors from `.agents/skills`:

```powershell
./scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate
```

Single-tool mirror refresh:

```powershell
./scripts/setup-ai-tools.ps1 -Tools Claude -Mode Copy -Validate
./scripts/setup-ai-tools.ps1 -Tools Cursor -Mode Copy -Validate
```

Validate skills and mirrors:

```powershell
./scripts/validate-skills.ps1 -IncludeMirrors
```

## Codex

Use `AGENTS.md`, `.agents/skills`, `.agents/workflows`, and `.codex/config.toml`.

Keep sandboxing and approvals conservative. Require confirmation before destructive commands, deleting worktrees, mutating Git history, installing dependencies, or running MCP write tools.

## Claude Code

Use `CLAUDE.md` and `.claude/agents` for subagent routing.

Do not edit `.claude/skills` as source content. Update `.agents/skills` and run setup again.

## Cursor

Use `.cursor/rules/project.mdc`, `.cursor/rules/agent-team.mdc`, and `.cursor/agents`.

Do not edit `.cursor/skills` as source content. Update `.agents/skills` and run setup again.

## GitHub Copilot

Use `.github/copilot-instructions.md` and the prompt files in `.github/prompts`.

Prompts are intentionally short and point back to `AGENTS.md`, `.agents/workflows`, and skill docs.

## MCP Safety

Before adding or changing MCP tools, read `../security/mcp-security-policy.md`.

Read tools may support research and documentation. Write tools require human confirmation, named Revit `Transaction`, audit logging, rollback planning, and `ExternalEvent` routing.
