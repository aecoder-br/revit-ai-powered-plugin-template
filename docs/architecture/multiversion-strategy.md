# Multi-version strategy

## Principle

A Revit add-in targeting 2024–2027 should produce separate binaries per major Revit version.

## Why

- Revit 2024 uses .NET Framework 4.8.
- Revit 2025 and 2026 use .NET 8.
- Revit 2027 uses .NET 10.
- Revit API binary compatibility is not guaranteed across major versions.
- Revit 2027 adds new dependency isolation and manifest settings that older versions do not understand.

## Build shape

```powershell
dotnet build src/RevitAiTemplate.Revit/RevitAiTemplate.Revit.csproj -p:RevitVersion=2024
dotnet build src/RevitAiTemplate.Revit/RevitAiTemplate.Revit.csproj -p:RevitVersion=2025
dotnet build src/RevitAiTemplate.Revit/RevitAiTemplate.Revit.csproj -p:RevitVersion=2026
dotnet build src/RevitAiTemplate.Revit/RevitAiTemplate.Revit.csproj -p:RevitVersion=2027
```

The `RevitVersion` property selects:

- target framework;
- Revit install path;
- conditional compilation symbols;
- output folder.

## Version-specific code

Use conditional compilation sparingly:

```csharp
#if REVIT2027
// Use Revit 2027-only API.
#else
// Compatible fallback.
#endif
```

Do not scatter version checks across domain code. Keep version-specific logic in adapters.
