# Adapter Parity Validation

This repository keeps `.agents/skills` and `.agents/roster.json` as the canonical agent layer.

Tool-specific files are adapters or mirrors:

- Codex: `.codex/config.toml` and `.codex/README.md`
- Claude Code: `.claude/agents` and `.claude/skills`
- Cursor: `.cursor/agents`, `.cursor/rules`, and `.cursor/skills`
- GitHub Copilot: `.github/copilot-instructions.md` and `.github/prompts`

Use `scripts/validate-ai-adapters.ps1` to detect drift between the canonical roster and the tool-specific adapter surfaces.

## Commands

Validate all adapters:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -Tools All
```

Fail on warnings:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -Tools All -FailOnWarnings
```

Verbose report:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -Tools All -VerboseReport
```

## What It Checks

- Every role in `.agents/roster.json` has `.agents/skills/<role>/SKILL.md`.
- Claude and Cursor skill mirrors contain each roster role when mirror directories exist.
- Claude and Cursor primary agent files exist and reference their canonical `.agents/skills/<role>` paths.
- Codex has `.codex/config.toml` and `.codex/README.md`.
- Codex documentation states that `.agents/skills` is the canonical source.
- Copilot instructions reference `AGENTS.md`.
- Required Copilot prompt files exist and reference `AGENTS.md` or `.agents/workflows`.

## Exit Codes

- `0`: no errors.
- `1`: critical validation errors.
- Warnings do not fail unless `-FailOnWarnings` is used.

The validator only reports drift. It does not generate, overwrite, or delete adapters.
