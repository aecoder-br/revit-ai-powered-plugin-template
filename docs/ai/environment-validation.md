# Environment Validation

Use `scripts/validate-environment.ps1` to check whether a Windows machine is ready to validate this Revit AI-powered plugin template.

The script is intentionally separate from `scripts/check.ps1`. Normal repository checks should remain lightweight and should not require every Revit version or Visual Studio installation. Use environment validation before Public Beta sign-off, release testing, or a full local template validation pass.

## Validation Modes

### Partial Validation

Partial validation is the default mode:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-environment.ps1
```

The script returns exit code `0` when the baseline environment can run partial checks. Missing Revit versions, .NET SDK 10, Visual Studio, WebView2, actionlint, or symlink permissions are reported as warnings or optional checks unless explicitly required.

Baseline requirements for partial validation:

- Windows;
- PowerShell;
- Git;
- `dotnet`;
- .NET SDK 8.

### Full Validation

Full validation is for Public Beta readiness and release sign-off:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-environment.ps1 -RequireFull
```

With `-RequireFull`, the script requires the full validation surface:

- .NET SDK 10 for Revit 2027;
- .NET Framework 4.8 Developer Pack for Revit 2024;
- Visual Studio, when detectable;
- Revit 2024, 2025, 2026, and 2027;
- `RevitAPI.dll` and `RevitAPIUI.dll` for each required Revit version.

The script returns exit code `1` if any full requirement is missing.

## Parameters

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-environment.ps1 `
  -RequireFull `
  -RequireRevitVersions 2024,2025,2026,2027 `
  -RequireDotNet10 `
  -JsonOutput ./artifacts/environment-validation.json
```

Parameters:

- `-RequireFull`: requires the complete Public Beta validation environment.
- `-RequireRevitVersions`: requires only the listed Revit versions. Useful for version-specific validation.
- `-RequireDotNet10`: fails when .NET SDK 10 is missing, even without `-RequireFull`.
- `-JsonOutput <path>`: writes machine-readable validation results.

## Checks

The script reports a table with:

- `Check`;
- `Status`: `Passed`, `Warning`, `Failed`, or `Optional`;
- `Detected value`;
- `Remediation`.

Checks include:

- Windows operating system;
- PowerShell version;
- Git;
- `dotnet`;
- .NET SDK 8;
- .NET SDK 10;
- .NET Framework 4.8 Developer Pack, when detectable;
- Visual Studio, when detectable;
- Revit 2024, 2025, 2026, and 2027;
- `RevitAPI.dll` and `RevitAPIUI.dll` for found or required Revit versions;
- WebView2 runtime, when detectable;
- `actionlint`, optional;
- Windows symlink permission, when detectable;
- Revit add-in paths under AppData and ProgramData.

## Expected Public Beta Command Set

Before Public Beta sign-off, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-environment.ps1 -RequireFull -JsonOutput ./artifacts/environment-validation/full.json
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-skills.ps1 -RootPath . -IncludeMirrors -FailOnWarnings
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-ai-adapters.ps1 -RootPath . -Tools All -FailOnWarnings
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-toml.ps1 -RootPath . -VerboseReport
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/check.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/build.ps1 -RevitVersion all
```

Do not treat a skipped Revit version as final Public Beta evidence. Skips are acceptable for local partial validation only.

## Notes

- The script detects common Autodesk Revit install paths such as `C:\Program Files\Autodesk\Revit 2024`.
- Visual Studio detection uses `vswhere.exe` when available and falls back to common Visual Studio 2022 directories.
- WebView2 detection checks common registry and installation paths.
- Symlink capability detection is best effort. If it cannot be detected, use `scripts/setup-ai-tools.ps1 -Mode Copy` or validate symlink mode manually.
- The script does not create add-in folders. It only reports whether expected AppData and ProgramData paths already exist.
