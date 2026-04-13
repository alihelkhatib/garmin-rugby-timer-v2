# Implementation Plan: Match Event Management

**Branch**: `005-match-event-management` | **Date**: 2026-04-13 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-match-event-management/spec.md`

## Summary

Add referee-focused match management improvements: automatic conversion countdowns after tries even while the match clock is paused, conversion-overlay-only layout adjustment, pause haptics and recurring pause reminders, card-triggered match pause, current-match event log with point-scoring and card events, match-end event review, and explicit Back options for End match and Reset match. The technical approach keeps existing modules and a single match model as the source of truth, adds small model fields for conversion/event-log/reset state, uses resource-backed menus/layouts for new UI, and preserves the existing activity recorder with best-effort event export/fallback diagnostics.

## Technical Context

**Language/Version**: Monkey C / Garmin Connect IQ API 4.1.6 minimum, validated with local Connect IQ SDK 9.1.0 build commands  
**Primary Dependencies**: Garmin Connect IQ Toybox modules already used by the app: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording`  
**Storage**: In-memory current-match event log; no new persistent app storage. Best-effort saved-activity event export uses existing activity-recording capability if supported, with in-app match-end review fallback.  
**Testing**: Monkey C unit tests for model/delegate behavior; Garmin app/test compile for `fenix7`; simulator/device checks for conversion overlay layout, haptics, paused reminders, Back options, and match-end event review  
**Target Platform**: Garmin watches from fenix 6 onward, plus compatible Connect IQ watch lines already covered by manifest/device validation  
**Project Type**: Garmin Connect IQ watch app  
**Performance Goals**: Timer and haptic updates derive from one match snapshot/timebase; pause reminder timer wakes every 10 seconds only while paused; conversion overlay updates without visible lag; no added network or analytics overhead  
**Constraints**: Lightweight offline watch app; dark color-blind-friendly UI; haptic critical alerts; minimal files/dependencies; UI structure in resources where feasible; keep red cards logged but do not add a persistent red-card timer  
**Scale/Scope**: Single-referee in-match use across rugby variants including 15s, 7s, 10s, and U19; event log limited to current match and cleared on Reset or new match start

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Referee-first scope: primary match countdown remains dominant; added UI supports conversion timing, pause safety, card/score review, and match lifecycle decisions.
- [x] Spec traceability: behavior is captured in `specs/005-match-event-management/spec.md` with clarifications recorded.
- [x] Synchronized timebase: main countdown, count-up, card timers, event-log match times, and haptics derive from `RugbyGameModel` elapsed-time state; conversion countdown is modeled against match elapsed time or a paused-start anchor without independent display drift.
- [x] Simplicity/DRY: use existing model, delegate, haptics, activity recorder, menu, and view patterns; avoid new dependencies or broad abstractions.
- [x] Declarative UI resources: Back options, match-end event review, and conversion overlay positioning use Connect IQ resources/layouts where feasible; Monkey C binds state and routes selections.
- [x] Garmin compatibility: Connect IQ API 4.1.6 minimum and fenix 6+ target remain unchanged; validate with app/test compiles and representative simulator/device checks.
- [x] Activity recording: existing rugby activity recorder remains; event export is best effort only and must not block save when unsupported.
- [x] Regression isolation: tests cover existing scoring, conversion, card, timer, haptic, activity, and idle/running controls touched by this feature.
- [x] Accessibility/haptics: haptic pause/reminder cues are specified; conversion overlay clipping is addressed; red-card event is logged even without a timer display.
- [x] Security & Privacy: event logs contain team side, action, and match elapsed time only; no PII, telemetry, or network transmission added.
- [x] Release & Rollback: use existing signed Connect IQ build flow; rollback is reverting this feature branch and rebuilding previous working artifact.
- [x] Dependency & Supply-Chain: no new dependencies; existing Garmin SDK/Toybox APIs only.
- [x] Performance Budgets: no new network/persistence loops; 10-second pause reminder timer runs only while paused; event log stays bounded to a single match.
- [x] Incident Response & Monitoring: diagnostics are local `RUGBY|...` traces for reproduction; no production monitoring or external alerts added.
- [x] Contributor Governance & Approvals: feature follows Spec Kit branch/spec/plan/tasks flow; review should focus on timer correctness and referee UX.
- [x] Legal & App-Store Compliance: no new third-party licenses, exports, or external data flows; maintain Garmin app-store policy compatibility.
- [x] Deprecation & Migration: no persisted data schema migration; reset/new match clearing is explicitly defined.

## Project Structure

### Documentation (this feature)

```text
specs/005-match-event-management/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- ui-interaction-contract.md
`-- tasks.md
```

### Source Code (repository root)

```text
source/                  # Monkey C application code
resources/               # Connect IQ XML resources and layouts
manifest.xml             # Connect IQ device/app manifest
monkey.jungle            # Build configuration
tests/                   # Monkey C tests where supported
```

**Structure Decision**: Keep the existing single-app Connect IQ structure. Extend `RugbyGameModel` for event-log/reset/conversion state, `RugbyTimerDelegate` and menu delegates for interaction routing, `RugbyHaptics` for pause/reminder feedback, `RugbyConversionView` plus conversion layout resources for overlay-only visual change, and the activity recorder for best-effort export diagnostics.

## Complexity Tracking

No constitution violations. The feature intentionally avoids new storage services, network telemetry, or a separate event-log subsystem; the current match model owns the current-match event list.

## Phase 0: Research

See [research.md](research.md). Decisions resolved: conversion timing while paused, pause reminder cadence, card-triggered pause, event log scope/retention, activity export fallback, Back option reset/save behavior, and conversion overlay layout isolation.

## Phase 1: Design

See [data-model.md](data-model.md), [contracts/ui-interaction-contract.md](contracts/ui-interaction-contract.md), and [quickstart.md](quickstart.md). Design keeps user-facing flows testable independently by user story while sharing only the event log and match state model.

## Post-Design Constitution Check

- [x] Synchronized timebase preserved through model-owned match elapsed time and event-log timestamp derivation.
- [x] UI resource-first approach documented for Back menu, event summary, and conversion overlay layout.
- [x] Activity-file export is best effort and explicitly non-blocking.
- [x] Security/privacy and retention remain local/current-match only.
- [x] No new dependencies or speculative abstractions introduced by the design.
