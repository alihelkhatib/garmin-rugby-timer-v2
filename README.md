# Garmin Rugby Timer V2

Rugby Timer V2 is an offline Garmin Connect IQ watch app for referees. It keeps the match countdown, elapsed playing time, scores, tries, conversions, yellow-card timers, red-card indicators, period transitions, haptics, activity recording, and match event summary synchronized from one match model.

## Match controls

- Before kickoff: Up adds one minute and Down subtracts one minute, bounded by zero and the selected variant's normal period length.
- Before kickoff: Menu opens the variant picker for 15s, 7s, 10s, or U19.
- Before kickoff: the status line shows `GPS WAIT`, `GPS READY`, or `GPS OFF`; wait for `GPS READY` before an outdoor match when a Garmin Connect route/map is required.
- Select/Start: starts, pauses, or resumes the current period; it also confirms a clearly labelled pending End or Reset action. Resuming a paused match gives one short confirmation vibration.
- During an active match: Up opens scoring and Down opens cards. A try starts the conversion countdown.
- Back: exits normally before kickoff and after completion. During an active match it opens End period, End match, Stop & exit, Undo last event, Match summary, Reset match, and Exit & save.
- Stop & exit requires confirmation, ends the match, saves its FIT activity, clears recovery, and closes the app.
- Exit & save writes the current FIT segment and a recovery checkpoint before closing. Relaunch restores the match paused or between periods; resuming starts a new FIT segment.
- Conversion view: Up/Menu records a made conversion; Down or Back records a miss.

Cards pause a running match. Yellow-card time advances only with active match time and pauses during stoppages and between periods. Conversion time follows monotonic wall time, including while the match clock is paused. Reaching zero while running advances to half-time or ends the final period automatically.
Each yellow card gives a distinct double-pulse warning at 60 seconds remaining and a stronger triple-pulse alert at expiry. Because issuing a card pauses a running match, resume the match clock for its active-time countdown to continue.
When a match ends manually or automatically, the main countdown returns to the selected period duration and conversion/card timers clear. Final scores and event history remain available in the match summary and saved activity.

## Architecture

- `RugbyGameModel` is the authoritative state machine. `advance(nowMs)` applies time-driven transitions; `snapshot(nowMs)` is a read-only UI projection.
- `RugbyTime` owns elapsed-time guards and clock formatting.
- `RugbyMatchController` coordinates periodic advancement, one-shot automatic activity save, persistence, and summary requests.
- `RugbyPersistence` and `RugbyVariantConfig` store a versioned match checkpoint and preferences. A running match restores paused so relaunch never invents unobserved playing time.
- `RugbyTimerDelegate` and menu delegates translate input into model operations.
- Views bind resource layouts and own only visible refresh/reminder timers. Timers stop when a view hides.
- `RugbyActivityRecorder` wraps Garmin GPS and heart-rate acquisition plus the supported start/stop/save/discard lifecycle. Garmin supplies the route, elapsed distance, and heart-rate samples to the saved FIT activity; mileage and heart rate are intentionally not added to the match UI. Scores, conversions, cards, and corrections are also written as best-effort FIT developer fields on event-generated laps.

```text
input -> model mutation -> persistence
timer callback -> controller tick -> model advance -> snapshot -> render
                                      |-> one-shot save / summary request
```

## Supported and validated profiles

The manifest intentionally lists only the profiles currently validated by the local build matrix:

- Fēnix 6 — compact round, API compatibility baseline
- Fēnix 7 — larger modern round
- Instinct 2 — compact monochrome display with a circular upper-right inset and device-specific layout/icon

The code targets Connect IQ API 3.4.0 or newer and is currently validated with SDK 8.3.0. Modern runtimes use Garmin's native rugby sport metadata. Older runtimes such as Fēnix 6 use supported `soccer` + `match` compatibility metadata with the activity name `Rugby Match`; this mirrors the reliable field-sport recording path used by FC Timer and avoids submitting a sport enum the firmware does not know. Garmin Connect will consequently classify Fēnix 6 recordings as Soccer rather than native Rugby. Additional devices should be added only after build, simulator layout, memory, and input validation.

## Build and test

Generate or select a Garmin RSA 4096-bit DER developer key outside the repository, then run:

```powershell
.\scripts\validate.ps1 -DeveloperKey C:\path\developer_key.der -SkipTests
```

Compile the unit-test application and run it in an open Connect IQ simulator:

```powershell
monkeyc -f tests/monkey.jungle -d fenix6 -o build/rugby-tests-fenix6.prg -y C:\path\developer_key.der -t -l 0
monkeydo build/rugby-tests-fenix6.prg fenix6 /t
```

See [docs/DEVELOPER.md](docs/DEVELOPER.md) for setup and architecture details, [docs/testing.md](docs/testing.md) for the complete validation flow, and [docs/RELEASING.md](docs/RELEASING.md) for release gates.

## Privacy and limitations

The app has no network access, analytics, or telemetry. While a match is recording, Garmin records the GPS route, distance, and available heart-rate samples into the FIT activity. The app also adds team-relative rugby event labels, match time, period, and score as FIT developer fields. It stores variant preferences, an active-match checkpoint, and cumulative distance needed for recovery. Reset removes the checkpoint; Garmin controls saved activity retention.

Known limits:

- Garmin Connect has no native rugby score/card event type. The app represents events as activity laps with Connect IQ developer fields; visibility varies by Garmin Connect/FIT viewer, and the in-app summary remains authoritative.
- Garmin Connect synchronization happens after Garmin saves the FIT file and is controlled by the watch/mobile sync pipeline. Disconnect USB and run a Garmin Connect Mobile sync after saving; the app itself cannot upload while acting as a USB drive.
- Exiting and later resuming an active match creates separate FIT activities because a Garmin recording session cannot survive process termination.
- A process interruption restores a running match paused. Conversion countdown recovery preserves the last checkpointed remaining time rather than guessing time elapsed while the app was not executing.
- Physical-device haptic, battery, activity-file, and long-duration validation remains part of the release checklist even when simulator tests pass.
