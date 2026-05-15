# GitHub Copilot instructions

Use `AGENTS.md` as the canonical source of repository rules.

For Revit API work:

- Keep Revit API calls inside `src/RevitAiTemplate.Revit`.
- Never call Revit API from WPF view models, WebView2 JavaScript handlers, MCP tools, AI Gateway, or tests.
- Use `ExternalEvent` for modeless UI, background, MCP, or bridge requests.
- Preserve the multi-version build strategy.
- Run `./scripts/check.ps1` when possible.
