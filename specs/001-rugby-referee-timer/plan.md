# Implementation Plan: Rugby Referee Timer

**Branch**: `001-rugby-referee-timer` | **Date**: 2026-04-12 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-rugby-referee-timer/spec.md`

## Summary

Build a Garmin Connect IQ watch app for rugby referees with a dominant synchronized match countdown, secondary count-up active match timer display, variant-based match setup, full common scoring with lightweight correction actions, yellow-card countdowns, persistent red-card indicators, conversion timing, haptics, and rugby activity recording. The implementation will use a single match-state/timebase model so all derived timers, alerts, and UI rendering update together.

## Technical Context

**Language/Version**: Monkey C / Garmin Connect IQ API 4.1.6 minimum for `Activity.SPORT_RUGBY`
**Primary Dependencies**: Garmin Connect IQ Toybox APIs: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording`
**Storage**: Connect IQ app storage for lightweight preferences only: selected variant and user-adjusted timing defaults; no match history database or network dependency
**Testing**: Monkey C unit tests where supported, Garmin simulator checks, and representative device validation
**Target Platform**: Garmin watch app targeting fenix 6 generation onward when the device supports the chosen API level; exact rugby recording requires Connect IQ API 4.1.6 support, and targets that cannot support either exact rugby or a validated rugby-equivalent fallback are excluded for v1; add other compatible watch lines only after simulator/device validation
**Project Type**: Garmin Connect IQ watch app
**Performance Goals**: All visible timers render from the same state snapshot per display refresh; score/timer actions reflect within one display refresh cycle
**Constraints**: Offline, lightweight watch UI; dark color-blind-friendly layout using Connect IQ XML resources where feasible; haptic critical alerts with same-cycle alert coalescing; minimal files/dependencies; no network or post-match analytics in v1
**Scale/Scope**: Single-referee in-match use across rugby variants including 15s, 7s, 10s, U19, and custom timing adjustments

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Referee-first scope: primary match countdown remains the dominant object; supporting state is limited to match timing, scoring, sanctions, variant setup, haptics, and activity recording.
- [x] Synchronized timebase: plan uses one `MatchClockState` snapshot to derive countdown, count-up active match timer, yellow-card timers, conversion timer, haptic thresholds, and red-card indicator state.
- [x] Simplicity/DRY: rugby variants use shared preset data plus per-match timing overrides; no duplicate branch-per-variant logic.
- [x] Declarative UI resources: match screen structure uses Connect IQ XML layouts for compact round, large round, and rectangular screens; `RugbyTimerView` only binds state into layout drawables.
- [x] Garmin compatibility: API 4.1.6 is selected for exact rugby sport recording; device support must be verified in simulator before adding a target to the manifest.
- [x] Activity recording: use `ActivityRecording.createSession()` with `Activity.SPORT_RUGBY` and `Activity.SUB_SPORT_MATCH`; rugby-equivalent fallback or target exclusion is documented in research and quickstart.
- [x] Regression isolation: plan requires tests/checks for existing timer, scoring, variant, UI, haptic, storage, and activity-recording behavior touched by implementation.
- [x] Accessibility/haptics: dark color-blind-friendly UI, non-color-only sanction distinction, stable watch layout, and 60-second haptic thresholds are planned.

No constitution violations are introduced.

## Project Structure

### Documentation (this feature)

```text
specs/001-rugby-referee-timer/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- ui-interaction-contract.md
`-- checklists/
    `-- requirements.md
```

### Source Code (repository root)

```text
source/
|-- RugbyTimerApp.mc
|-- RugbyTimerView.mc
|-- RugbyTimerDelegate.mc
|-- RugbyLayoutSupport.mc
|-- RugbyGameModel.mc
|-- RugbyVariantConfig.mc
|-- RugbyActivityRecorder.mc
`-- RugbyHaptics.mc

resources/
|-- layouts/
|-- strings/
`-- drawables/

manifest.xml
monkey.jungle
tests/
|-- Test_RugbyGameModel.mc
|-- Test_RugbyVariantConfig.mc
`-- Test_RugbyActivityRecorder.mc
```

**Structure Decision**: Use a single Connect IQ watch app with a small source module set. `RugbyGameModel` owns match state and derived timers, `RugbyVariantConfig` owns variant defaults and overrides, `RugbyTimerView` binds one state snapshot into XML layout drawables, `RugbyLayoutSupport` selects the compact round, large round, or rectangular layout, `RugbyTimerDelegate` maps watch inputs to model actions, `RugbyActivityRecorder` encapsulates FIT session handling, and `RugbyHaptics` gates alert delivery.

## Complexity Tracking

No constitution violations or complexity exceptions are planned.
