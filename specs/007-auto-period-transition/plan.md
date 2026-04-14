# Implementation Plan: Auto Period Transition

**Branch**: `007-auto-period-transition` | **Date**: 2026-04-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-auto-period-transition/spec.md`

## Summary

Automatically transition out of active match timing when the main countdown reaches 00:00: non-final periods enter the existing between-period flow, while the final period enters the existing match-ended summary/save flow. Non-final period end now also starts a simple half-time count-up timer at 00:00 so the referee can track elapsed break time until the next period starts. Preserve unexpired yellow-card countdowns across non-final period boundaries by anchoring them to active match time, carrying team assignment and remaining time into the next period, and pausing them while the half-time timer runs. The implementation should stay in the existing match model/delegate/view/test structure, with no new storage, networking, dependencies, or broad UI redesign.

## Technical Context

**Language/Version**: Monkey C / Garmin Connect IQ API 4.1.6 minimum, validated with local Connect IQ SDK 9.1.0 build commands  
**Primary Dependencies**: Garmin Connect IQ Toybox modules already used by the app: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording`  
**Storage**: Current match runtime state only; no new persistent app storage  
**Testing**: Monkey C unit tests for `RugbyGameModel` countdown expiry, half/final-period transition, half-time timer count-up, and yellow-card carry-forward; Garmin app/test compile for `fenix7`; simulator/device checks for transition readability on representative round watches
**Target Platform**: Garmin watches from fenix 6 onward, plus compatible Connect IQ watch lines already covered by manifest/device validation  
**Project Type**: Garmin Connect IQ watch app  
**Performance Goals**: Countdown expiry, half-time count-up, yellow-card expiry, and transition state all resolve from one match snapshot/update with no visible drift or repeated transition
**Constraints**: Lightweight offline watch app; dark color-blind-friendly UI; haptic critical alerts remain unchanged; minimal files/dependencies; resource-backed UI preserved unless a dynamic state binding requires Monkey C view logic  
**Scale/Scope**: Single-referee in-match use across rugby variants including 15s, 7s, 10s, and U19; scope limited to automatic period/match transition, yellow-card timer continuity, and elapsed break-time display between non-final periods

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Referee-first scope: fixes live match lifecycle timing, card-timer continuity, and break-time tracking for the referee; no secondary analytics or decorative UI added.
- [x] Spec traceability: behavior is captured in `specs/007-auto-period-transition/spec.md`, including the 2026-04-14 half-time timer correction.
- [x] Synchronized timebase: main countdown, count-up, half-time count-up, yellow-card timers, expiry, and transition state remain derived from `RugbyGameModel` state snapshots instead of independent loops.
- [x] Simplicity/DRY: extend existing model transition methods and tests; no new scheduler, dependency, persistence, or parallel match state machine.
- [x] Declarative UI resources: existing between-period and match-ended resource-backed flows remain the destination; only dynamic state binding is planned for the half-time timer if current resources lack that label.
- [x] Garmin compatibility: Connect IQ API 4.1.6 minimum and fenix 6+ target remain unchanged; validate with app/test compiles and representative simulator/device checks.
- [x] Activity recording: existing activity recorder remains the save path for final-period auto-end; no activity fallback changes are introduced.
- [x] Regression isolation: tests must cover existing manual end-half/end-match, scoring, conversion, card, variant, display, haptic, and activity-recording behavior touched by countdown expiry or break display.
- [x] Accessibility/haptics: no new haptic pattern or color-only cue; the half-time timer must be clearly distinguishable from match play time and carried yellow-card timers remain readable.
- [x] Security & Privacy: feature changes local current-match timer state only; no PII, telemetry, network transmission, or new persistence added.
- [x] Release & Rollback: use existing signed Connect IQ build flow; rollback is reverting this feature branch and rebuilding the previous working artifact.
- [x] Dependency & Supply-Chain: no new dependencies; existing Garmin SDK/Toybox APIs only.
- [x] Performance Budgets: transition work is constant per snapshot/update plus existing sanctions iteration; no background network, storage, or independent timer loop added.
- [x] Incident Response & Monitoring: local `RUGBY|...` diagnostics may be added for expiry/transition reproduction; no production monitoring or external alerts added.
- [x] Contributor Governance & Approvals: feature follows Spec Kit branch/spec/plan/tasks flow; review should focus on timer correctness and referee UX.
- [x] Legal & App-Store Compliance: no new third-party licenses, exports, or external data flows; maintain Garmin app-store policy compatibility.
- [x] Deprecation & Migration: no persisted data schema migration and no user-facing deprecation required.

## Project Structure

### Documentation (this feature)

```text
specs/007-auto-period-transition/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- period-transition-contract.md
|-- checklists/
|   `-- requirements.md
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

**Structure Decision**: Keep the existing single-app Connect IQ structure. Plan implementation in `source/RugbyGameModel.mc` for countdown-expiry transition, half-time timer derivation, and yellow-card carry-forward semantics; `source/RugbyTimerView.mc` for binding the between-period half-time timer and already-existing period/match-ended states; `source/RugbyTimerDelegate.mc` only if the delegate must react to auto-final-match save behavior; and `tests/Test_RugbyGameModel.mc` plus traceability docs for regression coverage.

## Complexity Tracking

No constitution violations. The feature avoids new storage, network behavior, separate timers, and new UI flows by reusing the current model, half-ended state, match-ended summary, existing sanction representation, and a derived elapsed break timer.

## Phase 0: Research

See [research.md](research.md). Decisions resolved: where automatic transition belongs, how to determine final vs non-final period, how to carry unexpired yellow-card timers, how to derive the half-time elapsed timer without enforcing break duration, how to handle paused-at-zero behavior, how to preserve conversion/red-card behavior, and the validation posture.

## Phase 1: Design

See [data-model.md](data-model.md), [contracts/period-transition-contract.md](contracts/period-transition-contract.md), and [quickstart.md](quickstart.md). Design keeps the public user flow unchanged except for the requested automatic countdown-expiry transition and elapsed half-time timer while between periods.

## Post-Design Constitution Check

- [x] Synchronized timebase preserved through model-owned match state and snapshot/update transition evaluation; half-time elapsed time is a derived between-period value, not a second countdown loop.
- [x] UI resource-first approach preserved by reusing existing between-period and match-ended flows with minimal dynamic timer binding.
- [x] Activity recording behavior remains existing final-match save/summary behavior with no new data export surface.
- [x] Security/privacy remain local current-match timer state only, with no new persistence, telemetry, or network behavior.
- [x] No new dependencies, storage services, schedulers, or speculative abstractions introduced by the design.
