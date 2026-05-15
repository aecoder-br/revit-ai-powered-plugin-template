# GitHub Copilot instructions

Use `AGENTS.md` as the canonical source of repository rules.

Use `.github/prompts/*.prompt.md` for repeatable workflows:

- `feature-plan.prompt.md`
- `revit-api-review.prompt.md`
- `security-review.prompt.md`
- `qa-validation.prompt.md`
- `pr-summary.prompt.md`

Use `docs/ai/ai-tooling-setup.md` for AI tool setup and `.agents/workflows` for lifecycle, branch isolation, handoff, and validation rules.

For Revit API work:

- Keep Revit API calls inside `src/RevitAiTemplate.Revit`.
- Never call Revit API from WPF view models, WebView2 JavaScript handlers, MCP tools, AI Gateway, or tests.
- Use `ExternalEvent` for modeless UI, background, MCP, or bridge requests.
- Preserve the multi-version build strategy.
- Run `./scripts/check.ps1` when possible.
- Do not create arbitrary Revit API execution tools.
