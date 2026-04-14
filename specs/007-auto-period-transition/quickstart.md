# Quickstart: Auto Period Transition

## Build

From the repository root, compile the app and test artifacts with the configured Garmin SDK:

```bash
monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7.prg -y /tmp/codex-garmin-rugby-timer-key.der -w
monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7-test.prg -t -y /tmp/codex-garmin-rugby-timer-key.der -w
```

Run the test artifact in a simulator when available:

```bash
monkeydo build/garmin-rugby-timer-fenix7-test.prg fenix7 -t
```

## Scenario 1: Non-Final Period Auto-End

1. Select a variant with another period remaining.
2. Start the first period.
3. Let the main countdown reach 00:00.
4. Confirm the app enters the existing between-period flow without pressing an end-period action.
5. Confirm the half-time timer appears at 00:00 and begins counting elapsed break time upward.
6. Confirm the main match countdown remains stopped while the half-time timer runs.
7. Start the next period using the existing start-next-period flow.
8. Confirm the next period starts with the correct period number and countdown, and the half-time timer stops or leaves view.

## Scenario 2: Final Period Auto-End

1. Start or advance to the final configured period.
2. Let the main countdown reach 00:00.
3. Confirm the app enters the existing match-ended summary/save flow without pressing an end-match action.
4. Confirm the final score, event log, card state, and activity-save behavior match the state at expiry.

## Scenario 3: Yellow Card Carries Into Next Period

1. Start a non-final period.
2. Issue a yellow card near the end of the period.
3. Let the main countdown reach 00:00 before the yellow-card timer expires.
4. Confirm the yellow-card timer pauses and remains associated with the same team during the period break.
5. Confirm the half-time timer advances during the break while the yellow-card timer remaining time does not decrement.
6. Start the next period.
7. Confirm the yellow-card timer is present and resumes from the preserved remaining time.

## Scenario 4: Deliberate Non-Final Period End Shows Half-Time Timer

1. Start a non-final period.
2. Use the existing deliberate end-period action before the countdown reaches 00:00.
3. Confirm the app enters the between-period flow.
4. Confirm the half-time timer starts at 00:00 and counts elapsed break time upward.
5. Start the next period.
6. Confirm the half-time timer stops or leaves view and active match timing resumes normally.

## Scenario 5: Multiple And Expired Yellow Cards

1. Start multiple yellow-card timers across Home and Away before a non-final period ends.
2. Let the period expire.
3. Confirm every unexpired yellow-card timer carries into the next period with its team and remaining time preserved.
4. Repeat with a yellow-card timer that reaches 00:00 before or on the same update as period expiry.
5. Confirm the expired timer is not revived in the next period.

## Scenario 6: Paused At Boundary

1. Pause the match at or near 00:00.
2. Allow the screen to refresh while paused.
3. Confirm the app does not unexpectedly auto-end the period or match due only to the paused refresh.
4. Use an explicit end action or resume into the expiry boundary.
5. Confirm the expected end-period or end-match transition occurs.

## Scenario 7: Regression Sweep

1. Verify manual end-period and end-match flows still work.
2. Verify scoring, conversion timer, card entry, pause/resume, haptic alerts, event log, variant selection, and activity recording still behave as before.
3. Validate representative small and large round watch screens for readable between-period and match-ended states with the half-time timer and carried yellow-card timers.
