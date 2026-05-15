---
name: template-setup
description: Guide setup of AI tools and creation of a new plugin from dotnet or Visual Studio templates.
agent: plan
argument-hint: <tool choice, product name, or setup request>
---

# Template Setup

Use `AGENTS.md` as the repository rule source.
Use `.agents/skills/visual-studio-template-engineer/SKILL.md` and `.agents/skills/devops-release-engineer/SKILL.md`.
Use `docs/ai/ai-tooling-setup.md`, `docs/ai/visual-studio-template.md`, and `.agents/workflows/validation-gates.md`.

Guide the user through:

- choosing `AiTools`: `none`, `codex`, `claude`, `cursor`, `copilot`, or `multi`;
- creating a plugin with `dotnet new revit-ai-plugin`;
- opening the generated `.sln` in Visual Studio;
- refreshing AI tool mirrors with `scripts/setup-ai-tools.ps1`;
- understanding the current Visual Studio ProjectGroup v1/v2/v3 roadmap.

Do not run setup scripts automatically unless the user explicitly asks. Do not install dependencies, mutate user-wide settings, or execute destructive actions without consent.
