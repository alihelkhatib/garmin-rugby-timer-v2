# rugby-timer-v2 Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-09-19

## Active Technologies
- Monkey C with a Connect IQ API 3.4.0 compatibility floor, validated with local SDK 8.3.0.
- Built-in Toybox `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, `ActivityRecording`, and `Position`; no third-party libraries.
- `Application.Storage` for variant preferences and a compact active-match/distance recovery snapshot; no network or external database.

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
- 011-codebase-rehabilitation: consolidated match timing, recovery, validation, resources, executable tests, and the supported device matrix.


<!-- MANUAL ADDITIONS START -->
## Implementation Notes

- SDK 8.3.0 CLI builds and simulator tests are available on PATH in the validated development environment.
- Current app files are intentionally focused: `RugbyGameModel` owns match state and timer derivation, `RugbyMatchController` owns periodic evaluation/persistence side effects, `RugbyVariantConfig` owns presets/preferences, views render snapshots, delegates map watch actions, `RugbyHaptics` coalesces alerts, and `RugbyActivityRecorder` owns GPS, elapsed distance, and the FIT session.
<!-- MANUAL ADDITIONS END -->
