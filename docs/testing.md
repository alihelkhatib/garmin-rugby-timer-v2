# Testing and Validation

## Automated tests

Tests use Toybox.Test and are compiled separately from production through `tests/monkey.jungle`.

```powershell
monkeyc -f tests/monkey.jungle -d fenix6 -o build/rugby-tests-fenix6.prg -y C:\path\developer_key.der -t -l 0
connectiq
monkeydo build/rugby-tests-fenix6.prg fenix6 /t
```

The final line must report all tests passed. The validation script type-checks production at level 1 and tests at level 0 because Toybox.Test assertions over dynamic snapshot dictionaries otherwise produce non-actionable container-inference warnings.

Coverage includes:

- Variant defaults and adjustment bounds.
- Start, pause, resume, delayed period transition, final match end, and reset.
- Timestamp-derived countdown/count-up and backward-time clamping.
- Scoring, corrections, conversions, sanctions, one-shot yellow-card warning/expiry patterns, and event log.
- One-shot resume confirmation haptics and ended-match timer reset with retained score/event summary.
- Yellow-card carry across half-time and wall-time conversion behavior.
- Input state gates and destructive confirmation flows.
- Recorder fallback, heart-rate lifecycle, terminal behavior, readable FIT event mapping, deduplication, correction export, and recovery priming.
- One-shot automatic match save.
- Valid, malformed, and running-to-paused recovery.

## Build matrix

```powershell
.\scripts\validate.ps1 -DeveloperKey C:\path\developer_key.der -SkipTests
```

This compiles `fenix6`, `fenix7`, and `instinct2` with warnings, informative type checking, and build stats. It also rejects tracked app packages, signing keys, backup files, and source/test placeholder markers.

## Simulator smoke test

On each representative shape:

1. Verify pre-match variant selection and both adjustment bounds.
2. Start, pause, wait for a reminder, resume, and deliberately delay a redraw.
3. Add all score types; make and miss conversions.
4. Issue multiple yellow cards and a red card, then cross half-time.
5. Verify the automatic final transition saves and opens the summary once.
   Confirm the main countdown returns to the selected period duration, auxiliary timers clear, and the final score/events remain in the summary.
6. Relaunch during an active match and verify it restores paused.
7. Reset and verify score, events, activity session, and recovery are cleared.
8. Inspect the main, paused, half-time, conversion, confirmation, and summary layouts for clipping. On Instinct 2, verify that no team or clock text enters the upper-right circular inset.
9. Start a match with simulator GPS unavailable and verify the GPS status is non-fatal while timing, scoring, and navigation continue normally.
   Before kickoff, verify the compact status changes among `GPS WAIT`, `GPS READY`, and `GPS OFF` without showing distance.
10. Open match options, exercise End period and Undo last event, then choose Exit & save; relaunch and verify the match is recovered and can resume in a new recording segment.
11. Choose Stop & exit, cancel once with Back, then confirm it; verify the app closes and the completed match is not restored on relaunch.
12. With a recording active, add a try, conversion, card, and undo; save the activity and inspect its event-generated laps/developer fields when the simulator FIT viewer supports them.

## Physical-device release checks

Simulator success does not replace checks on at least one supported watch:

- Haptic patterns and pause reminders.
- Button mapping and accidental double input.
- Display sleep/wake and foreground/background behavior.
- FIT activity creation, save, and discard.
- GPS lock, route presence, and elapsed-distance/mileage agreement with the saved FIT activity within normal Garmin tolerance.
- For the route/map check, perform the test outdoors, wait for `GPS READY`, move far enough to produce multiple position samples, and record for at least one minute before saving.
- Inspect the saved FIT session and confirm native `sport=rugby` on a runtime that exposes it, or `sport=soccer` on the Fēnix 6 compatibility path; both use `sub_sport=match` and the name `Rugby Match`. Confirm non-zero native position records and non-zero distance before evaluating Garmin Connect map rendering.
- Heart-rate samples throughout the saved activity, allowing for normal optical-sensor startup and dropouts.
- Event-generated laps with rugby event, match time, period, home score, and away score developer fields; confirm that an undo produces one additional `Undo ...` row and that resumed segments do not duplicate earlier events.
- Active Exit & save followed by relaunch/resume, including the expected separate FIT activities.
- Confirmed Stop & exit followed by Garmin Connect FIT inspection and a clean relaunch without recovery.
- After saving, disconnect USB and initiate a Garmin Connect Mobile sync before reconnecting the watch. Confirm the Fēnix 6 activity appears as Soccer / Rugby Match; USB mass-storage connection does not itself upload an activity.
- Issue a yellow card while running, resume the match, and verify the double-pulse warning at 60 seconds remaining and stronger triple-pulse alert at zero. The countdown must remain stationary while match time is paused.
- Full-length match drift and battery impact.
- Recovery after app exit and device interruption.

Garmin Connect has no native rugby event timeline. These fields use the Connect IQ FIT contributor mechanism and `displayInActivityLaps`; exact visibility can differ between Garmin Connect clients and third-party FIT viewers.
