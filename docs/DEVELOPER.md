# Developer Guide

## Prerequisites

- Garmin Connect IQ SDK 8.3.0 or newer on `PATH` (`monkeyc`, `monkeydo`, `connectiq`).
- Java supported by that SDK.
- A private RSA 4096-bit developer key in DER format stored outside the repository.
- Simulator device profiles for `fenix6`, `fenix7`, and `instinct2`.

Garmin documents command-line key generation as:

```text
openssl genrsa -out developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
```

Never commit the key. Common key filenames are ignored by `.gitignore`.

## Responsibilities

| Concern | Owner |
|---|---|
| Match state, scoring, sanctions, transitions | `source/RugbyGameModel.mc` |
| Timestamp deltas and clock text | `source/RugbyTime.mc` |
| Automatic transition side effects and checkpoints | `source/RugbyMatchController.mc` |
| Storage and recovery | `source/RugbyPersistence.mc`, `source/RugbyVariantConfig.mc` |
| GPS, heart rate, elapsed distance, FIT event fields, ActivityRecording lifecycle | `source/RugbyActivityRecorder.mc` |
| Main input mapping and menus | `source/RugbyTimerDelegate.mc`, team delegates |
| Resource binding and visible refresh timers | `source/RugbyTimerView.mc`, `source/RugbyConversionView.mc` |
| Layout selection | `source/RugbyLayoutSupport.mc`, `resources/layouts/layout.xml` |
| Match-end event display | `source/RugbyMatchSummaryView.mc` |

## State and timing model

The core states are `notStarted`, `running`, `paused`, `halfEnded` (between periods), and `matchEnded`. Only `RugbyGameModel` changes these states.

`advance(nowMs)` is the explicit write boundary for time-driven expiry. `snapshot(nowMs)` derives all visible values from the same timestamp and does not end periods, navigate, save an activity, or vibrate. The controller consumes one-shot auto-match-end state and prevents repeated saves.

The main clock accumulates active playing milliseconds. Yellow cards use that active time, so cards pause with the match and at half-time. Conversions use a monotonic wall-time anchor and therefore continue during a match pause. UI timers merely request evaluation/redraw; they never decrement authoritative counters.

Recovery snapshots fold a running interval into accumulated time and store the state as paused. This is deliberate: it preserves match data without guessing how much rugby was played while the application was unavailable.

The recorder enables continuous `Toybox.Position` updates and `Toybox.Sensor.SENSOR_HEARTRATE` while recording so Garmin's ActivityRecording subsystem captures the GPS track, elapsed distance, and heart-rate samples in the FIT activity. Those metrics are intentionally not rendered in the match UI. Recording begins without waiting for satellite lock; the pre-match status lets the referee wait for `GPS READY` when a complete outdoor route matters. Modern runtimes use native rugby sport metadata, while the Fēnix 6 compatibility runtime uses its supported soccer/match metadata and the name `Rugby Match`. The recorder also creates lap-scoped `Toybox.FitContributor` fields for the rugby event label, match time, period, and score; each event or later correction adds one lap after populating those fields. Garmin Connect does not expose a native rugby event model, so developer-field rendering is best effort and the in-app event log remains authoritative. Recovery retains internal distance metadata; resuming after an app exit starts a new FIT segment because live Garmin sessions are process-bound, and restored historical events are primed so they are not duplicated in the new segment.

## Resources and devices

Static layout, fonts, positions, colors, strings, and menus live in `resources/`. The Instinct 2 launcher override lives in `resources-instinct2/`. Manual drawing is limited to the runtime-sized summary list and red-card marker.

The manifest contains only three validated products. Add a new product only after application and test compilation, simulator layout/input checks, and memory review.

## Spec Kit workflow

Behavior changes require a spec in `specs/`, followed by a plan and dependency-ordered tasks. Keep `CLEANUP_NOTES.md` current for rehabilitation work. Narrow build fixes may precede design only when they restore already-specified behavior.

## Code review expectations

- Check timestamp behavior with delayed callbacks and boundaries.
- Check every touched valid and invalid state transition.
- Check view timer cleanup in `onHide`.
- Check recovery schema compatibility and reset deletion.
- Check recorder terminal calls for idempotence.
- Check GPS acquisition, distance continuity, and Positioning permission behavior.
- Check heart-rate sensor cleanup, one-time FIT event/correction export, and Sensor/FitContributor permissions.
- Compile all manifest products and run the unit-test PRG.
- Do not add unconditional logging, placeholder tests, generated output, secrets, network dependencies, or unvalidated product IDs.
