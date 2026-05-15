# WPF WebView2 UX UI Examples

## Modeless Assistant

Recommended flow:

1. User opens assistant from a Revit command.
2. UI loads without touching Revit API directly.
3. User requests model context.
4. ViewModel calls an application service.
5. Adapter queues Revit work through ExternalEvent.
6. UI shows loading, result, or error.

## Error State

Show a clear message when:

- no active document exists;
- selection is empty;
- Revit is busy;
- bridge request times out;
- user cancels.
