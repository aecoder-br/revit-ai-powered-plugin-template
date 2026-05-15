# Installer notes

## Development install

Use `scripts/dev-install.ps1` to install a per-user `.addin` manifest.

## Production install

Recommended structure:

```txt
C:\Program Files\Company\Product\2024\RevitAiTemplate.Revit.dll
C:\Program Files\Company\Product\2025\RevitAiTemplate.Revit.dll
C:\Program Files\Company\Product\2026\RevitAiTemplate.Revit.dll
C:\Program Files\Company\Product\2027\RevitAiTemplate.Revit.dll
```

Use one manifest per Revit version.

## Revit 2027 note

Revit 2027 changed all-user add-in discovery paths. Prefer per-user manifests for development. For enterprise all-user installs, validate the current Autodesk guidance and avoid writing manifests into locations reserved for Autodesk internal signed add-ins.

## Production checklist

- [ ] Unique AddInId and VendorId.
- [ ] Version-specific manifest.
- [ ] Signed binaries if required by your deployment policy.
- [ ] AI Gateway endpoint configuration.
- [ ] Privacy/security docs.
- [ ] Uninstaller removes manifests and product files.
