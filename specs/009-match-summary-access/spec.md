# Feature Specification: Match Summary Access

Terminology: UI label: "Match Summary (Event Log)" — user-facing screens and resource strings SHOULD use exactly this phrasing for the summary view. Canonical code/module name: RugbyEventLog (source/RugbyEventLog.mc). Feature documentation and plan items MUST use "Match Summary (Event Log)" when referring to UI copy and "RugbyEventLog" when referring to the code/module or API.

**Feature Branch**: `009-match-summary-access`  
**Created**: 2026-04-14  
**Status**: Draft  
**Input**: User description: "as a part of this at match end, there should be an option to see the match summary somehow in the menu that ends or resets a match. or perhaps even have the ability to see the event log/event summary at any point in time by using the dialog menu with the back button, would that be a good idea?"

## Clarifications

### Session 2026-04-14

- Q: Should match summary be integrated with ActivityRecording/FIT export? → A: Use existing ActivityRecording/FIT export (RugbyActivityRecorder).
- Q: On devices without ActivityRecording, fallback behavior? → A: Fallback to in-app summary (in-memory events).
- Q: What format should be exported to ActivityRecording (raw vs summary)? → A: Export raw chronological events (type, timestamp, details).
- Q: Should the summary view be scrollable or truncated? → A: Use a scrollable list for summary viewing.
- Q: When should ActivityRecording export occur (timing)? → A: Export at match end (flush events).

### Session 2026-04-15

- Q: Where should canonical event schema normalization occur (model vs exporter)? → A: Model emits canonical keys `type` and `timestamp` (seconds since match start).
- Q: When opening Match Summary from end/reset menu, should the menu be dismissed before showing the summary? → A: Pop/dismiss the menu before pushing the summary view.
- Q: Resource ID naming: should code use the resource name `MatchSummaryLayout` or rename layout to match code? → A: Use `MatchSummaryLayout` and update code to call `Rez.Layouts.MatchSummaryLayout(dc)`.
- Q: Which summary view artifact should be canonical (RugbyMatchSummaryView vs RugbySummaryView)? → A: Consolidate to `RugbyMatchSummaryView` and remove the stub `RugbySummaryView`.
- Q: Export retry persistence policy — should retries persist across restarts or rely on manual retry UI? → A: No persistence; provide a manual post-match retry UI (MVP default).






## User Scenarios & Testing *(mandatory)*

### User Story 1 - Review Match Summary At Match End (Priority: P1)

As a referee who has just finished a match, I need a clear option to view the match summary from the end/reset flow so I can quickly review the recorded events before leaving the match screen.

**Why this priority**: The end-of-match decision point is the safest time to review the event log because the match is already over or about to be reset.

**Independent Test**: End a match or open the match end/reset menu and verify that a match-summary option appears and opens the summary view with the recorded events.

**Acceptance Scenarios**:

1. **Given** a match is active or completed, **When** the referee opens the menu that offers end/reset actions, **Then** a match-summary option is available.
2. **Given** the end/reset menu is open, **When** the referee selects match summary, **Then** the app shows the recorded match summary or event log.
3. **Given** the summary view is open, **When** the referee exits it, **Then** they return to the end/reset menu or the prior match context without losing the recorded events.

---

### User Story 2 - Preserve Existing End And Reset Actions (Priority: P2)

As a referee, I need the new summary option to stay out of the way of end-match and reset actions so I can still finish the match without confusion.

**Why this priority**: The new summary option should add visibility, not make terminal match controls harder to use.

**Independent Test**: Open the end/reset menu and verify the existing end-match and reset choices still work as before, alongside the new summary choice.

**Acceptance Scenarios**:

1. **Given** the end/reset menu is open, **When** the referee chooses end match, **Then** the current end-match confirmation and save flow still work.
2. **Given** the end/reset menu is open, **When** the referee chooses reset match, **Then** the current reset confirmation and discard flow still work.
3. **Given** the summary option is not chosen, **When** the referee uses the menu, **Then** the existing end/reset actions remain the fastest path to finish the match.

### Edge Cases

- The summary option must not prevent the referee from completing the end-match save flow.
- The summary option must not destroy or clear the recorded event log.
- If the match is reset after viewing the summary, the app should still honor the existing reset confirmation behavior.
- If there are no events recorded, the summary view should still be accessible and clearly indicate an empty summary.
- The summary view must support scrolling to view older events; ensure navigation and focus on the most recent event for immediate glanceability.

## Constraints & Tradeoffs

- No new persistent storage; reuse ActivityRecording when available.
- Default export at match end to minimize writes and battery impact.
- Use declarative resource-first UI (per Constitution VII) for layouts where possible.
- Implementation note: Canonical layout resource id for the match summary is `MatchSummaryLayout`. View code SHOULD call `Rez.Layouts.MatchSummaryLayout(dc)` to use the resource-first layout where available.
- Devices without ActivityRecording fall back to in-app summary (in-memory), which maintains parity of visible events but may not produce an external activity export.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST provide a match-summary option from the end/reset menu or equivalent match-ending menu path.
- **FR-002**: Selecting match summary MUST show the recorded event log or summary for the current match. When the selection is made from the end/reset menu, the menu MUST be dismissed (pop) before the summary view is pushed so the summary view remains visible and is not immediately popped by menu cleanup logic.
- **FR-003**: The summary view MUST preserve the recorded match events when the referee exits it.
- **FR-004**: The end-match and reset actions MUST remain available and continue to behave as they do today.
- **FR-005**: The summary option MUST not require the referee to lose or discard the current match before viewing it.
- **FR-006**: The summary view MUST clearly handle the case where no match events are available.
- **FR-007**: If the design also supports accessing summary from the Back-button dialog during an active or paused match, that access path MUST not interfere with the existing end/reset confirmation flow or primary match controls.
- **FR-008**: If ActivityRecording is not available on the device, the app MUST present the match summary using the in-memory recorded event log without requiring persistent storage.
- **FR-009**: When exporting to ActivityRecording/FIT, recorded match events MUST be exported as raw chronological events including at minimum: event type, timestamp (monotonic match time), optional actor identifier, and optional numeric value.
- **FR-010**: When ActivityRecording export is available, the app MUST initiate a flush immediately after the referee confirms match end. The flush MUST be started without blocking the end/reset UI. If the underlying API provides only asynchronous confirmation, record the export as 'pending' and follow FR-011 retry semantics. If the save does not complete within a timeout (10 seconds), the app MUST continue match termination and mark the export as pending/failed per FR-011.
- **FR-011**: ActivityRecording export MUST NOT block match end or reset flows. The app MUST attempt up to 3 non-blocking retries (MAX_EXPORT_RETRIES = 3) using exponential backoff (e.g., 2000ms, 5000ms, 10000ms). If all attempts fail, set _eventExportState = 'failed' and exportAttempts = N, emit a Diagnostic trace named `activity_export` with payload {status, attempts, reason, timestamp}, and retain events in-memory so the match ends without blocking. Persisting a retry queue across app restarts is optional only if the platform's ActivityRecording APIs and device resources safely support background persistence; otherwise provide a manual retry UI for post-match retry. Default (MVP): do not persist retries across restarts — implement a manual post-match retry UI and surface export retry diagnostics for operator-assisted retries. Integration tests MUST simulate export failures and assert non-blocking match end, exact retry counts, backoff timings, and the presence and contents of the `activity_export` diagnostic trace. For the general diagnostic obligations (schema, non-PII rules, inspector tooling), reference the cross-cutting diagnostics requirement FR-DIAG-001 (see specs/cross-cutting/diagnostics.md). Feature-level traces (such as `activity_export`) remain documented here as feature-specific payload examples.
- **FR-012**: When exporting to ActivityRecording, the app MUST set the activity type to Activity.SPORT_RUGBY where the Connect IQ SDK exposes a rugby activity constant. If a rugby-specific activity constant is absent on a target device, a documented fallback mapping (to the closest available activity type) MUST be recorded in the plan and validated per-device during testing.

### Key Entities *(include if feature involves data)*

- **Match Summary**: A readable list or view of recorded match events for the current match.
- **End/Reset Menu**: The menu used to finish or discard the current match.
- **Summary Access Path**: The menu or dialog entry point that opens the match summary.
- **Event**: Minimal exported event schema: { type: String, timestamp: MonotonicMatchTime, actor?: String, value?: Number, details?: String } — used for in-app rendering and ActivityRecording exports.

  Implementation note: The in-memory model MUST populate the canonical keys `type` (String) and `timestamp` (Number, seconds since match start). Exporters/recorders SHOULD rely on these keys for ActivityRecording export; if other fields are present the exporter must map them to the canonical keys.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In end-of-match tests, the referee can reach the match summary from the end/reset menu in one menu choice.
- **SC-002**: In summary-access tests, 100% of recorded match events remain visible after the referee opens and exits the summary view.
- **SC-003**: In regression tests, the end-match and reset flows still complete with the same outcomes as before the summary option was added.
- **SC-004**: If the optional Back-button summary access is implemented, testers can reach the summary without breaking the existing active-match back menu behavior.
- **SC-005**: Where ActivityRecording/FIT export is available, recorded match events are included in the exported activity and remain visible in the summary view.
- **SC-006**: Exported ActivityRecording/FIT activity must contain raw chronological events matching the declared event schema and be verifiable in integration tests.
- **SC-007**: When ActivityRecording export is used, exported activity must be produced at match end as a flush operation (not continuous writes) and validated in integration tests.
- **SC-010**: Activity-type mapping verified on representative devices (Activity.SPORT_RUGBY used when supported; documented fallback used otherwise).
- **SC-011**: Export error handling verified: failed exports do not block match end, retries are attempted, and failures are logged for inspection.
- **SC-008**: Performance budgets (binary size, memory, CPU/battery) validated on representative devices.
- **SC-009**: Integration tests confirm exported ActivityRecording contains raw chronological events matching the in-app event list.

## Assumptions

- The safest first version is to expose match summary from the end/reset menu rather than making it a mandatory active-match shortcut.
- The current match summary view can be reused instead of inventing a second summary screen. Implementation note: The canonical WatchUi view class is `RugbyMatchSummaryView`. Any lightweight stub named `RugbySummaryView` should be removed or converted to a thin compatibility delegate that forwards to the canonical class.
- If an always-available summary access path is later added, it should be treated as a follow-on refinement rather than required for the initial release.
- No new persistent storage is required.
- Match summary will reuse existing ActivityRecording/FIT export (RugbyActivityRecorder) where available; this avoids creating new persistent storage.
- On devices without ActivityRecording, the app will fall back to the in-app summary view using the in-memory recorded event log.
- ActivityRecording exports will be produced at match end by default (flush operation).

## Performance Budgets

- Binary size target (compiled): <= 200 KB (initial target; refine per device in Phase 0 research)
- Max memory usage (heap & working set): <= 128 KB (initial target)
- Battery/CPU impact: <= 5% additional battery drain over baseline for a 90-minute match (initial target)

Device-specific measurable checks (executable procedure)

1) Build and measure
- Build for each device target using your local Connect IQ toolchain or CI job. Record the compiled artifact size (bytes). Example build invocation (local): `monkeyc -f <device-profile> -o build/<artifact>` and inspect the artifact size.
- PASS threshold (example): fenix-family: build_size_delta <= 200000 bytes. Record precise thresholds per-device in `specs/009-match-summary-access/perf-validation.md` during Phase 0 research.

2) Runtime measurement (simulator)
- Run the perf script for the target device (e.g., `tests/perf_check_fenix6.mc`) to simulate a 90-minute match with representative event generation.
- Collect metrics: peak heap bytes, average CPU percent over the run, and wall-clock time. Produce JSON output with fields: {"device":"<profile>", "build_size_bytes":<int>, "peak_heap_bytes":<int>, "avg_cpu_pct":<float>, "passed":<bool> }.

3) Acceptance criteria
- Example pass thresholds (refine in Phase 0):
  - fenix-family: `build_size_delta <= 200 KB`, `peak_heap_delta <= 128 KB`, `avg_cpu_pct <= 5.0`.
  - For smaller or older devices: tighten thresholds and record exceptions in perf-validation.md.

4) Reporting
- Append per-device JSON result rows to `specs/009-match-summary-access/perf-validation.md` and include a short human-readable summary table for reviewers and CI artifacts.

Notes
- These checks require local SDK/simulator and are not runnable in this environment. Capture raw measurements and machine-readable JSON so CI or reviewer tooling can parse and aggregate results.

## Security & Privacy Considerations

- Data classification: Match summary data is local match event information and contains no PII by default.
- Telemetry opt-in: No telemetry or analytics are added.
- Retention & deletion: The summary reflects current match data only and follows the existing discard/save behavior.
- External communications: None.
- Required security tests: Confirm the summary access path does not expose data beyond the current match and does not add external dependencies.
