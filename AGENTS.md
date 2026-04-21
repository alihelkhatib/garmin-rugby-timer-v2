# rugby-timer-v2 Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-04-21

## Active Technologies
- Monkey C / Garmin Connect IQ API 4.1.6 minimum + Garmin Connect IQ Toybox modules already used by the app: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording` (003-idle-timer-controls)
- Existing local setup/preferences behavior only; this feature does not add new persistence (003-idle-timer-controls)
- Monkey C / Garmin Connect IQ API 4.1.6 minimum, validated with local Connect IQ SDK 9.1.0 build commands + Garmin Connect IQ Toybox modules already used by the app: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording` (005-match-event-management)
- In-memory current-match event log; no new persistent app storage. Best-effort saved-activity event export uses existing activity-recording capability if supported, with in-app match-end review fallback. (005-match-event-management)
- Current match runtime state only; no new persistent app storage (007-auto-period-transition)
- Monkey C / Garmin Connect IQ SDK 4.1.6 minimum, matching the current app baseline + Garmin Connect IQ Toybox modules already used by the app: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording` (007-auto-period-transition)
- No new storage; current runtime state only (007-auto-period-transition)
- Monkey C / Garmin Connect IQ SDK 4.1.6 minimum + `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, `ActivityRecording` (001-rugby-referee-timer)
- Connect IQ app storage only for lightweight preferences and unsupported-recording fallback; no match-history database (001-rugby-referee-timer)
- Monkey C / Garmin Connect IQ API 4.1.6 minimum, validated with local Connect IQ SDK 9.1.0 build commands when available + Existing Garmin Connect IQ Toybox modules: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording` (010-referee-field-controls)
- Current match runtime state only; no new persistent storage or match-history database (010-referee-field-controls)

- Monkey C / Garmin Connect IQ API 4.1.6 minimum for `Activity.SPORT_RUGBY` + Garmin Connect IQ Toybox APIs: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording` (001-rugby-referee-timer)

## Project Structure

```text
source/                  # Monkey C application code
resources/               # Connect IQ XML resources, layouts, strings, drawables
manifest.xml             # Connect IQ app/device manifest
monkey.jungle            # Connect IQ build configuration
tests/                   # Monkey C tests where supported
```

## Commands

- Build with the Garmin Connect IQ SDK toolchain for each validated target device.
- Run simulator checks on representative small and large round Garmin watch profiles.
- Run Monkey C tests where supported for model, variant, activity-recording, and timer behavior.

## Code Style

- Follow standard Monkey C and Garmin Connect IQ conventions.
- Keep timing logic in a shared match-state model so all visible timers derive from one state snapshot.
- Keep variant defaults in shared configuration rather than per-variant branches.
- Keep screen structure, static text, colors, fonts, and stable positions in Connect IQ resources where feasible; Monkey C views should bind state into those resources instead of manually drawing layouts.
- Before implementing behavior changes, update the active Spec Kit spec when the change belongs to it, or create a new spec when it is a distinct feature.
- Avoid network dependencies, heavy analytics, and generated clutter for v1.

## Recent Changes
- 010-referee-field-controls: Added Monkey C / Garmin Connect IQ API 4.1.6 minimum, validated with local Connect IQ SDK 9.1.0 build commands when available + Existing Garmin Connect IQ Toybox modules: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording`
- 001-rugby-referee-timer: Added Monkey C / Garmin Connect IQ SDK 4.1.6 minimum + `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, `ActivityRecording`
- 007-auto-period-transition: Added Monkey C / Garmin Connect IQ SDK 4.1.6 minimum, matching the current app baseline + Garmin Connect IQ Toybox modules already used by the app: `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording`


<!-- MANUAL ADDITIONS START -->
## Implementation Notes

- Connect IQ CLI commands (`monkeyc`, `monkeydo`, `connectiq`) were not available on PATH during the 2026-04-12 implementation pass, so SDK build, simulator, and device validation must be run after the Garmin SDK environment is configured.
- Current app files are intentionally small: `RugbyGameModel` owns match state/timer derivation, `RugbyVariantConfig` owns presets/preferences, `RugbyTimerView` renders one snapshot, `RugbyTimerDelegate` maps watch actions, `RugbyHaptics` coalesces alerts, and `RugbyActivityRecorder` owns the FIT session.
<!-- MANUAL ADDITIONS END -->
