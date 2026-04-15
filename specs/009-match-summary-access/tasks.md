# Tasks: Match Summary Access

## Phase 0 - Research

- [ ] T001 [P] Research ActivityRecording/FIT export APIs and payload limits and document findings in `specs/009-match-summary-access/research-activityrecording.md`
- [ ] T002 [P] Research UI scrollable list patterns on representative Garmin devices and document findings in `specs/009-match-summary-access/research-ui.md`
- [ ] T003 Consolidate Phase 0 findings and update `specs/009-match-summary-access/research.md` and `specs/009-match-summary-access/plan.md`

## Phase 1 - Design

- [ ] T004 Create `specs/009-match-summary-access/data-model.md` documenting the Event schema, validation rules, and ActivityRecording mapping
- [ ] T005 [P] Create `specs/009-match-summary-access/quickstart.md` with simulator/device validation steps and a verification checklist
- [ ] T006 [P] Produce resource-first summary view layouts for small-round and large-round devices and add `resources/layouts/match_summary_layout.xml`

## Phase 2 - Foundational Implementation

- [ ] T007 [P] Add `source/RugbyEventLog.mc` implementing in-memory EventLog APIs: addEvent(event), snapshot(), and serialize()
- [ ] T008 [P] Integrate RugbyEventLog into `source/RugbyGameModel.mc` and ensure match events are accessible for summary rendering and export
- [ ] T009 [P] Implement ActivityRecording/FIT export flush-at-match-end in `source/RugbyActivityRecorder.mc` and document rugby activity-type mapping in `specs/009-match-summary-access/activity-type-mapping.md`
- [ ] T010 [P] Implement non-blocking export retry and failure handling with 3 retries, exponential backoff, and `activity_export` diagnostics in `source/RugbyActivityRecorder.mc`
- [ ] T011 [P] Implement in-app fallback summary rendering for devices without ActivityRecording in `source/RugbySummaryView.mc`

## Phase 3 - User Story 1 - Review Match Summary At Match End (P1)

- [ ] T012 [US1] Add a Match Summary option to the end/reset menu and wire the action in `resources/menus/match_options.xml` and `source/RugbyTimerDelegate.mc`
- [ ] T013 [US1] Implement the match summary view using `source/RugbySummaryView.mc` and `resources/layouts/match_summary_layout.xml`
- [ ] T014 [US1] Add `tests/match_summary_endflow_test.mc` validating end->menu->summary navigation and visible recorded events
- [ ] T015 [US1] Add `tests/match_summary_empty_state_test.mc` validating the empty-state message when no events are recorded
- [ ] T016 [US1] Add exit/navigation verification in `tests/match_summary_endflow_test.mc` to confirm the user returns to the prior match context without losing recorded events

## Phase 4 - User Story 2 - Preserve Existing End And Reset Actions (P2)

- [ ] T017 [US2] Add `tests/match_summary_regression_test.mc` that verifies the existing end-match save flow still works when Match Summary is available
- [ ] T018 [US2] Add `tests/match_summary_regression_test.mc` that verifies the existing reset-confirm discard flow still works when Match Summary is available
- [ ] T019 [US2] Preserve end/reset menu order and behavior in `resources/menus/match_options.xml` and `source/RugbyTimerDelegate.mc` so Match Summary does not interfere with primary actions
- [ ] T020 [US2] Prototype optional Back-button summary access without changing the default end/reset dialog flow in `source/BackButtonSummaryPrototype.mc` and `tests/back_button_summary_proto.mc`

## Phase 5 - Polish & Cross-cutting

- [ ] T021 [P] Update docs in `specs/009-match-summary-access/research.md`, `specs/009-match-summary-access/data-model.md`, and `specs/009-match-summary-access/quickstart.md`
- [ ] T022 [P] Produce `specs/009-match-summary-access/device-validation-report.md` for fenix 6 family and Forerunner/vivoactive family validation
- [ ] T023 [P] Produce `specs/009-match-summary-access/perf-validation.md` and add performance checks in `tests/perf_check_fenix6.mc` and `tests/perf_check_forerunner.mc`
- [ ] T024 [P] Normalize terminology in `specs/009-match-summary-access/spec.md` and `specs/009-match-summary-access/plan.md` to use "Match Summary (Event Log)" and the canonical `RugbyEventLog` naming
- [ ] T025 [P] Confirm declarative resource-first UI use in `resources/layouts/match_summary_layout.xml` and `source/RugbySummaryView.mc` per Constitution VII
- [ ] T026 [P] Validate ActivityRecording export does not block match end, emits `activity_export` diagnostics, and reports export state in `tests/impl_export_error_handling.mc`
- [ ] T027 [P] Confirm no new persistent storage is added and in-app fallback is used on unsupported devices in `source/RugbyActivityRecorder.mc` and `source/RugbySummaryView.mc`
- [ ] T028 [P] Run final regression checks for timer, scoring, card, conversion, variant, UI, storage, and activity behavior touched by this feature

## Dependencies

- Phase 0 tasks (T001, T002) MUST complete before Phase 1 design tasks (T004-T006).
- Phase 1 tasks (T004-T006) MUST complete before Phase 2 foundational implementation (T007-T011).
- Phase 2 tasks (T007-T011) MUST complete or provide stable mocks before User Story implementation (T012-T020).
- User Story implementation tasks may proceed in parallel once Phase 2 is stable.

## Parallel opportunities

- T001 and T002 can run in parallel ([P]).
- T005, T006, T007, T008, T009, T010, and T011 are parallelizable when their dependencies are met.
- User Story tests and implementation tasks for US1 and US2 can run in parallel after foundational work completes.

## Notes

- All tasks include explicit target file paths; adjust exact filenames if the project uses different module names.
- MVP recommendation: complete User Story 1 (T012-T015) after core Foundational tasks T007-T009.
