# Implementation Plan: Referee Field Controls

**Branch**: `010-referee-field-controls` | **Date**: 2026-04-21 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/010-referee-field-controls/spec.md`

## Summary

Implement three referee-first field controls: undo the latest score/card event from the Back-button match menu, replace automatic period expiry with referee-confirmed time-up overtime, and make the match summary scrollable with newest events shown first. The implementation will extend the existing single match-state model and Back-button menu flow, preserve Select/Start as pause/resume during time-up overtime, keep current-match data in memory only, and add targeted regression coverage for timer expiry, scoring/card rollback, conversion handling, activity save/discard, and watch-scale readability.

## Technical Context

**Language/Version**: Monkey C / Garmin Connect IQ API 4.1.6 minimum, validated with local Connect IQ SDK 9.1.0 build commands when available  
**Primary Dependencies**: Existing Garmin Connect IQ Toybox modules: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording`  
**Storage**: Current match runtime state only; no new persistent storage or match-history database  
**Testing**: Monkey C unit tests where supported, existing smoke/performance checks, and simulator/device validation on representative watch profiles  
**Target Platform**: Garmin watches from fenix 6 onward plus compatible round/rectangular Connect IQ watch profiles already supported by the app manifest  
**Project Type**: Garmin Connect IQ watch app  
**Performance Goals**: One-second visible timer refresh while running/time-up/half-time; no visible drift between countdown, overtime, count-up, card timers, conversion timer, and haptic thresholds; summary scrolling responsive to physical button presses  
**Constraints**: Offline lightweight watch app; physical-button-first flow; dark glanceable UI; no touch-only controls; no new dependencies; no additional telemetry/network behavior  
**Scale/Scope**: Single referee managing one current match across existing rugby variants: 15s, 7s, 10s, and U19

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Referee-first scope: primary match countdown/time-up state remains dominant; undo and summary are Back-button menu actions for in-match decisions.
- [x] Spec traceability: behavior is captured in `specs/010-referee-field-controls/spec.md`.
- [x] Synchronized timebase: countdown, overtime, count-up, card timers, conversion timer, haptics, and expiry logic remain derived from `RugbyGameModel.snapshot(nowMs)` using `System.getTimer()`.
- [x] Simplicity/DRY: reuse existing model/delegate/menu/view patterns; no new dependency or broad abstraction planned.
- [x] Declarative UI resources: menu entries and static strings will use resources; summary layout should reuse or extend resource layout where feasible. Manual drawing is allowed only for dynamic scrolling rows if resource text areas cannot express the required list behavior safely.
- [x] Garmin compatibility: target remains Connect IQ API 4.1.6 minimum, fenix 6 onward; simulator/device coverage documented in quickstart.
- [x] Activity recording: no new recording integration; existing save/discard/export fallback behavior must be regression tested because undo and time-up affect event log and match-end timing.
- [x] Regression isolation: explicit coverage planned for timer expiry, scoring, card lifecycle, conversion flow, match menu actions, summary viewing, activity save/discard, haptics, and small-screen readability.
- [x] Accessibility/haptics: time-up uses text/status plus haptic; card/summary behavior remains readable without color-only meaning.
- [x] Security & Privacy: current-match local data only; no PII, telemetry, network, or persistent match history added.
- [x] Release & Rollback: release validation and rollback path documented in quickstart.
- [x] Dependency & Supply-Chain: no new dependencies; existing SDK/toolchain only.
- [x] Performance Budgets: budgets and validation checks documented below and in quickstart.
- [x] Incident Response & Monitoring: no live monitoring added; field issues handled through existing release/rollback notes and local diagnostic logs.
- [x] Contributor Governance & Approvals: feature follows Spec Kit branch/spec/plan workflow; review expected before implementation.
- [x] Legal & App-Store Compliance: no new licensing, network, telemetry, or export-control surface; Garmin app policy checks remain part of release validation.
- [x] Deprecation & Migration: automatic period ending is intentionally replaced for this feature; no stored data migration needed.

## Project Structure

### Documentation (this feature)

```text
specs/010-referee-field-controls/
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
source/
|-- RugbyGameModel.mc             # State machine, undo, time-up overtime, event log shape
|-- RugbyTimerDelegate.mc         # Back-button menu actions and confirmation routing
|-- RugbyTimerView.mc             # Time-up/overtime status binding and haptic handling
|-- RugbyMatchSummaryView.mc      # Scrollable recent-first summary
|-- RugbyTeamActionDelegate.mc    # Score/card flows regression touchpoint
|-- RugbyConversionView.mc        # Conversion flow regression touchpoint
|-- RugbyHaptics.mc               # Time-up alert pattern reuse/addition
resources/
|-- menus/match_options.xml       # Add undo and ensure summary access menu shape
|-- strings/strings.xml           # Add static labels/status text
|-- layouts/*.xml                 # Use resources for stable summary/time-up text where feasible
tests/
|-- Test_RugbyGameModel.mc        # Timer/undo state tests
|-- match_summary_*_test.mc       # Summary access/scroll ordering tests where supported
|-- perf_check_*.mc               # Existing performance smoke checks
```

**Structure Decision**: Keep the feature in the existing watch-app modules. `RugbyGameModel` remains the single source of truth; UI/delegate files bind and route model state without duplicating timer rules. No new top-level source package or external dependency is needed.

## Phase 0: Research

See [research.md](research.md). Key decisions:

- Add a `timeUp`/overtime state or equivalent explicit state marker rather than auto-ending from `snapshot()`.
- Implement undo as a single latest score/card rollback in the model, not as arbitrary event editing.
- Use the Back-button match menu as the only entry point for undo, summary, and time-up period-end confirmation.
- Render summary newest-first with physical-button scrolling and a bounded row count per screen.

## Phase 1: Design

See [data-model.md](data-model.md) for entity/state details and [contracts/ui-interaction-contract.md](contracts/ui-interaction-contract.md) for physical-button UI contracts.

Design outputs:

- Model state adds a time-up overtime representation and exposes overtime seconds in snapshots.
- Event entries become sufficient to reverse the latest score/card event without guessing from aggregate counters.
- Match menu includes `Undo last event`, `Match summary`, `End half`/`End match` where appropriate, and existing reset/end actions.
- Summary view tracks a scroll offset, displays newest events first, and exits back to prior match context.
- Haptic alert for time-up fires once at regulation expiry and does not repeat on every refresh.

## Post-Design Constitution Check

- [x] Referee-first scope preserved: all new interactions support in-match correction, timing, or review.
- [x] Single synchronized timebase preserved through model snapshot derivation.
- [x] Resource-first UI planned for static menu/status text, with manual drawing justified only for dynamic scrolling list rows.
- [x] Garmin compatibility unchanged; no new SDK modules or target-device requirements.
- [x] Activity recording behavior unchanged except event log content after undo and explicit match-end timing; regression tests planned.
- [x] Performance budget remains feasible because data stays in memory and summary renders only visible rows.
- [x] Security/privacy unchanged: no PII, network, telemetry, or persistent match-history storage.

## Performance Budgets

- Timer refresh: running, half-time, and time-up states refresh visible timers at one-second cadence without visible drift between derived timers.
- Summary responsiveness: physical-button scroll input updates the visible list on the next UI refresh for at least 20 recorded events.
- Memory: event log remains current-match only; summary view renders a bounded number of visible rows and does not duplicate long event lists beyond shallow snapshots.
- Battery/CPU: no additional background timer beyond existing one-second refresh cadence for running/time-up/half-time states; no continuous work while pre-match or reset.
- Binary size: no new dependencies; compiled artifact should remain within the existing project budget and be compared against the previous `.iq`/build artifact during release validation.

## Release, Rollback, and Validation

- Release checklist: build with Garmin SDK, run Monkey C tests, run simulator smoke checks on small and large watch profiles, validate physical-button flows, and verify activity save/discard still works.
- Rollback: revert this feature branch changes to restore prior automatic period-ending behavior if time-up or undo regressions are found before release.
- Post-release verification: run a scripted match covering try/conversion, penalty/drop goal, yellow/red cards, time-up overtime, undo, summary scroll, and match save.
- Emergency patch: disable/hide undo and summary menu additions if rollback of the full feature is too broad, while preserving core timer start/pause/resume behavior.

## Complexity Tracking

No constitution violations are expected. The feature reuses existing model, delegate, resource, and test patterns.
