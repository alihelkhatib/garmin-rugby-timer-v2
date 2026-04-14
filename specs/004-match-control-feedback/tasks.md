# Tasks: Match Control Feedback

## Phase 1 - Setup

- [ ] T001 [P] Create `specs/004-match-control-feedback/research.md` with reproduction steps, simulator profiles used (fenix6, forerunner), and captured logs from manual reproductions
- [ ] T002 [P] Create `specs/004-match-control-feedback/diagnostics.md` defining the diagnostic trace format (timestamp, action, priorState, result, metadata) and example entries
- [ ] T003 [P] Add a test harness entry `tests/Test_MatchControl_Repro.mc` containing step-by-step reproduction scripts/instructions for simulator runs

## Phase 2 - Foundational Implementation (blocking)

- [ ] T004 Implement diagnostics helper module at `source/Diagnostics.mc` (trace API: trace(action, ctx))
- [ ] T005 [P] Instrument `source/RugbyTimerDelegate.mc` to emit diagnostic traces for select/start, pause, menu routing, and back actions
- [ ] T006 [P] Instrument `source/RugbyGameModel.mc` to emit diagnostics for timer scheduling decisions and expose a single synchronized timebase accessor
- [ ] T007 [P] Add `tests/diagnostics_test.mc` to validate diagnostics format and presence for a few synthetic actions

## Phase 3 - User Stories (Priority order)

### User Story 1 - Start Match With Feedback And Live Timers (P1)

- [ ] T008 [US1] Fix start behavior so Select/Start calls `_model.startMatch`, `_recorder.start`, triggers haptic via `source/RugbyHaptics.mc` and requests immediate UI update — edit `source/RugbyTimerDelegate.mc` and `source/RugbyTimerView.mc`
- [ ] T009 [US1] Add integration test `tests/start_and_timer_update_test.mc` that asserts start path fires haptic (or logs fallback) and visible timers update over first 5 simulated seconds
- [ ] T010 [US1] Update `source/RugbyHaptics.mc` to expose `fireMatchStart()` and ensure no-op on devices without haptics; add unit test `tests/test_haptics.mc`

### User Story 2 - Show Yellow Card Identity Clearly (P2)

- [ ] T011 [US2] Fix yellow-card display rendering to include identifier and remaining timer — edit `source/RugbyTimerView.mc` (or the view responsible for card UI) to bind identifier string explicitly
- [ ] T012 [US2] Add unit test `tests/yellow_card_render_test.mc` asserting rendered label contains identifier and timer

### User Story 3 - Route Score Menus Correctly (P2)

- [ ] T013 [US3] Fix menu routing so score-team -> score-type flow is correct (edit `source/RugbyTimerDelegate.mc`, `source/MatchOptionDelegate` or menu delegate files as needed); ensure `resources/menus/score_team.xml` and `resources/menus/score_type.xml` are used correctly
- [ ] T014 [US3] Add integration test `tests/score_menu_routing_test.mc` that simulates selecting Home/Away and verifies next menu pushed is score-type

### User Story 4 - Trace Match Control Decisions (P3)

- [ ] T015 [US4] Add a diagnostics inspector script `tools/diagnostics_inspector.mc` or `scripts/diagnostics_inspector.sh` that parses device logs and summarizes decision traces into `specs/004-match-control-feedback/diagnostics_report.md`
- [ ] T016 [US4] Add test `tests/diagnostics_integration_test.mc` that runs actions and asserts the inspector finds expected trace entries

## Final Phase - Polish & Cross-cutting

- [ ] T017 Update `specs/004-match-control-feedback/research.md` and `specs/004-match-control-feedback/diagnostics.md` with findings from implementation and test runs
- [ ] T018 Produce device validation report `specs/004-match-control-feedback/device-validation-report.md` (fenix 6 family, Forerunner/vivoactive family)
- [ ] T019 Performance validation / regression checks: add `tests/perf/match_control_perf_check.mc` and record results in `specs/004-match-control-feedback/perf-validation.md`

## Dependencies

- Phase 1 tasks (T001-T003) should complete before Phase 2 foundational work (T004-T007).
- Diagnostics helper (T004) should be implemented before instrumentation (T005-T006).
- Start-fix tasks (T008-T010) depend on diagnostics instrumentation (T005-T006).

## Parallel opportunities

- T001, T002, T003 can run in parallel ([P]).
- Instrumentation for delegate and model (T005, T006) are parallelizable once Diagnostics helper (T004) exists.
- Unit tests for haptics and rendering (T010, T012) can be developed in parallel with implementation tasks.

## Notes

- All test files created are placeholders and must be implemented to run on the project’s Monkey C test harness. Adjust exact filenames if the project uses different naming conventions.
