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

- [X] T012 [US1] Add match-summary menu entry to end/reset menu resources and wire action — edit `resources/menus/end_reset_menu.xml` and `source/RugbyTimerDelegate.mc`
- [X] T013 [US1] Implement summary view UI and rendering from in-memory events — create/edit `source/RugbySummaryView.mc` and resources `resources/layouts/match_summary_layout.xml`
- [X] T014 [US1] Add integration test validating end->menu->summary flow and visible events — create `tests/match_summary_endflow_test.mc`
- [X] T015 [US1] Verify SC-001 and SC-002 via automated assertions in `tests/match_summary_endflow_test.mc`

### User Story 2 - Preserve Existing End And Reset Actions (P2)

- [ ] T016 [US2] Add regression tests ensuring end-match and reset flows still behave as before — create `tests/match_summary_regression_test.mc`
- [ ] T017 [US2] Prototype optional Back-button summary access (exploratory) without changing default end/reset flow — create `source/BackButtonSummaryPrototype.mc` and test `tests/back_button_summary_proto.mc` (mark as follow-on if not included in MVP)

## Final Phase - Polish & Cross-cutting

- [ ] T018 Update docs: finalize `specs/009-match-summary-access/research.md`, `specs/009-match-summary-access/data-model.md`, and `specs/009-match-summary-access/quickstart.md`
- [ ] T019 Device matrix validation and report — produce `specs/009-match-summary-access/device-validation-report.md` (fenix 6 family, Forerunner/vivoactive family, etc.)
- [ ] T020 Performance validation and optimization report — produce `specs/009-match-summary-access/perf-validation.md` and add automated checks under `tests/perf/`

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
