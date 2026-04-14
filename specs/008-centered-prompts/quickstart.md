# Quickstart: Center Prompts for Round Screens

## Build

From the repository root, compile the app with the configured Garmin SDK:

```bash
monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7.prg -y /tmp/codex-garmin-rugby-timer-key.der -w
```

If a test artifact is needed, build it as well:

```bash
monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7-test.prg -t -y /tmp/codex-garmin-rugby-timer-key.der -w
```

## Validation Scenarios

1. Open each affected match-control prompt or dialog on a representative circular watch profile and confirm the full text and choices are visible without clipping.
2. Repeat the same prompts/dialogs on a representative square watch profile and confirm the layout remains readable and the same actions are available.
3. Exercise the source screens that launch the prompts/dialogs and verify the selection flow and back/cancel behavior are unchanged.
4. Validate the conversion prompt, score-team flow, card-team flow, match options, and variant menu on round and square profiles if they are part of the affected bottom-placement set.

## Pass Criteria

- No affected dialog is clipped on circular screens.
- No existing prompt flow changes its action semantics.
- Square-screen behavior remains readable and functionally equivalent.
