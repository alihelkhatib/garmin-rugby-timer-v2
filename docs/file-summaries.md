# Source file summaries
Each source file below has a short description and links to relevant specs and tests.

## RugbyLayoutSupport.mc
Layout helper that selects the proper Rez layout for the device family/size.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: TODO (no direct unit test found)

## RugbyActivityRecorder.mc
Small wrapper around ActivityRecording to start/stop/save a recorded match.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: tests/Test_RugbyActivityRecorder.mc

## RugbyTimerView.mc
UI view that renders the main timer and binds model snapshot data into layout drawables.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: TODO (no direct unit test found)

## RugbyCardMenus.mc
Menu delegates for assigning discipline cards (yellow/red) to teams.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: TODO (no direct unit test found)

## RugbyHaptics.mc
Coalescing haptics helper to avoid duplicate vibrations per snapshot.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: TODO (no direct unit test found)

## RugbyConversionView.mc
View and delegate for conversion attempts after a try; presents timer and made/miss actions.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: TODO (no direct unit test found)

## RugbyTimerApp.mc
Connect IQ app entry point that wires model, recorder and initial view.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: TODO (no direct unit test found)

## RugbyGameModel.mc
Core match state machine: timers, scoring, sanctions, snapshots and haptic detection.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: tests/Test_RugbyGameModel.mc

## RugbyVariantConfig.mc
Variant presets and helpers for applying user overrides to match configuration.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: tests/Test_RugbyVariantConfig.mc

## RugbyScoringMenus.mc
Menu delegates for selecting team and score type; routes to score handling flow.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: TODO (no direct unit test found)

## RugbyTimerDelegate.mc
Behavior delegate mapping watch input (buttons/menus) to model actions and navigation.

- Spec: specs/001-rugby-referee-timer/spec.md
- Test: TODO (no direct unit test found)
