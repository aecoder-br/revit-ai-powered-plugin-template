# Environment Evidence Example

This is an example format only. Replace all placeholder values with real observed output.

## Machine

- Date: `<yyyy-mm-dd>`
- Machine or runner: `<machine-name>`
- OS: `<Windows version>`
- PowerShell: `<$PSVersionTable.PSVersion>`
- Git: `<git --version>`

## SDKs

```txt
<dotnet --list-sdks output>
```

## Revit Installations

| Version | Installed | Path | API DLLs |
| --- | --- | --- | --- |
| 2024 | `<yes/no>` | `<path>` | `<present/missing>` |
| 2025 | `<yes/no>` | `<path>` | `<present/missing>` |
| 2026 | `<yes/no>` | `<path>` | `<present/missing>` |
| 2027 | `<yes/no>` | `<path>` | `<present/missing>` |

## Environment Validator

Command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-environment.ps1 -RequireFull -JsonOutput ./artifacts/environment-validation/full.json
```

Result:

```txt
<exit code and summary>
```
