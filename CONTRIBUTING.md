# Contributing

## Branching

Use feature branches and small pull requests.

## Required validation

```powershell
./scripts/check.ps1
```

For Revit API changes, validate at least one installed Revit version with:

```powershell
./scripts/build.ps1 -RevitVersion 2026
./scripts/dev-install.ps1 -RevitVersion 2026
```

## Pull request checklist

- [ ] I kept Revit API references out of Core/Application/UI.
- [ ] I used ExternalEvent for modeless/background/MCP-triggered Revit work.
- [ ] I added or updated tests where possible.
- [ ] I did not introduce secrets or sensitive model data.
- [ ] I documented new MCP tools or AI behavior.
- [ ] I listed Revit versions tested.
