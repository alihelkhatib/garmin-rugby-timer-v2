# Quickstart: Rehabilitation Validation

## Prerequisites

- Garmin Connect IQ SDK 8.3.0 or newer on `PATH`.
- A private RSA 4096-bit developer key in DER format outside the repository.
- A downloaded device profile for each selected simulator target.

## Build representative application targets

```powershell
monkeyc -f monkey.jungle -d fenix6 -o build/rugby-fenix6.prg -y C:\path\developer_key.der -w -l 1
monkeyc -f monkey.jungle -d fenix7 -o build/rugby-fenix7.prg -y C:\path\developer_key.der -w -l 1
monkeyc -f monkey.jungle -d instinct2 -o build/rugby-instinct2.prg -y C:\path\developer_key.der -w -l 1
```

## Compile and run unit tests

Use the rehabilitation's explicit test jungle/target and the same developer key. Run the resulting test PRG in at least one representative simulator and retain the PASS/FAIL console output.

## Required smoke flow

1. Launch with no recovery data and select every rugby variant.
2. Adjust the pre-match clock at both bounds.
3. Start, pause, wait through a reminder, resume, and verify no visible drift.
4. Record every score type; make and miss conversions; issue multiple yellow cards and a red card.
5. Cross a period boundary after a deliberately delayed refresh and start the next period.
6. Exit/relaunch during a match and verify paused recovery.
7. End and save; inspect the event summary; repeat callbacks to verify no duplicate save.
8. Reset and verify recovery/activity data is discarded.

## Final evidence

- Compiler output for compact round, large round, and rectangular targets.
- Unit-test output.
- Build stats and full-match timer/timer-count observations.
- Simulator screenshots for main, paused, half-time, conversion, and summary screens.
- Updated `CLEANUP_NOTES.md` with remaining device-only limitations.
