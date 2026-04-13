# Quickstart: Match Event Management

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

## Scenario 1: Automatic Conversion From Paused Try

1. Start a match.
2. Press Select/Start to pause.
3. Open score controls and record a Home try.
4. Confirm the conversion overlay opens and the countdown starts without pressing Select.
5. Repeat for Away.
6. Record penalty goal and drop goal actions and confirm they do not open the conversion overlay.

## Scenario 2: Conversion Overlay Layout

1. Open the conversion overlay after a try.
2. Confirm the conversion timer is higher than before and does not clip or overlap the made/miss hints.
3. Confirm the main match screen layout is unchanged.

## Scenario 3: Pause Haptics And Reminders

1. Start a match.
2. Press Select/Start to pause.
3. Confirm immediate pause vibration when haptics are available.
4. Leave the match paused for 30 seconds.
5. Confirm at least two reminder vibrations occur.
6. Resume, end, or reset and confirm reminders stop.

## Scenario 4: Card Issue Pauses Match

1. Start a match.
2. Issue a yellow card while running.
3. Confirm the match pauses and the yellow-card timer/event are recorded.
4. Resume and issue a red card.
5. Confirm the match pauses and a red-card event is recorded without a persistent red-card timer.

## Scenario 5: Event Log And Match Summary

1. Record try, made conversion, penalty goal, drop goal, yellow card, and red card events.
2. End the match from Back options.
3. Confirm the match summary shows team, action, and match elapsed time for each event in order.
4. Confirm missed conversions or navigation actions are not logged.
5. Confirm activity save still succeeds if activity event export is unsupported.

## Scenario 6: Back Options

1. Press Back during an active match.
2. Cancel and confirm the match remains unchanged.
3. Press Back again and choose End match; confirm the match ends and saves.
4. Start another match, create runtime state, then press Back and choose Reset match.
5. Confirm scores, timers, cards, conversion state, pending actions, event log, and unsaved current activity are cleared.
