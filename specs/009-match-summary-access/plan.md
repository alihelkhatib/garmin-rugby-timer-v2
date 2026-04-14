# Implementation Plan: Match Summary Access

Path: /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/plan.md

Problem statement and scope

- Problem: Allow referees to review the Match Summary (Event Log) from the match end/reset flow (and optionally from the back-button dialog) without interfering with existing end-match or reset flows. The view should show the recorded chronological events for the current match and support exporting raw events to the platform ActivityRecording/FIT when available.
- Scope (in-scope):
  - Add a "Match Summary (Event Log)" entry to the end/reset menu and show a scrollable summary view that lists recorded events (type, monotonic match timestamp, actor?, value?, details?).
  - Export raw chronological events to ActivityRecording/FIT at match end when the platform supports ActivityRecording.
  - Provide an in-memory fallback rendering on devices without ActivityRecording or when export fails.
  - Preserve existing end/reset actions and ensure exports do not block match termination.
- Out-of-scope:
  - Persistent new storage outside ActivityRecording (no DB/FS schema changes).
  - Live continuous export during match (exports only at match end as a flush operation).

Proposed approach and architecture / stack choices

- Language & runtime: Monkey C (Connect IQ). Work will live in source/ and module RugbyEventLog (canonical name: RugbyEventLog, file: source/RugbyEventLog.mc).
- UI: Resource-first (XML) layouts for summary list and item rows. Use platform view classes appropriate to device family (ListView / ScrollView equivalents in Connect IQ). Prefer declarative resource-based screens to satisfy Constitution VII.
- View classes and flow:
  - Add a lightweight controller class (RugbyEventLogView) that:
    - Accepts an Event[] model and renders rows via a resource-based row layout.
    - Exposes a static openFromMenu(matchContext) method used by the end/reset menu action.
    - Preserves pointer/selection and returns control to the invoking menu when dismissed.
  - Add menu integration in existing EndResetMenu controller: insert a non-invasive menu item that opens RugbyEventLogView.
- Event model and mapping to app state:
  - In-memory event buffer already collected by match logic (source: search for event collection in source/). Map that buffer to a normalized Event schema used by RugbyEventLog and by the ActivityRecording exporter.
  - Event schema (canonical): { type: String, timestamp: UInt32 (monotonic match seconds or ms), actor?: String, value?: Number, details?: String }
  - Map between app state and Event[]: the match controller exposes getEvents(): Event[]; RugbyEventLog will call this when opening the view.
- ActivityRecording export:
  - Implement RugbyActivityExporter that adapts Event[] into the platform ActivityRecording API (or FIT writer when required). Export must be initiated at match end, be non-blocking, and follow retry/backoff semantics (FR-011). Export should attach activity type Activity.SPORT_RUGBY where available or fall back to documented mapping.

Data model references and mapping to app state

- Primary artifact: /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/data-model.md (to be created).
- Data model will document the Event entity and validation rules, and map fields to concrete producers in source/ (e.g., where goals, penalties, substitutions are recorded). Include examples per-event type and sample serialization used for ActivityRecording.
- When rendering, the UI will derive human-readable strings from event.type and use event.timestamp relative to match start for display.

Phases and deliverables

- Phase 0 — Research (deliverables: research.md)
  - Device matrix: enumerate representative devices and API capabilities (fenix family, Forerunner/vivoactive, other watch types). Path: /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/research.md
  - Confirm ActivityRecording API surface per device and any limits (event count, payload size, supported activity types). Document Activity.SPORT_RUGBY presence and fallback mapping per device.
  - Finalize performance budgets per device family (binary size, heap, CPU) with measured baselines using simulator builds.
  - Validate resource/layout constraints (row counts, fonts, truncation) for small-round vs large-round screens.

- Phase 1 — Design (deliverables: data-model.md, contracts/, quickstart.md)
  - data-model.md (Event schema, validation, serialization examples).
  - UI resource sketches: XML for row layout and screen variants (absolute path: /Users/600171959/Projects/garmin-rugby-timer-v2/resources/ and specs/ directory drafts).
  - contracts/: Document the exporter contract: inputs to ActivityRecording, diagnostic trace schema (activity_export), and expected success/failure states. Path: /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/contracts/
  - quickstart.md: how to run simulator tests, how to open the end/reset menu and the summary view, and how to verify exports. Path: /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/quickstart.md

- Phase 2 — Implementation (deliverables: code changes, unit/integration tests, perf scripts)
  - Code: source/RugbyEventLog.mc (view/controller), source/RugbyActivityExporter.mc, small menu integration patch in match end/reset controller.
  - Tests:
    - Unit tests for Event serialization and exporter translation (mock ActivityRecording API).
    - Integration tests that simulate match flows, open the summary view, and assert visibility of events.
    - Export failure simulation tests that verify retry/backoff counts, non-blocking end-match behavior, and diagnostic trace payloads.
  - Perf: Add perf-check scripts and device-specific verification artifacts under specs/009-match-summary-access/perf-validation.md

- Final polish — QA and documentation
  - Accessibility and visual checks, finalize strings (use UI label: "Match Summary (Event Log)" exactly), finalize resource names.
  - Merge checklist and add to repo README and AGENTS.md if needed.

Device-specific constraints and measurable performance budgets

- Initial budgets (to be validated & refined in Phase 0 research):
  - Compiled binary size delta: <= 200 KB
  - Peak additional heap: <= 128 KB
  - CPU / battery: <= +5% additional drain over baseline for a 90-minute match
- Per-device checks (example procedure for each target device):
  - Build for device target and measure built artifact size (monkeyc CLI or build artifact path). PASS if delta <= budget.
  - Run simulator for a 90-minute match with event generation script; measure peak heap and CPU over baseline. PASS if within budget.
  - Verify ActivityRecording export on device simulator (or real device) — check exported event count and that timestamps match in-app Event[]. PASS if export contains raw chronological events and activity_type mapping is correct.
  - Record all results in /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/perf-validation.md

Testing strategy and acceptance criteria

- Simulator tests (manual & automated):
  - Steps to reproduce on simulator (quickstart.md): create a synthetic match with a representative event stream (goals, penalties), open end/reset menu -> select "Match Summary (Event Log)" -> verify displayed events match the generated stream and order.
  - Export tests: trigger match end and verify that RugbyActivityExporter attempts to flush events to ActivityRecording. When simulator supports ActivityRecording, assert exported payload contains event array and activity type.
  - Failure mode: simulate export API errors/timeouts and assert non-blocking match end, retry attempts (3) with backoffs [2000, 5000, 10000] ms, and diagnostic trace 'activity_export' emitted with {status, attempts, reason, timestamp}.

- Unit & integration tests:
  - Unit tests for Event serialization, mapping rules, and exporter payload formation.
  - Integration tests to exercise menu navigation, view lifecycle, and that exiting the summary preserves app state and events.
  - Add tests in tests/ matching repo conventions; e.g., tests/unit/rugby_event_log_test.mc, tests/integration/match_summary_export_test.mc

- Performance & regression tests:
  - Automated perf scripts for target devices to measure artifact size and memory/CPU during a scripted match flow.
  - Regression tests: ensure existing end-match and reset flows continue to behave identically (no extra prompts, no blocked termination).

Acceptance criteria (traceable to spec requirements):
- AC-1: A "Match Summary (Event Log)" menu item is present in end/reset menu and opens the summary view (FR-001, FR-002).
- AC-2: Summary view shows all recorded events and preserves them after exit (FR-003, SC-002).
- AC-3: End-match and reset actions behave as before (FR-004, SC-003).
- AC-4: ActivityRecording export occurs at match end when available and contains raw chronological events (FR-009, SC-005/SC-006).
- AC-5: Export errors do not block match termination; retries and diagnostic traces implemented (FR-010, FR-011, SC-011).
- AC-6: Performance budgets met for target devices or documented exceptions recorded (SC-008).

Deliverables and next steps

- Files to create or update (absolute paths):
  - /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/research.md (Phase 0)
  - /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/data-model.md (Phase 1)
  - /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/quickstart.md (Phase 1)
  - /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/contracts/activity-export.md (Phase 1)
  - /Users/600171959/Projects/garmin-rugby-timer-v2/specs/009-match-summary-access/perf-validation.md (Phase 2)
  - /Users/600171959/Projects/garmin-rugby-timer-v2/source/RugbyEventLog.mc (Phase 2 implementation)
  - /Users/600171959/Projects/garmin-rugby-timer-v2/source/RugbyActivityExporter.mc (Phase 2 implementation)
  - Update existing end/reset menu controller under source/ (file: locate and patch in Phase 2)
  - tests/unit/rugby_event_log_test.mc and tests/integration/match_summary_export_test.mc

- Immediate next steps (this branch):
  1. Phase 0 research: produce research.md and enumerate target devices & ActivityRecording behaviors.
  2. Create data-model.md and quickstart.md drafts.
  3. Prototype a resource-based row layout and runner screen on one representative device in simulator.
  4. Create unit tests for Event serialization and an integration test that opens the summary view.

Notes on extension hooks

- Pre-plan hooks found in /.specify/extensions.yml indicate an optional pre-plan git.commit hook. This plan does not automatically execute hooks; follow repository tooling to run them if desired.

Plan owner: @feature-author

