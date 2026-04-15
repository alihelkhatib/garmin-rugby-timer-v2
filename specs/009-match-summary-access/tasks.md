# Tasks: Match Summary Access

## Phase 0 - Research

- [X] T001 [P] Research ActivityRecording/FIT export APIs and payload limits — produce `specs/009-match-summary-access/research-activityrecording.md`
- [X] T002 [P] Research UI scrollable list patterns on representative devices — produce `specs/009-match-summary-access/research-ui.md`
- [X] T003 Consolidate Phase 0 findings and update device matrix in `specs/009-match-summary-access/research.md` and `specs/009-match-summary-access/plan.md`

## Phase 1 - Design

- [X] T004 Create `specs/009-match-summary-access/data-model.md` documenting Event schema and mapping to ActivityRecording/FIT
- [X] T005 [P] Create `specs/009-match-summary-access/quickstart.md` with simulator steps and verification checklist
- [X] T006 [P] Produce resource-first UI layouts for summary view — add `resources/layouts/match_summary_layout.xml` (variants for small/large round devices under `resources/layouts/`)

## Phase 2 - Foundational Implementation (Cross-cutting)

- [X] T007 Implement in-memory recorded-event model and serialization — edit `source/RugbyGameModel.mc` (or add `source/RugbyEventLog.mc`) and unit tests under `tests/`
- [X] T008 Implement ActivityRecording export (flush at match end) — edit `source/RugbyActivityRecorder.mc` and add integration test `tests/impl_activity_export.mc`
- [X] T009 Implement ActivityRecording export retry & non-blocking failure handling (3 retries) and logging — edit `source/RugbyActivityRecorder.mc` and add test `tests/impl_export_error_handling.mc`
- [X] T010 Implement activity-type mapping and document fallback mapping — edit `source/RugbyActivityRecorder.mc` and add `specs/009-match-summary-access/activity-type-mapping.md`
- [X] T011 Implement in-app fallback rendering for devices without ActivityRecording — edit `source/RugbySummaryView.mc` and `source/RugbyActivityRecorder.mc` as needed

## Phase 3 - User Stories (Priority order)

### User Story 1 - Review Match Summary At Match End (P1)

- [X] T012 [US1] Add match-summary menu entry to end/reset menu resources and wire action — edit `resources/menus/match_options.xml` and `source/RugbyTimerDelegate.mc`
- [X] T013 [US1] Implement summary view UI and rendering from in-memory events — create/edit `source/RugbySummaryView.mc` and resources `resources/layouts/match_summary_layout.xml`
- [X] T014 [US1] Add integration test validating end->menu->summary flow and visible events — create `tests/match_summary_endflow_test.mc`
- [X] T015 [US1] Verify SC-001 and SC-002 via automated assertions in `tests/match_summary_endflow_test.mc`

### User Story 2 - Preserve Existing End And Reset Actions (P2)

- [X] T016 [US2] Add regression tests ensuring end-match and reset flows still behave as before — create `tests/match_summary_regression_test.mc`
- [X] T017 [US2] Prototype optional Back-button summary access (exploratory) without changing default end/reset flow — create `source/BackButtonSummaryPrototype.mc` and test `tests/back_button_summary_proto.mc` (mark as follow-on if not included in MVP)

## Final Phase - Polish & Cross-cutting

- [X] T018 Update docs: finalize `specs/009-match-summary-access/research.md`, `specs/009-match-summary-access/data-model.md`, and `specs/009-match-summary-access/quickstart.md`
- [X] T019 Device matrix validation and report — produce `specs/009-match-summary-access/device-validation-report.md` (fenix 6 family, Forerunner/vivoactive family, etc.)
- [X] T020 Performance validation and optimization report — produce `specs/009-match-summary-access/perf-validation.md` and add automated checks under `tests/perf/`

## Final Phase - Additional Tasks

- [X] T021 Implement non-blocking export retry policy in `source/RugbyActivityRecorder.mc` (MAX_EXPORT_RETRIES=3, BACKOFFS=[2000,5000,10000] ms); record `exportAttempts` and `_eventExportState`; emit Diagnostics `activity_export` (file: source/RugbyActivityRecorder.mc)  
  Acceptance: Integration tests must simulate failures and assert retry counts, backoff timings, and diagnostic payload presence.
- [X] T022 Add integration test `tests/impl_export_retry_test.mc` that simulates ActivityRecording failures and asserts non-blocking end/reset flow, retry attempts, backoff timings, and the `activity_export` diagnostic trace (file: tests/impl_export_retry_test.mc)
- [ ] T023 Document retry behavior in `specs/009-match-summary-access/quickstart.md` with reproduction steps (file: specs/009-match-summary-access/quickstart.md)  
  Acceptance: quickstart must include reproduction steps and verification checklist; specs/009-match-summary-access/perf-validation.md must list device names and pass/fail results for retry validation.
- [ ] T024 Add perf test script `tests/perf_check_fenix6.mc` (measure binary size, heap delta, CPU over a simulated 90-minute match) (file: tests/perf_check_fenix6.mc)  
  Acceptance: perf-validation report must list device names and pass/fail results, and include measured binary size, peak heap delta, and CPU overhead.
- [ ] T025 Add perf test script `tests/perf_check_forerunner.mc` (same measurements for Forerunner profile) (file: tests/perf_check_forerunner.mc)  
  Acceptance: perf-validation report must list device names and pass/fail results, and include measured binary size, peak heap delta, and CPU overhead.
- [X] T026 [US1] Implement empty-state layout and messaging in `resources/layouts/match_summary_layout.xml` and show in `source/RugbySummaryView.mc`; add `tests/match_summary_empty_state_test.mc` (file: resources/layouts/match_summary_layout.xml, source/RugbySummaryView.mc, tests/match_summary_empty_state_test.mc)  
  Acceptance: empty-state displays the message "No events recorded" when event log is empty; automated test must assert empty-state text presence.
- [X] T027 Create `source/RugbyEventLog.mc` implementing small in-memory EventLog API: addEvent(event), serialize(), snapshot() (file: source/RugbyEventLog.mc)  
  Acceptance: EventLog provides addEvent, serialize, and snapshot APIs; unit tests validate basic add and snapshot semantics.
- [X] T028 Migrate callers to use `source/RugbyEventLog.mc`: update `source/RugbyActivityRecorder.mc`, `source/RugbySummaryView.mc`, and `source/RugbyGameModel.mc` to call RugbyEventLog APIs; add `tests/eventlog_unit_test.mc` (files modified: source/RugbyActivityRecorder.mc, source/RugbySummaryView.mc, source/RugbyGameModel.mc; create tests/eventlog_unit_test.mc)
- [ ] T029 Add test steps and timeout assertion in `tests/impl_activity_export.mc` ensuring flush initiation at match end is non-blocking and times out appropriately (file: tests/impl_activity_export.mc)
- [ ] T030 Normalize terminology: add a short "Terminology" note to `specs/009-match-summary-access/spec.md` stating canonical name is "Match Summary (Event Log)" and update spec references accordingly (file: specs/009-match-summary-access/spec.md)
- [ ] T031 Research owner sign-off: add a task `T031` requiring research owner to sign off on `specs/009-match-summary-access/research.md` before Phase 1 starts (file: specs/009-match-summary-access/tasks.md)  
  Acceptance: Research owner must explicitly sign-off in the research.md file (e.g., a sign-off line with name and date) before Phase 1 begins.

## Dependencies

- Phase 0 tasks (T001, T002) MUST complete before Phase 1 design tasks (T004-T006).
- Design outputs (T004-T006) MUST complete before Foundational implementation (T007-T011).
- Foundational implementation (T007-T011) MUST complete or provide stable mocks before User Story implementation (T012-T017).

## Parallel opportunities

- T001 and T002 can run in parallel ([P]).
- T005 and T006 are parallelizable after Phase 0 is complete ([P]).
- Several implementation unit tests can be developed in parallel with code changes where interfaces are stable.

## Notes

- All tasks include explicit target file paths; adjust exact filenames if the project uses different module names.
- MVP recommendation: complete User Story 1 (T012-T015) after core Foundational tasks T007-T009.
