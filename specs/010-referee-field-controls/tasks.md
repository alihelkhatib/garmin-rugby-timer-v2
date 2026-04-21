# Tasks: Referee Field Controls

**Input**: Design documents from `/specs/010-referee-field-controls/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/ui-interaction-contract.md`, `quickstart.md`

**Tests**: Required by the feature specification and constitution because this feature changes timer expiry, scoring/card rollback, match menu behavior, summary viewing, haptics, and activity save/discard flows.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`US1`, `US2`, `US3`)
- All descriptions include exact file paths

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare shared resources and traceability before behavior changes.

- [ ] T001 Update feature traceability entries for referee field controls in `tests/TEST_TRACEABILITY.md`
- [ ] T002 Add shared menu/status strings for undo, confirm undo, time-up, overtime, and end-half labels in `resources/strings/strings.xml`
- [ ] T003 Update Back-button match menu resource entries for undo, end-half, summary, end-match, and reset actions in `resources/menus/match_options.xml`
- [ ] T004 [P] Document expected simulator validation targets for this feature in `specs/010-referee-field-controls/quickstart.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add shared state shape and menu routing prerequisites needed by all user stories.

**CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T005 Add shared model constants for `timeUp`, pending undo, pending end-half, and undoable score/card actions in `source/RugbyGameModel.mc`
- [ ] T006 Add snapshot fields for `overtimeSeconds`, `canUndoLastEvent`, `latestUndoableEvent`, and `isTimeUp` in `source/RugbyGameModel.mc`
- [ ] T007 Update match-state eligibility helpers for active, time-up, summary, score, card, and match-option states in `source/RugbyTimerDelegate.mc`
- [ ] T008 Add menu action dispatch cases for undo and end-half identifiers in `source/RugbyTimerDelegate.mc`
- [ ] T009 [P] Add time-up and undo labels to the UI interaction traceability notes in `specs/010-referee-field-controls/contracts/ui-interaction-contract.md`

**Checkpoint**: Foundation ready - user story implementation can now begin in priority order.

---

## Phase 3: User Story 1 - Undo Last Event (Priority: P1) MVP

**Goal**: Referee can undo only the latest score/card event from the Back-button match menu with confirmation and without disturbing unrelated match state.

**Independent Test**: Record a try, conversion, penalty goal, drop goal, yellow card, or red card; open the match menu; confirm undo; verify the latest event is removed and the visible score/card/summary state returns to the previous value.

### Tests for User Story 1

> Write these tests first and verify they fail before implementation.

- [ ] T010 [US1] Add model tests for undoing latest try, conversion, penalty goal, and drop goal in `tests/Test_RugbyGameModel.mc`
- [ ] T011 [US1] Add model tests for undoing latest yellow and red card sanctions in `tests/Test_RugbyGameModel.mc`
- [ ] T012 [US1] Add model tests for undo cancel/no-event/latest-only behavior in `tests/Test_RugbyGameModel.mc`
- [ ] T013 [US1] Add model tests for undoing a try with an active conversion opportunity and undoing a made conversion without removing the try in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 1

- [ ] T014 [US1] Enrich score event creation with score delta, counter field, and conversion-timer linkage metadata in `source/RugbyGameModel.mc`
- [ ] T015 [US1] Enrich yellow/red card event creation with sanction id metadata in `source/RugbyGameModel.mc`
- [ ] T016 [US1] Implement latest-event eligibility helpers and `requestUndoLastEvent()` in `source/RugbyGameModel.mc`
- [ ] T017 [US1] Implement confirmed latest-event rollback for score, conversion, try-created conversion timer, yellow card, and red card in `source/RugbyGameModel.mc`
- [ ] T018 [US1] Integrate pending undo confirmation into `confirmPending()`, `cancelPendingAction()`, and snapshot state in `source/RugbyGameModel.mc`
- [ ] T019 [US1] Add `requestUndoLastEvent()` routing and confirmation handling in `source/RugbyTimerDelegate.mc`
- [ ] T020 [US1] Show or suppress the undo menu action based on model snapshot eligibility in `source/RugbyTimerDelegate.mc`
- [ ] T021 [US1] Ensure undo confirmation status text is readable and distinct from other confirmations in `source/RugbyTimerView.mc`
- [ ] T022 [US1] Verify existing score/card/conversion tests still pass after undo metadata changes in `tests/Test_RugbyGameModel.mc`

**Checkpoint**: User Story 1 is complete when latest-only undo passes for all score/card event types and existing score/card/conversion behavior is preserved.

---

## Phase 4: User Story 2 - Referee-Confirmed Time Expiry (Priority: P2)

**Goal**: Regulation time reaching zero enters a time-up overtime state and only ends the period or match after Back-button match menu confirmation; Select/Start remains pause/resume.

**Independent Test**: Run a half to zero, verify time-up/overtime appears and continues counting, then confirm period end from the Back-button menu and verify half-time or match-end flow.

### Tests for User Story 2

> Write these tests first and verify they fail before implementation.

- [ ] T023 [US2] Replace non-final auto-expiry tests with time-up overtime expectations in `tests/Test_RugbyGameModel.mc`
- [ ] T024 [US2] Replace final-period auto-end tests with time-up pending-confirmation expectations in `tests/Test_RugbyGameModel.mc`
- [ ] T025 [US2] Add tests that Select/Start pause/resume behavior remains unchanged during time-up overtime in `tests/Test_RugbyGameModel.mc`
- [ ] T026 [US2] Add tests that score/card/conversion timers remain available and timestamp consistently during time-up overtime in `tests/Test_RugbyGameModel.mc`
- [ ] T027 [US2] Add haptic test for one-time time-up alert behavior in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 2

- [ ] T028 [US2] Replace automatic countdown expiry mutation with explicit `timeUp` state transition in `source/RugbyGameModel.mc`
- [ ] T029 [US2] Add overtime elapsed calculation and countdown clamping for time-up snapshots in `source/RugbyGameModel.mc`
- [ ] T030 [US2] Add Back-button menu end-half/end-match pending confirmation behavior for time-up states in `source/RugbyGameModel.mc`
- [ ] T031 [US2] Preserve pause/resume active elapsed behavior for time-up overtime without letting Select/Start confirm period end in `source/RugbyTimerDelegate.mc`
- [ ] T032 [US2] Allow score and card menus during time-up where existing active-match rules allow them in `source/RugbyTimerDelegate.mc`
- [ ] T033 [US2] Bind `TIME` and overtime display/status without hiding score, card, or conversion context in `source/RugbyTimerView.mc`
- [ ] T034 [US2] Add or reuse a one-time time-up haptic pattern in `source/RugbyHaptics.mc`
- [ ] T035 [US2] Remove auto-match-end save trigger assumptions and ensure activity save occurs only after confirmed match end in `source/RugbyTimerView.mc`
- [ ] T036 [US2] Verify yellow-card carry-forward and conversion timer behavior around time-up in `tests/Test_RugbyGameModel.mc`

**Checkpoint**: User Story 2 is complete when regulation expiry never ends a period automatically, overtime remains visible, Back-button confirmation ends periods/matches, and Select/Start still pauses/resumes.

---

## Phase 5: User Story 3 - Scrollable Recent-First Match Summary (Priority: P3)

**Goal**: Referee can open match summary from the Back-button menu in match states, see newest events first, scroll through all events, and exit without modifying match state.

**Independent Test**: Record more events than fit on one screen, open summary, verify newest first, scroll through older events, exit back to the prior match state, and confirm undone events are absent.

### Tests for User Story 3

> Write these tests first and verify they fail before implementation.

- [ ] T037 [US3] Add summary ordering tests for newest-first event display in `tests/match_summary_regression_test.mc`
- [ ] T038 [US3] Add summary scroll-window tests for zero, one, one-screen, and twenty-event lists in `tests/match_summary_regression_test.mc`
- [ ] T039 [P] [US3] Add summary access state tests for active, paused, half-ended, time-up, match-ended, pre-match, and reset states in `tests/match_summary_endflow_test.mc`
- [ ] T040 [P] [US3] Add summary empty-state regression test in `tests/match_summary_empty_state_test.mc`

### Implementation for User Story 3

- [ ] T041 [US3] Add summary scroll offset, visible row calculation, and Up/Down navigation handling in `source/RugbyMatchSummaryView.mc`
- [ ] T042 [US3] Render summary rows newest-first while preserving underlying chronological event data in `source/RugbyMatchSummaryView.mc`
- [ ] T043 [US3] Render zero-event empty state through existing summary resources in `source/RugbyMatchSummaryView.mc`
- [ ] T044 [US3] Update summary delegate Back/Select behavior to return to prior match context without exiting active matches unexpectedly in `source/RugbyTimerDelegate.mc`
- [ ] T045 [US3] Ensure Back-button match menu exposes summary in active, paused, half-ended, time-up, and match-ended states only in `source/RugbyTimerDelegate.mc`
- [ ] T046 [US3] Align summary static labels and layout resources with scrollable summary behavior in `resources/layouts/match_summary_layout.xml`
- [ ] T047 [US3] Ensure undone events are absent from summary snapshots and display after US1 rollback in `source/RugbyMatchSummaryView.mc`

**Checkpoint**: User Story 3 is complete when all events are reachable by physical-button scrolling, newest event is initially visible, and summary access preserves match state.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validate integrated behavior across all stories and prepare for implementation handoff/release.

- [ ] T048 Run all model, summary, activity-recorder, idle-control, and variant tests listed in `tests/README.md`
- [ ] T049 Run the simulator smoke flow from `specs/010-referee-field-controls/quickstart.md`
- [ ] T050 Validate small and large watch readability for time-up, undo confirmation, and summary scrolling using `resources/layouts/layout.xml` and `resources/layouts/match_summary_layout.xml`
- [ ] T051 Validate activity save/discard behavior after confirmed time-up match end and reset in `source/RugbyActivityRecorder.mc`
- [ ] T052 Validate no new persistent storage, network access, telemetry, or dependencies were introduced in `source/` and `resources/`
- [ ] T053 Compare compiled artifact size with existing `garmin-rugby-timer-v2.iq` or latest build output and document any unexpected growth in `specs/010-referee-field-controls/quickstart.md`
- [ ] T054 Update user-facing control documentation for undo, time-up overtime, and scrollable summary in `README.md`
- [ ] T055 Update developer validation notes for this feature in `docs/DEVELOPER.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational completion. This is the MVP.
- **User Story 2 (Phase 4)**: Depends on Foundational completion; can be implemented after or alongside US1, but final integration must preserve US1 undo behavior.
- **User Story 3 (Phase 5)**: Depends on Foundational completion; final validation depends on US1 so undone events are absent from summary.
- **Polish (Phase 6)**: Depends on all implemented user stories.

### User Story Dependencies

- **US1 - Undo Last Event**: Independent MVP after Foundation.
- **US2 - Referee-Confirmed Time Expiry**: Independent after Foundation; integration check required with US1 because undo is allowed in time-up state.
- **US3 - Scrollable Recent-First Match Summary**: Independent summary display after Foundation; complete acceptance requires US1 integration for undone events and US2 integration for time-up menu access.

### Within Each User Story

- Tests must be written before implementation tasks.
- Model changes precede delegate/view/resource integration.
- Delegate/menu routing precedes simulator validation.
- Story checkpoint must pass before moving to the next priority in a sequential implementation.

### Parallel Opportunities

- T004 and T009 can run in parallel with resource/model setup tasks.
- US1 test design can be reviewed in parallel, but T010-T013 edit `tests/Test_RugbyGameModel.mc` and should be applied sequentially.
- US2 test design can be reviewed in parallel, but T023-T027 edit `tests/Test_RugbyGameModel.mc` and should be applied sequentially.
- US3 tests T039-T040 touch separate summary test files and can run in parallel with T037-T038 after coordinating edits to `tests/match_summary_regression_test.mc`.
- Polish validation tasks T050-T055 can run in parallel after core implementation.

---

## Parallel Example: User Story 3

```text
Task: "Add summary ordering tests for newest-first event display in tests/match_summary_regression_test.mc"
Task: "Add summary access state tests for active, paused, half-ended, time-up, match-ended, pre-match, and reset states in tests/match_summary_endflow_test.mc"
Task: "Add summary empty-state regression test in tests/match_summary_empty_state_test.mc"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 setup.
2. Complete Phase 2 foundation.
3. Complete Phase 3 latest-only undo.
4. Stop and validate all US1 tests plus existing score/card/conversion regression tests.
5. Demo undo from the Back-button match menu before implementing time-up or summary scrolling.

### Incremental Delivery

1. Add latest-only undo and confirm rollback correctness.
2. Add time-up overtime while preserving undo and activity save/discard behavior.
3. Add scrollable recent-first summary and verify undone/time-up events render correctly.
4. Run final quickstart and device/simulator validation.

### Parallel Team Strategy

After Phase 2:

- Developer A: US1 model and menu undo.
- Developer B: US2 time-up model and haptics.
- Developer C: US3 summary scrolling tests/view.

Coordinate edits to `source/RugbyGameModel.mc`, `source/RugbyTimerDelegate.mc`, and `tests/Test_RugbyGameModel.mc` because those files are shared across stories.

---

## Notes

- `[P]` tasks indicate potential parallel work, but shared Monkey C test files still require merge coordination.
- Keep implementation scoped to current-match runtime state; do not add persistent match history.
- Keep static text and stable layout in resources where feasible.
- Manual drawing is acceptable only for dynamic summary rows if resource text areas cannot safely scroll event windows.
- Existing unrelated `manifest.xml` changes should not be reverted as part of this feature.
