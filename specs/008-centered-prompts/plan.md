# Implementation Plan: Center Prompts for Round Screens

**Branch**: `007-auto-period-transition` | **Date**: 2026-04-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-centered-prompts/spec.md`

## Summary

Adjust affected match-control prompts and dialogs so they remain fully visible on circular Garmin watch screens. The safest approach is to shift the clipped bottom-aligned UI into a centered visible region for the affected dialogs, while preserving the same choice flow and behavior on square screens. Reuse the existing menu and view structure with minimal layout changes and no new persistence, networking, or unrelated UI redesign.

## Technical Context

**Language/Version**: Monkey C / Garmin Connect IQ SDK 4.1.6 minimum, matching the current app baseline  
**Primary Dependencies**: Garmin Connect IQ Toybox modules already used by the app: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording`  
**Storage**: No new storage; current runtime state only  
**Testing**: Monkey C unit tests where practical plus Garmin simulator checks on representative round and square watch profiles  
**Target Platform**: Garmin watches from fenix 6 onward and other already-supported Connect IQ watch lines  
**Project Type**: Garmin Connect IQ watch app  
**Performance Goals**: Keep dialog visibility changes layout-stable with no noticeable interaction delay or new rendering drift  
**Constraints**: Lightweight offline watch app; preserve existing flows; use declarative resources for static layout where feasible; avoid broad UI redesign  
**Scale/Scope**: Single-referee in-match use; scope limited to prompt/dialog placement for affected bottom-screen UI elements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Referee-first scope: change is limited to visibility of match-control prompts/dialogs and does not alter match timing, scoring, or other referee controls.
- [x] Spec traceability: behavior is captured in `specs/008-centered-prompts/spec.md`.
- [x] Synchronized timebase: unchanged; the feature does not introduce new timers or alternate update loops.
- [x] Simplicity/DRY: reuse existing menu and view flows; no speculative abstractions or extra data model.
- [x] Declarative UI resources: adjust resource-backed layouts and menu presentation where possible; only use Monkey C view logic if a screen cannot be expressed cleanly in resources.
- [x] Garmin compatibility: target compatibility remains the same watch set and SDK baseline.
- [x] Activity recording: unaffected.
- [x] Regression isolation: existing prompt flows, match controls, scoring, carding, and variant selection must continue to work unchanged except for placement.
- [x] Accessibility/haptics: this change improves readability on round screens and does not alter card distinctions or haptic behavior.
- [x] Security & Privacy: local UI-only change; no new data collection or transmission.
- [x] Release & Rollback: standard Connect IQ build/release flow applies; rollback is reverting this feature branch.
- [x] Dependency & Supply-Chain: no new dependencies.
- [x] Performance Budgets: limited to small UI layout adjustments; no additional background processing.
- [x] Incident Response & Monitoring: no external monitoring changes.
- [x] Contributor Governance & Approvals: follows existing Spec Kit planning flow.
- [x] Legal & App-Store Compliance: no new licensing or export concerns.
- [x] Deprecation & Migration: no user data migration needed.

## Project Structure

### Documentation (this feature)

```text
specs/008-centered-prompts/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- checklists/
|   `-- requirements.md
`-- tasks.md             # Not created by /speckit.plan
```

### Source Code (repository root)

```text
source/                  # Monkey C application code
resources/               # Connect IQ XML layouts, menus, strings, drawables
manifest.xml             # Connect IQ device/app manifest
monkey.jungle            # Build configuration
tests/                   # Monkey C tests where supported
```

**Structure Decision**: Keep the existing Connect IQ app structure. Expect the implementation to touch `resources/layouts/layout.xml` and any affected menu resources under `resources/menus/` for centered, screen-safe placement; `source/RugbyConversionView.mc`, `source/RugbyTimerDelegate.mc`, and related menu/delegate files only if a particular prompt needs placement logic or a different navigation path; and existing tests where dialog routing or readability can be validated.

## Complexity Tracking

No constitution violations. The feature is a narrow UI placement correction and does not require additional storage, network behavior, scheduler changes, or new abstractions.

## Phase 0: Research

See [research.md](research.md). Decisions resolved: which prompts/dialogs are actually at risk of clipping, whether centering should be applied only on round screens or across all screens, how to preserve existing menu flow, and what validation best demonstrates the readability fix.

## Phase 1: Design

See [data-model.md](data-model.md) and [quickstart.md](quickstart.md). No external contracts are needed because this feature only changes in-app UI placement.

## Post-Design Constitution Check

- [x] Referee-first scope remains bounded to readability of existing prompts/dialogs.
- [x] Declarative resource-first approach remains the default, with view logic reserved only if needed for a specific screen.
- [x] No new persistence, telemetry, network, or activity-recording behavior introduced.
- [x] No new dependencies, timers, or broad UI framework changes introduced.
