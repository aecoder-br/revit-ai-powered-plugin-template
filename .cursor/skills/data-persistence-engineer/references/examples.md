# Data Persistence Engineer Examples

## Good Local Persistence

Store a UI preference such as last selected tab or window size in local user settings.

## Cache

Cache a derived category summary with a clear invalidation trigger.
Do not cache full model exports without explicit user consent.

## Database Justification

Use SQLite only when queryable durable data is required and a simple JSON file is insufficient.
Document schema, migrations, retention, and privacy review.
