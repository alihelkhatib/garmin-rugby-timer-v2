# Implementation Plan: idle-timer-controls

**Branch**: `003-idle-timer-controls` | **Date**: 2026-04-13 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/Users/600171959/Projects/garmin-rugby-timer-v2/specs/003-idle-timer-controls/spec.md`

## Summary

Route physical button behavior by match state so pre-match idle controls adjust the main timer and active-match controls preserve scoring access. Idle Up/Menu increases the main timer by 1 minute up to the selected variant's normal half length; idle Down decreases by 1 minute down to 00:00; score dialogs remain unavailable before kickoff and after match end. Running, paused, and half-ended states remain active match states for score-dialog availability.

## Technical Context

**Language/Version**: Monkey C / Garmin Connect IQ API 4.1.6 minimum  
**Primary Dependencies**: Garmin Connect IQ Toybox modules already used by the app: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording`  
**Storage**: Existing local setup/preferences behavior only; this feature does not add new persistence  
**Testing**: Monkey C tests for model/delegate behavior plus Garmin simulator/device checks on representative small and large round watch profiles  
**Target Platform**: Garmin watches from fenix 6 onward, plus compatible Connect IQ watch lines already supported by the project  
**Project Type**: Garmin Connect IQ watch app  
**Performance Goals**: Idle button presses update the visible main timer on the next UI refresh with no visible lag, and no existing timer display drifts from the single match snapshot  
**Constraints**: Offline watch app, dark color-blind-friendly UI, no network dependency, no new third-party dependency, no broad UI redesign, and no manual drawing unless existing resource-backed layout cannot represent the state  
**Scale/Scope**: Single-referee in-match use across rugby variants including 15s, 7s, 10s, and U19

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Referee-first scope: The change improves pre-match setup and prevents irrelevant score entry before kickoff without adding analysis or data-entry flows.
- [x] Spec traceability: The behavior is captured in [spec.md](spec.md), including two clarifications for timer upper bound and active match states.
- [x] Synchronized timebase: The plan keeps timer state in the existing match model and snapshot flow; no independent countdown loops are added.
- [x] Simplicity/DRY: The change is limited to shared match setup/button routing behavior and avoids new dependencies or speculative abstractions.
- [x] Declarative UI resources: No layout or static text change is required; existing resource-backed screen structure remains in place.
- [x] Garmin compatibility: Connect IQ API 4.1.6 minimum and fenix 6+ validation remain the baseline, with simulator/device checks on representative round watch profiles.
- [x] Activity recording: This feature does not change activity recording; regression tasks will confirm match start/recording behavior is preserved.
- [x] Regression isolation: Tasks will cover idle button routing and active-match scoring, plus model/variant regressions touched by timer setup.
- [x] Accessibility/haptics: The existing dark, readable layout and haptic behavior are preserved; no new haptic pattern is required for this feature.
- [x] Security & Privacy: The feature changes local match-preparation state only and adds no PII, telemetry, network calls, or external storage.
- [x] Release & Rollback: Existing release gates apply: build, tests, simulator/device validation, signed release process, and rollback by reverting the small behavior patch.
- [x] Dependency & Supply-Chain: No new dependency is added; existing dependency inventory/CVE/license checks remain unchanged.
- [x] Performance Budgets: The change must stay within existing binary/memory/CPU/battery budgets and is validated by no visible timer lag on supported devices.
- [x] Incident Response & Monitoring: No telemetry/monitoring surface is added; existing incident process applies to any release regression.
- [x] Contributor Governance & Approvals: Feature owner/repo maintainer approval is required before implementation proceeds.
- [x] Legal & App-Store Compliance: No new legal or store-policy surface is introduced; existing Garmin app release checks apply.
- [x] Deprecation & Migration: No stored-data migration or public API deprecation is required.

## Project Structure

### Documentation (this feature)

```text
specs/003-idle-timer-controls/
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

**Structure Decision**: Keep source changes in the existing match model/delegate/view boundary: `source/RugbyGameModel.mc`, `source/RugbyVariantConfig.mc`, `source/RugbyTimerDelegate.mc`, and focused tests under `tests/`. No new app module or external dependency is needed.

## Complexity Tracking

No constitution violations require justification.

## Phase 0: Research

Research confirmed:

- Button routing is centralized in `source/RugbyTimerDelegate.mc`.
- Match setup and visible main countdown derive from `source/RugbyGameModel.mc` and `source/RugbyVariantConfig.mc`.
- The idle timer upper bound must be the selected variant's normal half length, not the current custom override value.
- Score dialog availability is limited to running, paused, and half-ended states.

Output: [research.md](research.md)

## Phase 1: Design & Contracts

Design outputs:

- [data-model.md](data-model.md) defines Match State, Main Timer Value, Variant Timer Bounds, and Score Dialog Availability.
- [contracts/ui-interaction-contract.md](contracts/ui-interaction-contract.md) defines the user-facing button interaction contract.
- [quickstart.md](quickstart.md) defines manual simulator/device validation for idle adjustments and active scoring regression.

Post-design Constitution Check: Pass. The design remains a small local behavior change, keeps state in the existing model snapshot flow, preserves resource-backed UI structure, and adds regression coverage without new dependencies.

## Phase 2: Task Planning Scope

Tasks should be generated by user story:

- US1: Adjust Main Timer Before Kickoff, including model/variant bounds and UI update tests.
- US2: Block Score Menu While Idle, including delegate routing tests for idle physical-button paths.
- US3: Preserve In-Match Score Controls, including running, paused, and half-ended scoring regression tests.

Suggested MVP: US1 plus the US2 idle Up/Menu score-menu block because both share the same idle button-routing change and jointly satisfy the primary reported bug.
