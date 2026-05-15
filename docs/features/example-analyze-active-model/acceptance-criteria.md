# Acceptance Criteria

## Documentation Example

- Given a contributor opens `docs/features/example-analyze-active-model/`, when they read the feature artifacts, then they can identify the feature brief, requirements, acceptance criteria, task plan, and role handoffs.
- Given an agent reads `task-plan.json`, when it selects a task, then it can determine the assigned role, allowed paths, read-only paths, validation commands, and handoff path.
- Given two agents are assigned different tasks, when they follow `allowedPaths`, then they do not edit the same file paths concurrently.
- Given the example is documentation-only, when the diff is reviewed, then no production source code files are changed.

## Future Feature Behavior

- Given a Revit project document is active, when the user requests a category summary, then the future feature collects category information in a valid Revit API context.
- Given the UI is modeless or background-driven, when it needs model data, then it uses ExternalEvent before touching Revit.
- Given category data crosses out of the Revit project, when the future feature calls Application or AI Gateway boundaries, then it passes DTOs only.
- Given the AI Gateway is unavailable, when the future feature requests a summary, then it reports a recoverable error without writing to the model.
- Given the feature completes successfully, when the user sees the summary, then it is clearly presented as AI-assisted advisory output.

## Safety Criteria

- Given the feature is read-only, when it runs, then it does not open a Revit `Transaction`.
- Given model data may contain sensitive names, when the AI Gateway request is created, then the request contains only minimized category summary data.
- Given a reviewer checks the implementation, when they inspect project references, then Core, Application, UI, MCP, and AI Gateway projects do not reference `Autodesk.Revit.*`.
