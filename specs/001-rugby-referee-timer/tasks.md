# Tasks: Rugby Referee Timer

**Input**: Design documents from `/specs/001-rugby-referee-timer/`
**Prerequisites**: `plan.md` (required), `spec.md` (required for user stories), `research.md`, `data-model.md`, `contracts/`, `quickstart.md`
**Tests**: Include simulator and unit-test tasks for timer synchronization, haptics, activity recording, and regression-sensitive behavior because the constitution requires explicit coverage for those areas.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label, e.g. `[US1]`
- Include exact file paths in every task description

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Align the Connect IQ project and documentation with the clarified rugby-timer feature before implementation begins.

- [X] T001 [P] Update `manifest.xml` to require Connect IQ API 4.1.6 minimum and keep the `Fit`, `Positioning`, `Sensor`, and `SensorLogging` permissions aligned with rugby recording and GPS support
- [X] T002 [P] Refresh shared resource labels and layout bindings in `resources/strings/strings.xml`, `resources/layouts/layout.xml`, `resources/layouts/match_summary_layout.xml`, and `resources/menus/match_options.xml` for the revised summary, exit, and conversion-overlay wording
- [ ] T003 [P] Update `tests/README.md` and `tests/TEST_TRACEABILITY.md` with the final feature coverage matrix for timer sync, haptics, recording, and exit flows

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared state, recorder hooks, haptics, and flow plumbing that all user stories depend on.

- [X] T004 [P] Extend `source/RugbyGameModel.mc` with shared snapshot helpers and state fields for conversion-overlay countdown visibility, match-summary visibility, one-time half-warning events, and motion-data hooks
- [X] T005 [P] Extend `source/RugbyActivityRecorder.mc` to carry rugby-equivalent fallback labeling, GPS motion data, distance/current speed/average speed capture, and non-blocking export state
- [X] T006 [P] Extend `source/RugbyHaptics.mc` with dedicated helpers for match start, pause, pause reminder, conversion warning, yellow-card warning, and 2-minute half-warning patterns
- [X] T007 [P] Update `source/RugbyTimerDelegate.mc` and `source/RugbyTimerView.mc` control flow so summary transitions, exit routing, and new haptic snapshot events can be wired without duplicating logic
- [X] T008 [P] Update `source/RugbyConversionView.mc` and its layout dependencies in `resources/layouts/layout.xml` so the overlay can reserve a small countdown area at the top

**Checkpoint**: Foundation ready - user story implementation can now begin in priority order.

---

## Phase 3: User Story 1 - Run Match Clock (Priority: P1)

**Goal**: Keep the main countdown, count-up timer, and half indicator synchronized from one shared match state.

**Independent Test**: Start a match, pause and resume it, and force half-end/match-end transitions while verifying all visible timers move together without visible drift.

### Tests for User Story 1

- [ ] T009 [P] [US1] Add or extend tests in `tests/Test_RugbyGameModel.mc` for start, pause, resume, half-end, and match-end transitions from one shared snapshot

### Implementation for User Story 1

- [ ] T010 [US1] Refine the timing state and snapshot calculations in `source/RugbyGameModel.mc` so the main countdown, count-up timer, and half indicator remain synchronized
- [ ] T011 [US1] Update `source/RugbyTimerView.mc` and `resources/layouts/layout.xml` so the main timer hierarchy and half indicator remain readable during active play and paused states

**Checkpoint**: User Story 1 should be fully functional and testable independently.

---

## Phase 4: User Story 2 - Manage Scores and Conversion Timer (Priority: P2)

**Goal**: Record scoring actions and show the conversion overlay with a smaller countdown at the top.

**Independent Test**: Record tries, conversions, penalties, and drop goals for both teams, then verify the conversion timer starts or replaces correctly and the conversion overlay keeps the countdown visible at the top.

### Tests for User Story 2

- [X] T012 [P] [US2] Add or extend tests in `tests/Test_RugbyGameModel.mc` and `tests/test_eventlog.mc` for try/conversion/penalty/drop-goal scoring, conversion replacement, and the smaller top countdown on the conversion overlay

### Implementation for User Story 2

- [X] T013 [US2] Update scoring and conversion logic in `source/RugbyGameModel.mc` so try starts or replaces the conversion timer and score counters remain consistent
- [X] T014 [US2] Update `source/RugbyScoringMenus.mc`, `source/RugbyTeamSelectionDelegate.mc`, `source/RugbyTeamActionDelegate.mc`, and `source/RugbyConversionView.mc` so the conversion overlay shows the smaller top countdown and returns correctly after made or missed conversions
- [ ] T015 [P] [US2] Adjust `resources/menus/score_team.xml`, `resources/menus/score_home.xml`, `resources/menus/score_away.xml`, and `resources/layouts/layout.xml` if the conversion flow needs label or position tweaks

**Checkpoint**: User Story 2 should be independently usable without affecting timer control.

---

## Phase 5: User Story 5 - Confirm Match Start And Leave Safely (Priority: P2)

**Goal**: Provide tactile match-start confirmation and a clear way to leave the app from pre-match or terminal states.

**Independent Test**: Start a match on a haptic-capable device and verify one start vibration, then leave the app from pre-match or terminal screens using the documented exit path.

### Tests for User Story 5

- [X] T016 [P] [US5] Add or extend tests in `tests/Test_RugbyGameModel.mc` and `tests/match_summary_endflow_test.mc` for match-start vibration, pre-match exit routing, and terminal-screen exit handling

### Implementation for User Story 5

- [X] T017 [US5] Update `source/RugbyTimerDelegate.mc`, `source/RugbyTimerView.mc`, and `resources/menus/match_options.xml` so pre-match and terminal states expose a clear exit path without breaking active-match controls
- [X] T018 [US5] Wire the match-start tactile confirmation in `source/RugbyTimerDelegate.mc` and `source/RugbyHaptics.mc` so the start action produces a single supported-device vibration

**Checkpoint**: Match start confirmation and app exit behavior should now be independently testable.

---

## Phase 6: User Story 6 - Record Rugby Activity, Distance, And Speed (Priority: P2)

**Goal**: Save the match as a rugby activity with GPS motion data, distance, current speed, and average speed when supported.

**Independent Test**: Save a GPS-enabled match and verify the recording is labeled as rugby or the documented fallback and includes distance, current speed, average speed, and route data; verify the match still saves if GPS is denied.

### Tests for User Story 6

- [X] T019 [P] [US6] Add or extend tests in `tests/Test_RugbyActivityRecorder.mc`, `tests/impl_activity_export.mc`, and `tests/impl_export_error_handling.mc` for rugby labeling, GPS fallback behavior, motion data capture, and non-blocking save retries

### Implementation for User Story 6

- [X] T020 [US6] Update `source/RugbyActivityRecorder.mc` to capture motion data, preserve rugby-equivalent fallback labeling, and keep stop/save non-blocking when event export is unavailable
- [X] T021 [US6] Update `source/RugbyGameModel.mc` and `source/RugbyTimerView.mc` so match-end snapshots and summary flow expose the event log and motion-data-friendly state needed by the recorder
- [X] T022 [P] [US6] Refresh `manifest.xml` and recording-facing copy in `resources/strings/strings.xml` if permission or fallback language needs to be explicit for GPS-enabled recordings

**Checkpoint**: Rugby activity recording should now be independently verifiable with motion data and fallback behavior.

---

## Phase 7: User Story 3 - Manage Discipline Timers (Priority: P3)

**Goal**: Keep yellow and red sanctions visible and synchronized, including the 2-minute half-warning behavior.

**Independent Test**: Issue yellow and red cards, run the clock through a half transition, and verify alerts fire once while card state remains visible and synchronized.

### Tests for User Story 3

- [X] T023 [P] [US3] Add or extend tests in `tests/Test_RugbyGameModel.mc` and `tests/Test_RugbyTimerView.mc` for yellow/red card pause behavior, one-time 60-second alerts, and the 2-minute half-warning threshold

### Implementation for User Story 3

- [X] T024 [US3] Update sanction expiry and preservation logic in `source/RugbyGameModel.mc` so yellow cards pause across halves, red cards remain persistent, and the half-warning event is emitted once
- [X] T025 [US3] Update `source/RugbyTimerView.mc` and `source/RugbyHaptics.mc` so active sanctions remain visible, yellow-card alerts coalesce, and 2-minute warnings do not repeat
- [ ] T026 [P] [US3] Adjust `resources/layouts/layout.xml` and `resources/menus/card_team.xml` if the sanction display or alert labels need layout refinements

**Checkpoint**: Discipline state should remain independently testable without changing core scoring behavior.

---

## Phase 8: User Story 7 - Half-Remaining Warning Haptic (Priority: P3)

**Goal**: Vibrate once when 2 minutes remain in a half, without repeating or disrupting timer updates.

**Independent Test**: Run a half until 2 minutes remain and verify a single haptic warning fires, then confirm it does not repeat on subsequent updates.

### Tests for User Story 7

- [X] T027 [P] [US7] Add or extend tests in `tests/Test_RugbyGameModel.mc` and `tests/perf_check_fenix6.mc` for the 2-minute half-warning threshold and single-fire behavior

### Implementation for User Story 7

- [X] T028 [US7] Update `source/RugbyGameModel.mc` and `source/RugbyHaptics.mc` so the 2-minute remaining event is emitted once per half and marked fired after vibration
- [X] T029 [US7] Update `source/RugbyTimerView.mc` so the warning timing respects the shared snapshot and does not interfere with pause reminders or refresh timing

**Checkpoint**: The half-warning haptic should now be independently verifiable and non-repeating.

---

## Phase 9: User Story 4 - Choose and Adjust Rugby Variant (Priority: P4)

**Goal**: Select built-in rugby variants and adjust timing overrides without duplicating code paths.

**Independent Test**: Select each built-in variant, then adjust half, sin-bin, and conversion values and verify the later timers use the updated settings.

### Tests for User Story 4

- [ ] T030 [P] [US4] Add or extend tests in `tests/Test_RugbyVariantConfig.mc` for built-in presets, half-length adjustments, and sin-bin/conversion override persistence

### Implementation for User Story 4

- [ ] T031 [US4] Update `source/RugbyVariantConfig.mc` and `source/RugbyGameModel.mc` so preset loading, local overrides, and idle-only half adjustments stay aligned with the spec
- [ ] T032 [US4] Update `source/RugbyTimerDelegate.mc` and `resources/menus/variant_menu.xml` so the variant picker is only available before the first match start and applies the selected preset cleanly

**Checkpoint**: Variant selection and adjustment should remain independent from the other match flows.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Validate the integrated feature set, watch-scale layout, and regression-sensitive behavior before implementation is considered complete.

- [ ] T033 Run regression checks in `tests/Test_RugbyGameModel.mc`, `tests/Test_RugbyActivityRecorder.mc`, `tests/Test_RugbyVariantConfig.mc`, `tests/test_eventlog.mc`, `tests/match_summary_empty_state_test.mc`, `tests/match_summary_endflow_test.mc`, and `tests/match_summary_regression_test.mc` to confirm prior behaviors still pass
- [ ] T034 Validate representative simulator and device profiles using `tests/perf_check_fenix6.mc`, `tests/perf_check_forerunner.mc`, and the scenarios in `specs/001-rugby-referee-timer/quickstart.md` on small and large round watch profiles
- [ ] T035 Audit `resources/layouts/layout.xml`, `resources/layouts/match_summary_layout.xml`, `resources/menus/card_away.xml`, `resources/menus/card_home.xml`, `resources/menus/card_team.xml`, `resources/menus/match_options.xml`, `resources/menus/match_summary.xml`, `resources/menus/score_away.xml`, `resources/menus/score_home.xml`, `resources/menus/score_team.xml`, and `resources/menus/variant_menu.xml` for watch-scale readability, conversion-overlay countdown placement, and exit-path clarity
- [X] T036 Update `tests/README.md` and `tests/TEST_TRACEABILITY.md` with the final story-to-test mapping and validation matrix

---

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 has no dependencies and can start immediately.
- Phase 2 depends on Phase 1 and blocks every user story.
- User story phases depend on Phase 2.
- Phase 10 depends on the desired user stories being complete.

### User Story Dependencies

- User Story 1 (P1) is the MVP and can be implemented immediately after Phase 2.
- User Stories 2, 5, and 6 can proceed after Phase 2 and are independent enough to run in parallel if staffed.
- User Stories 3 and 7 can proceed after Phase 2 and share haptic/model plumbing.
- User Story 4 is lowest priority and can be deferred until the shared variant infrastructure is stable.

### Within Each User Story

- Tests should be written or updated before implementation tasks where included.
- Shared model changes should land before view and delegate wiring.
- Resource/layout updates should follow the state behavior they display.
- Each user story should end in a self-contained checkpoint that can be validated independently.

## Parallel Opportunities

- Setup: T001, T002, and T003 can run in parallel because they touch different files.
- Foundation: T004, T005, T006, T007, and T008 can be split across separate implementation lanes.
- US1: T009 can run while T010 and T011 are being planned, then T010 and T011 can split by model versus view work.
- US2: T013 and T015 can be split by model versus resource updates once T012 is in place.
- US3: T024 and T026 can be split by model versus resource work once T023 is in place.
- US5: T017 and T018 can be split between exit-routing and haptic wiring.
- US6: T020 and T022 can be split between recorder logic and manifest/documentation updates.
- US7: T028 and T029 can be split between model/haptics and view timing.
- US4: T031 and T032 can be split between variant configuration and menu wiring.

## Implementation Strategy

### MVP First

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational prerequisites.
3. Complete Phase 3: User Story 1.
4. Stop and validate the timer core before moving on.

### Incremental Delivery

1. Deliver User Story 1 as the baseline match timer.
2. Add User Story 2 for scoring and conversion behavior.
3. Add User Story 5 for start confirmation and safe exit paths.
4. Add User Story 6 for activity recording and motion data.
5. Add User Story 3 for discipline timing.
6. Add User Story 7 for the half-warning haptic.
7. Finish with User Story 4 for variant adjustments and presets.

### Parallel Team Strategy

1. One developer can own the shared model and recorder changes while another handles layouts and delegates.
2. After Phase 2, User Stories 2, 5, and 6 can move in parallel because they touch mostly separate surfaces.
3. Discipline and half-warning work can proceed in parallel once the shared haptic/model hooks are ready.

## Notes

- `[P]` tasks can run in parallel when file ownership does not overlap.
- User story labels map directly to the feature spec for traceability.
- The feature should remain usable after each phase checkpoint, not only at the end.
- Keep regression-sensitive timer, scoring, recording, and layout behavior covered throughout implementation.
