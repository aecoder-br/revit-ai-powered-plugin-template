# Installer Packaging Checklist

## Version Separation

- Map each Revit version to its target framework and output directory.
- Keep `.addin` manifests version-specific.
- Confirm assembly paths point to the correct versioned binary.

## Install Scope

- Decide per-user installation under AppData or machine-wide installation under ProgramData.
- Document admin rights, enterprise deployment, update policy, and support implications.
- Keep user settings separate from application binaries.

## Manifest Review

- Validate add-in name, assembly path, add-in ID, vendor ID, vendor description, and command class.
- Confirm manifests are installed into the correct Revit addins folder.
- Confirm no stale manifest points to removed or mismatched binaries.

## Packaging Option Review

- Use script-based packaging for early template validation.
- Use MSI/WiX/Inno when enterprise installation, repair, or uninstall behavior is required.
- Use MSIX only when Revit add-in loading and enterprise requirements are compatible.

## Uninstall And Upgrade

- Preserve user settings unless removal is explicitly requested.
- Remove only files owned by the installer.
- Document rollback and repair strategy.
