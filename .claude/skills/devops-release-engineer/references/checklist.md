# DevOps Release Checklist

## Build Matrix

- List Revit versions and target frameworks.
- Identify required .NET SDKs.
- Identify whether each project is pure, adapter-based, UI-based, or Revit-dependent.
- Separate fast validation from full release validation.

## CI Without Revit

- Run repository hygiene and configuration validation.
- Run tests for Core/Application and other pure projects.
- Build projects that do not require local Autodesk references.
- Validate skills and AI configuration.

## CI With Revit Installed

- Use Windows runners with explicit Revit version installation assumptions.
- Build each supported Revit version with `./scripts/build.ps1 -RevitVersion <year>`.
- Record installed Revit paths and SDK availability in job logs.

## Artifacts

- Keep version-specific outputs separated.
- Include add-in binaries, manifests, installer packages, checksums, release notes, and template packages when applicable.
- Exclude local cache, secrets, model exports, and developer machine paths.

## Release

- Define signing, versioning, changelog, and release notes steps.
- Define rollback and support diagnostics.
- Require human approval before publishing packages or releases.
