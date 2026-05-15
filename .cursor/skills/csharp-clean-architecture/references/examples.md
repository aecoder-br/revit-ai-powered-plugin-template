# C# Clean Architecture Examples

## Good Boundary

Application use case depends on an `IModelContextReader` port from Core.
The Revit project implements the port by reading Revit API data and mapping it to DTOs.

## Boundary Leak

Fail review when Application receives `Autodesk.Revit.DB.Document`.

## Interface Rule

Use an interface for an AI Gateway client because it is an external integration.
Avoid an interface for a simple immutable mapper unless tests or boundaries require it.
