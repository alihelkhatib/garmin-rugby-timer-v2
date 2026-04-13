# Test Results

## 2026-04-13 Idle Timer Controls

- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7.prg -y /tmp/codex-garmin-rugby-timer-key.der -w`: PASS with existing warnings for invalid manifest device ids and dynamic container type inference.
- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7-test.prg -t -y /tmp/codex-garmin-rugby-timer-key.der -w`: PASS with existing warnings for invalid manifest device ids and dynamic container type inference.
- `monkeydo build/garmin-rugby-timer-fenix7-test.prg fenix7 -t`: BLOCKED, unable to connect to simulator.

Coverage added:

- Idle timer lower and upper bounds in `tests/Test_RugbyGameModel.mc`.
- Match start from an adjusted idle timer in `tests/Test_RugbyGameModel.mc`.
- Score action regression after idle timer adjustment in `tests/Test_RugbyGameModel.mc`.
- Variant normal-half bounds in `tests/Test_RugbyVariantConfig.mc`.
- Idle Up/Menu, idle Down, match-ended block, active score dialog, and active card dialog state gates in `tests/Test_RugbyIdleTimerControls.mc`.
