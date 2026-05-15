# Revit Multiversion Architect Checklist

## Version Matrix

| Revit | Target framework | Required check |
|---|---|---|
| 2024 | `net48` | .NET Framework 4.8 and Revit 2024 API |
| 2025 | `net8.0-windows` | .NET 8 Windows and Revit 2025 API |
| 2026 | `net8.0-windows` | .NET 8 Windows and Revit 2026 API |
| 2027 | `net10.0-windows` | .NET 10 Windows and Revit 2027 API |

## Review Steps

- Check `Directory.Build.props` before changing build behavior.
- Check project target frameworks before changing references.
- Keep Revit API version logic in adapters where possible.
- Avoid scattering conditional compilation through domain or UI code.
- Confirm output paths remain version-specific.
- Confirm no single universal binary is introduced.

## Validation

Use:

```powershell
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027
```

Record skipped versions exactly when Revit is not installed.
