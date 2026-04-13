# Quickstart: idle-timer-controls validation

## Prerequisites

- Garmin Connect IQ SDK configured locally.
- Project builds for at least one representative small round and one large round watch profile, including fenix 6.
- Test app includes Monkey C tests under `tests/`.

## Build And Test

1. Build the app with the Garmin Connect IQ toolchain for a representative target device.
2. Run Monkey C tests and confirm existing model/variant tests still pass.
3. Run simulator checks on representative small and large round watch profiles.
4. Install on a physical device when available, with fenix 6 as the baseline validation target.

## Idle Timer Adjustment

1. Launch the app and ensure the match has not started.
2. Select a known variant and note that variant's normal half length.
3. Press Up/Menu once while the timer is below the selected variant's normal half length.
4. Confirm the main timer increases by 1 minute and the score dialog does not open.
5. Press Down once while the timer is above 00:00.
6. Confirm the main timer decreases by 1 minute and the score dialog does not open.
7. Repeat Down until 00:00, press Down again, and confirm the timer remains 00:00.
8. Repeat Up/Menu until the selected variant's normal half length, press Up/Menu again, and confirm the timer remains at that normal half length.

## Match Start

1. Adjust the idle timer to a value between 00:00 and the selected variant's normal half length.
2. Press Select/Start from the idle screen.
3. Confirm the match begins from the adjusted timer value.
4. Repeat from the idle screen without making an adjustment and confirm Select/Start still begins the match from the visible timer value.
5. Confirm existing activity recorder start behavior is unchanged.

## Active Match Scoring Regression

1. With the match running, open the score dialog through the existing Up/Menu path and record a score.
2. Pause the match, open the score dialog, and confirm scoring remains available.
3. End the half when another half remains, open the score dialog, and confirm scoring remains available in the half-ended state.
4. End the match and confirm physical-button paths no longer open the score dialog.

## Visual Validation

1. Confirm idle timer changes remain readable on all tested watch profiles.
2. Confirm no layout jump hides or overlaps the main timer after repeated button presses.
3. Confirm the main timer is visually centered in the primary timer area on representative round watch profiles.
4. Confirm raw internal state labels such as `notStarted` do not appear on the idle screen; any status shown is referee-facing or omitted.
5. Confirm no existing card timer, conversion timer, haptic alert, or score display behavior regresses during active-match tests.

## 2026-04-13 Validation Notes

- Compile: Passed for `fenix7` with Garmin Connect IQ SDK 9.1.0 using a temporary local signing key: `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7.prg -y /tmp/codex-garmin-rugby-timer-key.der -w`. Existing warnings remain for invalid manifest device ids only.
- Unit-test compile: Passed for `fenix7` with `-t`: `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7-test.prg -t -y /tmp/codex-garmin-rugby-timer-key.der -w`. Existing warnings remain for invalid manifest device ids only.
- Simulator run: Blocked because `monkeydo build/garmin-rugby-timer-fenix7-test.prg fenix7 -t` could not connect to the Connect IQ simulator.
- Follow-up regression fix: App and unit-test compiles were rerun after adding raw physical-key routing for Up/Menu, Down, and Select/Start, removing the raw `notStarted` idle status text, and recentering the resource-backed main countdown label. Both compiles passed with invalid manifest device-id warnings only.
- Runtime idle adjustment, readability, activity recorder start/stop, memory, CPU, battery, and small/large round profile checks remain pending until the simulator or a physical device is available.
- Security/privacy check: No new network access, telemetry, external storage, PII, dependency, or permission surface was added by this feature.
