# Implementation Plan: Rugby Referee Timer

**Branch**: `001-rugby-referee-timer` | **Date**: 2026-04-18 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-rugby-referee-timer/spec.md`

## Summary

Build a Garmin Connect IQ watch app for rugby referees that keeps one synchronized match-state model driving the main countdown, count-up timer, scoring, cards, conversion screen, haptics, summary flow, and activity recording. The implementation stays resource-first for stable watch layouts and records rugby activity output with supported GPS, distance, current speed, and average speed data when available.

## Technical Context

**Language/Version**: Monkey C / Garmin Connect IQ SDK 4.1.6 minimum  
**Primary Dependencies**: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, `ActivityRecording`  
**Storage**: Connect IQ app storage only for lightweight preferences and unsupported-recording fallback; no match-history database  
**Testing**: Monkey C unit tests plus Garmin simulator/device checks on fenix 6 class and representative large/small round watch profiles  
**Target Platform**: Garmin watches from fenix 6 onward and other compatible Connect IQ watch lines validated in simulator/device testing  
**Project Type**: Garmin Connect IQ watch app  
**Performance Goals**: One shared snapshot per refresh, no visible timer drift, and non-blocking recording/event updates  
**Constraints**: Offline watch app, dark accessible UI, one active recording session, no network dependency, resource-first UI, limited file count  
**Scale/Scope**: Single-referee live match control across built-in rugby variants and recording output for the current match only

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Referee-first scope: primary match countdown remains the dominant object and supporting UI is limited to in-match referee decisions.
- [x] Spec traceability: each behavior change is captured in the active feature spec or a dedicated supporting spec before implementation tasks proceed.
- [x] Synchronized timebase: main countdown, count-up/realtime, card timers, conversion timer, haptics, and expiry logic derive from one time source.
- [x] Simplicity/DRY: variant rules are shared data/configuration; no speculative abstractions, unused dependencies, or extraneous files.
- [x] Declarative UI resources: screen structure, static text, colors, fonts, and stable positions use Connect IQ XML/resources where feasible; any manual drawing is justified.
- [x] Garmin compatibility: Connect IQ SDK/API assumptions, fenix 6+ support, representative device coverage, and exclusions are documented.
- [x] Activity recording: rugby activity type or documented SDK fallback is planned and testable.
- [x] Regression isolation: existing functioning timer, scoring, variant, UI, storage, and activity-recording behavior affected by the feature has explicit regression coverage.
- [x] Accessibility/haptics: dark color-blind-friendly UI, non-color-only card distinction, stable watch layout, and critical haptic alerts are specified.
- [x] Security & Privacy: feature plan includes data classification, PII handling, telemetry opt-in, retention/deletion policy, and a completed security checklist.
- [x] Release & Rollback: release checklist, CI/CD gates, signing, device validation, and rollback/emergency patch procedures are documented.
- [x] Dependency & Supply-Chain: SBoM for dependencies, CVE scanning, license review, and upgrade policy documented.
- [x] Performance Budgets: measurable budgets for binary size, memory, CPU/battery and device validation tests are defined.
- [x] Incident Response & Monitoring: monitoring/alerting plan, incident contacts, and postmortem expectations are present.
- [x] Contributor Governance & Approvals: owner and approver for the feature, any required contributor approvals, and Code of Conduct link are documented in project governance.
- [x] Legal & App-Store Compliance: licensing, store policy checks, and export-control considerations are documented.
- [x] Deprecation & Migration: deprecation notices, migration path, and compatibility considerations are described when applicable.

## Project Structure

### Documentation (this feature)

```text
specs/001-rugby-referee-timer/
|-- plan.md              # This file
|-- research.md          # Research decisions and API choices
|-- data-model.md        # Entity and state model
|-- quickstart.md        # Build and validation steps
|-- contracts/           # UI interaction contract and related behavior notes
`-- tasks.md             # Generated after planning
```

### Source Code (repository root)

```text
source/                  # Monkey C application code
resources/               # Connect IQ XML resources and layouts
manifest.xml             # Connect IQ device/app manifest
monkey.jungle            # Build configuration
tests/                   # Monkey C tests where supported
```

**Structure Decision**: Use the existing repository root layout and keep all feature planning artifacts in `specs/001-rugby-referee-timer/`. Implementation should continue to use the current `source/`, `resources/`, `manifest.xml`, `monkey.jungle`, and `tests/` directories without introducing new top-level code roots.

## Complexity Tracking

No constitution violations require complexity justification for this feature.

