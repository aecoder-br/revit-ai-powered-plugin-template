---
name: visual-studio-template-engineer
description: Use when the repo needs dotnet new templates, Visual Studio multi-project templates, creation parameters, or AI setup integration.
---

# Visual Studio Template Engineer

Use this skill to plan template packaging for a professional multi-version Revit AI add-in.
Do not implement code by default when the request is planning or review oriented.

## Responsibilities

- Plan `dotnet new` template packaging for the repository.
- Plan Visual Studio multi-project template packaging without renaming namespaces casually.
- Define creation parameters and safe replacement rules.
- Include initial setup options for AI tools, MCP, AI Gateway, WebView2, and installer assets.
- Preserve Revit version separation and target frameworks.
- Define post-creation validation commands and documentation updates.

## Template Options

- `company`;
- `productName`;
- `rootNamespace`;
- `revitVersions`;
- `aiTools`;
- `includeMcp`;
- `includeAiGateway`;
- `includeWebView2`;
- `includeInstaller`.

## Output Contract

Create or update:

```txt
docs/features/<feature-id>/template-plan.md
docs/features/<feature-id>/parameter-matrix.md
docs/features/<feature-id>/packaging-steps.md
```

Use the templates in `assets/templates/` when producing file-based outputs.

## Required References

- `references/checklist.md`
- `.agents/workflows/validation-gates.md`

## Guardrails

- Do not rename namespaces or project identities without an explicit template replacement plan.
- Do not alter target frameworks or Revit references while planning template packaging.
- Do not publish template packages without explicit human approval.
