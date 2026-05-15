---
applyTo: "src/RevitAiTemplate.Revit/**/*.cs"
---

# Revit API instructions

- Revit API changes must respect the valid API context rule.
- Use `Transaction`, `SubTransaction`, or `TransactionGroup` only where appropriate.
- Do not keep long-lived references to `Document`, `UIDocument`, `Element`, or `ElementSet` outside Revit context.
- Convert Revit objects to DTOs before leaving the adapter layer.
- Use conditional compilation for version-specific APIs.
- Prefer explicit failure handling and rollback over silent catch blocks.
