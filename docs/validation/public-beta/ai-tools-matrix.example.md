# AI Tools Matrix Example

This is an example format only. Record observed results from setup and adapter validation.

| Tool | Command | Status | Evidence |
| --- | --- | --- | --- |
| Codex | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools Codex -ValidateAdapters` | `<passed/failed>` | `<summary>` |
| Claude Code | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools Claude -Mode Copy -Force -Validate -ValidateAdapters` | `<passed/failed>` | `<summary>` |
| Cursor | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools Cursor -Mode Copy -Force -Validate -ValidateAdapters` | `<passed/failed>` | `<summary>` |
| GitHub Copilot | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools Copilot -ValidateAdapters` | `<passed/failed>` | `<summary>` |
| Multi-tool setup | `./scripts/setup-ai-tools.ps1 -RootPath . -Tools All -Mode Copy -Force -Validate -ValidateAdapters` | `<passed/failed>` | `<summary>` |

Also record:

- `./scripts/validate-skills.ps1 -RootPath . -IncludeMirrors -FailOnWarnings`
- `./scripts/validate-ai-adapters.ps1 -RootPath . -Tools All -FailOnWarnings`
- `./scripts/validate-toml.ps1 -RootPath . -VerboseReport`
