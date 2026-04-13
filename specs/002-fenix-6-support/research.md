# Research: fenix-6-support

## R-001: Connect IQ SDK version
Recommended: Use the latest stable Connect IQ SDK compatible with fenix 6 at validation time. If constrained, minimum supported SDK: 4.1.6 (as noted in project guidelines). Validate that the chosen SDK supports Activity.SPORT_RUGBY constant; if absent, document fallback mapping.

## R-002: Device capabilities and manifest flags
- fenix 6 supports haptic vibration patterns and activity recording APIs. Confirm manufacturer-specific device capabilities (e.g., vibration intensity control) and any manifest flags for permissions.

## R-003: Layout and fonts
- Verify existing resource XML uses scalable units and avoids fixed pixel offsets. If fixed sizes present, refactor to use resource layouts and relative positioning.

Decision: Use SDK 4.1.6+ and prefer resource modifications over runtime layout code.
