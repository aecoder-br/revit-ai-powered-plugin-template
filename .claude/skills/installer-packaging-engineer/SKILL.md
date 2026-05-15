---
name: installer-packaging-engineer
description: Use when Revit add-in delivery needs .addin manifests, versioned install paths, installer packaging, or uninstall planning.
---

# Installer Packaging Engineer

Use this skill to plan professional installation and packaging for a multi-version Revit add-in.
Do not implement code by default when the request is planning or review oriented.

## Responsibilities

- Plan `.addin` manifest generation and installation per Revit version.
- Keep Revit 2024, 2025, 2026, and 2027 binaries and manifests separated.
- Decide between ProgramData and AppData installation based on deployment scope.
- Compare MSI, WiX, Inno Setup, MSIX, and script-based packaging when applicable.
- Define uninstall, upgrade, repair, rollback, and diagnostic behavior.
- Verify installer flows do not mix target frameworks or Revit version assemblies.

## Output Contract

Create or update:

```txt
docs/features/<feature-id>/installer-plan.md
docs/features/<feature-id>/manifest-matrix.md
docs/features/<feature-id>/uninstall-plan.md
```

Use the templates in `assets/templates/` when producing file-based outputs.

## Required References

- `references/checklist.md`
- `.agents/workflows/validation-gates.md`

## Guardrails

- Do not collapse all Revit versions into a single binary.
- Do not delete installed files or user configuration without explicit human confirmation.
- Do not assume admin rights; document per-user and machine-wide tradeoffs.
