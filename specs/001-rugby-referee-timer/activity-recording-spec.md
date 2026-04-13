# Feature Specification: Activity Recording Enhancements

**Feature Branch**: `[activity-recording-enhancements]`
**Created**: 2026-04-13
**Status**: Draft
**Input**: Add per-event FIT markers (lap/marker entries), GPS enabled by default (opt-out per recording and global setting), sidecar JSON fallback for unsupported devices, and permission handling.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Record event markers (Priority: P1)
As a referee, I want each match event (try, conversion, penalty, drop goal, yellow/red card, substitution, stoppage adjustment) recorded as a timestamped session marker so that post-match analysis and uploads include a chronological event list.

Independent Test: Start a recording, trigger a try, conversion, and a yellow card; stop and save the session; verify the exported FIT session contains markers/laps or an attached sidecar JSON with entries matching the expected schema and timestamps.

Acceptance Scenarios:
1. Given a running recording, when a try is recorded, then a marker with event_type=try, team, points_delta=5, elapsed_ms and recorded_at_ms is created and persisted.
2. Given ActivityRecording does not support markers on the device, when the match ends, then a sidecar JSON file is saved in app storage containing the same markers.

---

### User Story 2 - GPS by default, opt-out (Priority: P1)
As a referee, GPS trace should be recorded by default so positioning is available for analysis, but I must be able to disable GPS for a single recording or globally.

Independent Test: Start a recording with default settings; verify GPS trace samples are attached to the saved session. Start a recording after toggling the per-recording GPS-off option; verify no GPS trace is recorded.

Acceptance Scenarios:
1. Default recording includes GPS traces when platform permissions are granted.
2. A per-recording toggle disables GPS for the current session only.
3. A global setting allows the user to disable GPS by default for all recordings.

---

### Edge Cases
- Positioning permission denied: session still records event markers and metadata but no GPS trace.
- Low battery or interrupted recording: partial sessions must save recorded markers and available GPS samples; recorder must not crash.
- Duplicate events emitted rapidly: markers must be deduplicated or recorded with distinct recorded_at_ms.

## Requirements *(mandatory)*

- **FR-AR-001**: The app MUST record per-event markers into the active ActivityRecording session using the platform API when available.
- **FR-AR-002**: Each marker MUST include the following fields: event_type, team (home/away), points_delta (nullable), sanction_id (nullable), conversion_result (made/missed/n/a), elapsed_ms (match elapsed), recorded_at_ms (System.getTimer timestamp).
- **FR-AR-003**: If the platform does not support embedded markers or ActivityRecording is unavailable, the app MUST persist a sidecar JSON file in app storage with identical marker entries tied to a session identifier.
- **FR-AR-004**: GPS traces MUST be collected by default for recordings unless the user explicitly disables GPS for that recording. The recorder MUST request and respect platform positioning permissions before collecting GPS.
- **FR-AR-005**: The app MUST provide a per-recording GPS opt-out toggle and a global setting to change the default behavior for new recordings.
- **FR-AR-006**: The recorder API MUST be resilient: marker writes are non-blocking to the UI thread, persisted reliably, and survive mid-match interruptions.
- **FR-AR-007**: Unit and integration tests MUST verify marker creation, persistence, sidecar fallback, and GPS opt-out behaviors.

## Key Entities

- **RecordingSession**: session object created via ActivityRecording (or placeholder id for sidecar); owns markers and GPS samples.
- **EventMarker**: item with event_type, team, points_delta, sanction_id, conversion_result, elapsed_ms, recorded_at_ms.
- **GPSSample**: latitude, longitude, accuracy, timestamp.
- **RecordingSettings**: per-recording and global flags (gpsEnabledByDefault, perRecordingGpsEnabled).
- **SidecarFile**: JSON file stored in app storage when embedded markers are unavailable.

## Success Criteria *(mandatory)*

- **SC-AR-001**: For supported devices, 95% of automated simulator runs produce saved sessions that contain at least one marker for each emitted event in a canonical test scenario.
- **SC-AR-002**: GPS traces are attached to saved sessions by default when platform permissions are granted in 95% of validation runs; per-recording opt-out must prevent GPS for that session in 100% of tests.
- **SC-AR-003**: Sidecar fallback writes occur on unsupported devices and contain identical marker schemas; tests verify sidecar content matches expected event timestamps and metadata.
- **SC-AR-004**: Recorder recovers gracefully from an interrupted recording (e.g., app stop) in 100% of simulated interruptions and preserves recorded markers up to the interruption point.

## Assumptions

- Toybox.ActivityRecording provides suitable APIs to add markers or laps on supported device targets; if not available, sidecar persistence is acceptable for v1.
- App storage is available to persist small JSON sidecar files; storage size for markers is minimal.
- Privacy: GPS opt-out by user will be clearly documented; recorded GPS is considered sensitive and will not be uploaded without device/user consent during normal device upload flows.


