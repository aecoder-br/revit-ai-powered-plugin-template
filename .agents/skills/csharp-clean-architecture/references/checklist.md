# C# Clean Architecture Checklist

## Layer Review

- Core contains domain concepts, DTOs, and ports.
- Application contains use cases and orchestration.
- Infrastructure contains external integration implementations.
- UI contains WPF and MVVM behavior.
- RevitBridge contains bridge DTOs and contracts.
- Revit contains host integration, commands, adapters, and ExternalEvent logic.

## Dependency Direction

- Core has no dependency on other app projects.
- Application depends on Core.
- Infrastructure depends on Core and integration packages.
- UI depends on Application/Core abstractions, not Revit API.
- Revit composes adapter implementations.

## Design Rules

- Prefer explicit constructors.
- Avoid service locator except at the Revit host boundary.
- Avoid interfaces for every class.
- Add interfaces for ports, external services, and testable boundaries.
- Keep methods small and side effects clear.

## Tests

- Add unit tests for Application behavior.
- Use DTOs and fake ports for pure tests.
- Keep Revit API integration validation separate from pure unit tests.
