# Implementation Plan: Match Summary Access

## Technical Context

- Feature: Match Summary Access (end/reset menu; optional back-button access)
- Devices: representative Garmin devices (fenix 6 family and others) — initial device matrix: fenix 6 family (large-round), Forerunner/vivoactive family (small-round). Exact targets to be finalized during Phase 0 research.
- Constraint: No new persistent storage; reuse ActivityRecording/FIT when available
- Unknowns: specific device ActivityRecording APIs and export limits, exact layout constraints per device

## Constitution Check

- Must follow Constitution VII (Declarative Resource-First UI) — plan will prefer resource XML layouts where possible
- Must ensure Single Synchronized Timebase (II) for event timestamps
- No violations expected

## Phases

### Phase 0 - Research

- Research device-specific ActivityRecording/FIT export APIs and limits
- Research sample ActivityRecording payload size and simulator validation steps
- Research UI patterns for scrollable lists on small-round and large-round devices

### Phase 1 - Design

- Create data-model.md capturing Event schema and any validation rules
- Prepare quickstart.md describing how to validate on device simulator and run integration tests
- Produce UI XML layouts (resource-first) for summary view variants

### Phase 2 - Implementation Plan

- Define tasks for code changes: add menu entry, summary view screen, ActivityRecording export at match end, in-memory fallback rendering, tests, and device validation

## Outputs

- data-model.md (to be generated)
- research.md (to be generated)
- quickstart.md (to be generated)

## Performance Budgets

Device-specific measurable checks: For each representative device family (fenix 6 family, Forerunner/vivoactive family) define explicit measurement steps and pass/fail thresholds. Measurements should include compiled binary size (monkeyc build artifact), peak heap delta during a 90-minute simulated match, and CPU overhead. Record results and pass/fail per device in `specs/009-match-summary-access/perf-validation.md`. Create perf-check scripts to automate measurement where feasible.

## Notes

- Several NEEDS CLARIFICATION items were resolved in clarifications section of spec.md; remaining unknowns are device API details that require research.
