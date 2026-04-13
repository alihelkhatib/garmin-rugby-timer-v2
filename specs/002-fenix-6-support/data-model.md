# Data Model: fenix-6-support

This compatibility plan does not introduce new persistent entities. Data considerations:

- FIT session: ensure recorded FIT files contain required metadata and activity type mapping.
- Runtime state: ensure transient match state fits within available heap and is not persisted beyond session unless needed.

No schema changes required.