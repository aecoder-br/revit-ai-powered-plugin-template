# WPF WebView2 UX UI Checklist

## UX Flow

- Identify user entry point in Revit.
- Define modeless, dockable, modal, or command-based behavior.
- Define loading, success, empty, error, cancelled, and permission states.
- Define clear user feedback for long-running tasks.
- Define keyboard and accessibility expectations.

## MVVM Review

- Keep ViewModels free of Revit API references.
- Use commands that call application services or ports.
- Keep WebView2 messages mapped to DTOs.
- Avoid domain logic in XAML code-behind.

## Revit Safety

- Use ExternalEvent-backed services for model access.
- Do not keep long-lived Revit API object references in UI state.
- Treat active document and selection as volatile.

## Validation

- Run `./scripts/check.ps1` when possible.
- Add tests for ViewModel behavior when practical.
- Manually review layout resilience for Revit window sizes.
