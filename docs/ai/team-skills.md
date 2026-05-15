# Team Skills

## Source Of Truth

Canonical skills live in:

```txt
.agents/skills
```

The planned role roster lives in:

```txt
.agents/roster.json
```

Tool-specific copies are generated mirrors or adapters:

- `.claude/skills`
- `.cursor/skills`
- `.claude/agents`
- `.cursor/agents`
- `.github/prompts`

## Skill Groups

Planning and coordination:

- `orchestrator-feature-lead`
- `branch-coordinator`
- `product-manager`
- `requirements-analyst`
- `technical-writer`

Engineering:

- `revit-api-senior`
- `revit-multiversion-architect`
- `csharp-clean-architecture`
- `wpf-webview2-ux-ui`
- `ai-runtime-mcp-engineer`
- `ai-gateway-backend-engineer`
- `data-persistence-engineer`

Delivery and quality:

- `cybersecurity-privacy-engineer`
- `qa-automation-engineer`
- `devops-release-engineer`
- `installer-packaging-engineer`
- `visual-studio-template-engineer`
- `verifier`
- `pr-reviewer`

## Updating Skills

1. Edit `.agents/skills/<skill-name>`.
2. Run:

```powershell
./scripts/validate-skills.ps1
./scripts/setup-ai-tools.ps1 -Tools All -Mode Copy -Validate -ValidateAdapters
```

3. Review generated mirror diffs in `.claude/skills` and `.cursor/skills`, plus static adapter validation for Codex and Copilot.

Do not duplicate long skill instructions in README, AGENTS, Claude, Cursor, or Copilot docs.
