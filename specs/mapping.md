# Spec-to-Source Mapping (scaffold)

Purpose: initial candidate mapping from spec folders to implementing source files. Use this as a starting point for owners to confirm and refine.

## specs/001-rugby-referee-timer
Candidate implementing files (high-confidence):
- source/RugbyGameModel.mc — core match state, countdowns, conversion and sanction timers
- source/RugbyVariantConfig.mc — variant presets and overrides (15s, 7s, 10s, U19, custom)
- source/RugbyTimerView.mc — rendering of dominant countdown, count-up, and auxiliary timers
- source/RugbyTimerApp.mc — app lifecycle and ties to activity recording
- source/RugbyTimerDelegate.mc — input/action routing and menu wiring
- source/RugbyActivityRecorder.mc — FIT session wrapper and recording lifecycle
- source/RugbyHaptics.mc — haptic thresholds and alert delivery
- source/RugbyScoringMenus.mc — scoring dialogs/menus
- source/RugbyConversionView.mc — conversion timer UI and flow
- source/RugbyCardMenus.mc — discipline/discipline menus (yellow/red)
- source/RugbyLayoutSupport.mc — XML layout binding helpers
- resources/layouts/layout.xml — primary layout used by RugbyTimerView
- resources/menus/* — XML menu definitions referenced by card/score flows
- resources/strings/strings.xml — localized strings
- tests/Test_RugbyGameModel.mc, tests/Test_RugbyVariantConfig.mc, tests/Test_RugbyActivityRecorder.mc — unit/integration tests referenced by tasks

Confidence: HIGH — these files are explicitly referenced in `specs/001` tasks.md and plan.md.

## specs/002-fenix-6-support
Candidate implementing files (high-confidence):
- manifest.xml — product list, minSdkVersion, Fit permission
- resources/layouts/layout.xml — layout adjustments and device-specific layout variants
- source/RugbyTimerView.mc — UI sizing/legibility tweaks
- source/RugbyLayoutSupport.mc — helper logic for layout/device differences
- source/RugbyHaptics.mc — haptic tuning for fenix devices
- source/RugbyActivityRecorder.mc — device FIT recording checks/fallbacks
- resources/drawables/* — launcher and device graphics where size matters
- monkey.jungle — build targets and device validation configuration

Confidence: MEDIUM — mostly device/manifest and UI-focused changes; tests should be added under a fenix-6 validation task.

## Unmapped / Noted
- No unreferenced `source/` files discovered: all source files are mentioned from `specs/001`.

## How to use this scaffold
- Owners: confirm or correct mappings by adding explicit implementer notes or file pointers in each spec's `plan.md` or `tasks.md` (e.g., `T001: Modify source/RugbyTimerView.mc to adjust fonts for fenix6`).
- When a mapping is confirmed, update `specs/<id>/data-model.md` or `specs/<id>/tasks.md` with explicit file-level tasks and tests.
