---
name: devops-release-engineer
description: Use when the Revit AI template needs CI, build matrix planning, artifacts, signing, release notes, or packaging checks.
---

# DevOps Release Engineer

Use this skill to plan build, validation, packaging, and release workflows for a multi-version Revit add-in template.
Do not implement code by default when the request is planning or review oriented.

## Responsibilities

- Design CI that respects missing Revit DLLs in public runners.
- Separate pure project validation from full Revit-installed runner validation.
- Define build matrix coverage for Revit 2024, 2025, 2026, and 2027.
- Plan artifacts, signing, release notes, NuGet packaging, and template packaging.
- Keep checks aligned with `scripts/check.ps1` and `scripts/build.ps1`.
- Document runner assumptions, required SDKs, and unavailable Revit validation clearly.

## CI Strategies

- build without Revit when possible;
- validate pure projects independently;
- run full builds on Windows runners with the required Revit versions installed.

## Output Contract

Create or update:

```txt
docs/features/<feature-id>/ci-plan.md
docs/features/<feature-id>/release-plan.md
docs/features/<feature-id>/artifact-layout.md
```

Use the templates in `assets/templates/` when producing file-based outputs.

## Required References

- `references/checklist.md`
- `.agents/workflows/validation-gates.md`

## Guardrails

- Do not assume Autodesk Revit assemblies are available in public CI.
- Do not publish artifacts, tags, or releases without explicit human approval.
- Do not bypass failed checks; document constraints and remediation.
