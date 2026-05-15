# Data Persistence Engineer Checklist

## Data Classification

- Configuration setting.
- User preference.
- Cache.
- Audit log.
- Model-derived data.
- Customer data.
- Secret or credential.

## Storage Decision

- Prefer in-memory state when possible.
- Prefer simple local config for user preferences.
- Use durable local storage only when the feature needs it.
- Justify SQLite or LiteDB before adding either.
- Avoid production dependencies unless justified.

## Safety

- Do not store sensitive model data by default.
- Do not store API keys or tokens in repository files.
- Define redaction for audit logs.
- Define retention period.
- Define deletion and migration behavior.

## Validation

- Add tests for serialization and migration when practical.
- Run `./scripts/check.ps1` when possible.
- Include privacy review when data leaves the Revit process.
