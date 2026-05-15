# ADR 0002: Runtime AI goes through an AI Gateway

## Status

Accepted

## Context

Embedding multiple provider SDKs and API keys in Revit increases dependency, privacy and operational risk.

## Decision

The add-in calls an AI Gateway over HTTP. The gateway handles providers, keys, policy and audit.

## Consequences

- Cleaner add-in dependencies.
- Easier governance.
- Requires deployment of gateway for production AI features.
