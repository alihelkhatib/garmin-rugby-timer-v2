# Constitution Check: Match Summary Access

Feature: specs/009-match-summary-access
Owner: @feature-author
Date: 2026-04-14

This Constitution Check documents how the Match Summary Access feature complies with the Rugby Timer Constitution (v1.3.0). This artifact is required before design acceptance and before implementation tasks proceed.

1) Timer synchronization strategy
- All UI and exported timestamps derive from the single monotonic match timebase (RugbyGameModel snapshot). Exports record monotonic match time (ms) relative to match start. No additional independent timers are created for event timestamps.

2) Device & SDK compatibility
- Representative target families (initial): fenix 6 family, Forerunner 945/255 family, Venu/vivoactive family (small round and square). Phase 0 research to validate exact profiles and SDK API surface.
- ActivityRecording availability: when ActivityRecording API is present, exporter must use Activity.SPORT_RUGBY; otherwise documented fallback mapping will be used and tested per device.

3) ActivityRecording / Export behavior
- Export is a flush at match end (non-blocking). The implementation follows FR-010/FR-011: initiate export asynchronously, attempt up to MAX_EXPORT_RETRIES (3) with exponential backoff [2000,5000,10000]ms, and emit a diagnostic trace named `activity_export` on failures and on final result.
- Events remain in-memory; optional persistent retry across restarts is gated by device capability and requires an additional design decision and tested approval.

4) Declarative resource usage
- UI will use resource-first layouts for summary list and event rows (resources/layouts/rugby_event_row.xml, resources/layouts/rugby_event_log.xml). Any imperative drawing must be justified here.

5) Accessibility & haptics
- Summary view uses high-contrast text, stable layout, and readable font sizes at watch scale. Haptics are unchanged by summary access; critical in-match haptics remain intact and must be preserved.

6) Spec traceability (FR → Task mapping)
- FR-001 (menu presence): T012, T016
- FR-002 (show event log): T013, T017, T018
- FR-003 (preserve events): T019, T028
- FR-004 (preserve end/reset flows): T016, T022
- FR-005..FR-012: see specs/009-match-summary-access/tasks.md mapping (ensure updated mapping is included here if tasks change)

7) Testing & QA gates
- Phase 0 research must enumerate device profiles and perf baselines and be attached to this check.
- Export retry behavior must have an integration test that simulates failure and asserts non-blocking behavior and `activity_export` diagnostic presence.

Sign-off (feature owner):
- Name: ______________________
- Date: ______________________

(Placeholders above must be filled by the feature owner before implementation tasks are accepted.)
