# QA Automation Checklist

## Test Scope

- Identify touched projects and boundaries.
- Confirm whether Revit API code is involved.
- Confirm whether the feature reads, writes, exports, stores, or sends model data.
- Confirm target Revit versions: 2024, 2025, 2026, 2027.

## Unit Tests

- Place pure behavior tests in Core or Application test projects when possible.
- Cover use cases, validation, DTO mapping, configuration, and error handling.
- Avoid Autodesk Revit API references in pure tests.

## Adapter Tests

- Use fakes for provider clients, storage, process boundaries, and RevitBridge DTO contracts.
- Verify cancellation, timeout, retry, and error paths where applicable.
- Verify privacy redaction before payloads leave the add-in boundary.

## Manual Revit Smoke Tests

- Document commands to run per Revit version.
- Verify command registration, ribbon entry, ExternalEvent routing, named transactions, and model rollback behavior.
- Include project, family, active view, selection, linked model, and worksharing cases when relevant.

## Regression Checks

- Run `./scripts/check.ps1` when possible.
- Run `./scripts/build.ps1 -RevitVersion <year>` for applicable versions when the SDK and Revit references are available.
- Record failures caused by missing SDK or Revit installation separately from product failures.

## Validation Report

- Include commands run, environment limits, results, risks, and follow-up tasks.
- Include diff/path ownership review when work was produced by isolated agents.
