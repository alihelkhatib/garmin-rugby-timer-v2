# Tasks: idle-timer-controls

**Input**: Design documents from `/Users/600171959/Projects/garmin-rugby-timer-v2/specs/003-idle-timer-controls/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/ui-interaction-contract.md](contracts/ui-interaction-contract.md), [quickstart.md](quickstart.md)

**Tests**: Tests and simulator/device checks are required because this feature touches timer setup, physical-button routing, score-dialog availability, and active-match regression behavior.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the existing input/model boundaries and add the minimum test surface needed for the feature.

- [ ] T001 Inspect current idle and active physical-button mappings in `source/RugbyTimerDelegate.mc` and document any state gates in `specs/003-idle-timer-controls/research.md`
- [ ] T002 [P] Inspect existing half-length bounds and variant preset helpers in `source/RugbyVariantConfig.mc` and document the selected-variant normal-half bound in `specs/003-idle-timer-controls/data-model.md`
- [ ] T003 [P] Create a delegate/model-focused test file for idle button routing in `tests/Test_RugbyIdleTimerControls.mc`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add shared model capabilities and test helpers needed before user-story implementation.

**CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T004 Add selected-variant normal half-length lookup support in `source/RugbyVariantConfig.mc`
- [ ] T005 Add idle main-timer adjustment model behavior with 60-second step, 00:00 lower bound, and selected-variant normal-half upper bound in `source/RugbyGameModel.mc`
- [ ] T006 [P] Add model tests for idle timer decrement-to-00:00 and increment-to-selected-variant-normal-half bounds in `tests/Test_RugbyGameModel.mc`
- [ ] T007 [P] Add variant-bound tests covering 15s, 7s, 10s, and U19 normal half lengths in `tests/Test_RugbyVariantConfig.mc`

**Checkpoint**: Foundation ready - idle timer behavior exists in the model and can be used by button routing.

---

## Phase 3: User Story 1 - Adjust Main Timer Before Kickoff (Priority: P1) MVP

**Goal**: Referee can use idle Up/Menu and Down presses to adjust the main timer before kickoff.

**Independent Test**: From the not-started idle screen, Up/Menu increases by 1 minute until the selected variant's normal half length, Down decreases by 1 minute until 00:00, and starting the match uses the adjusted value.

### Tests for User Story 1

- [ ] T008 [P] [US1] Add idle Up/Menu increment delegate tests in `tests/Test_RugbyIdleTimerControls.mc`
- [ ] T009 [P] [US1] Add idle Down decrement delegate tests in `tests/Test_RugbyIdleTimerControls.mc`
- [ ] T010 [P] [US1] Add match-start-from-adjusted-idle-timer tests in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 1

- [ ] T011 [US1] Route idle Up/Menu short-press to model timer increment behavior in `source/RugbyTimerDelegate.mc`
- [ ] T012 [US1] Route idle Down short-press to model timer decrement behavior in `source/RugbyTimerDelegate.mc`
- [ ] T013 [US1] Ensure idle timer adjustment requests a visible refresh without adding a new layout or manual drawing path in `source/RugbyTimerDelegate.mc`
- [ ] T014 [US1] Verify the existing main timer snapshot/render path displays the adjusted idle value in `source/RugbyTimerView.mc`

**Checkpoint**: User Story 1 is fully functional and testable independently.

---

## Phase 4: User Story 2 - Block Score Menu While Idle (Priority: P1)

**Goal**: Score dialog is unavailable from physical-button paths before a match has started.

**Independent Test**: From the not-started idle screen, Up/Menu, Down, and any existing score-dialog physical-button path do not open the score dialog.

### Tests for User Story 2

- [ ] T015 [P] [US2] Add idle Up/Menu score-dialog block tests in `tests/Test_RugbyIdleTimerControls.mc`
- [ ] T016 [P] [US2] Add idle Down and alternate physical-button score-dialog block tests in `tests/Test_RugbyIdleTimerControls.mc`
- [ ] T017 [P] [US2] Add match-ended score-dialog block regression tests in `tests/Test_RugbyIdleTimerControls.mc`

### Implementation for User Story 2

- [ ] T018 [US2] Tighten score-dialog state guard to allow only running, paused, and half-ended states in `source/RugbyTimerDelegate.mc`
- [ ] T019 [US2] Ensure idle Up/Menu and Down paths consume the button event without pushing score or card menus in `source/RugbyTimerDelegate.mc`

**Checkpoint**: User Stories 1 and 2 both work independently and jointly fix the reported idle-screen bug.

---

## Phase 5: User Story 3 - Preserve In-Match Score Controls (Priority: P2)

**Goal**: Existing scoring workflows remain available while a match is running, paused, or half-ended.

**Independent Test**: In running, paused, and half-ended states, the score dialog opens through the existing physical-button path and score actions still update teams according to existing scoring rules.

### Tests for User Story 3

- [ ] T020 [P] [US3] Add running-state score-dialog availability regression tests in `tests/Test_RugbyIdleTimerControls.mc`
- [ ] T021 [P] [US3] Add paused-state score-dialog availability regression tests in `tests/Test_RugbyIdleTimerControls.mc`
- [ ] T022 [P] [US3] Add half-ended score-dialog availability regression tests in `tests/Test_RugbyIdleTimerControls.mc`
- [ ] T023 [P] [US3] Add score action regression checks for try, conversion, penalty goal, and drop goal in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 3

- [ ] T024 [US3] Preserve active score-dialog routing for running, paused, and half-ended states in `source/RugbyTimerDelegate.mc`
- [ ] T025 [US3] Verify active-match Down/card dialog behavior remains unchanged for running, paused, and half-ended states in `source/RugbyTimerDelegate.mc`

**Checkpoint**: All user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Full validation, documentation, and release-readiness checks.

- [ ] T026 Run the idle-timer-controls quickstart validation on simulator profiles and record results in `specs/003-idle-timer-controls/quickstart.md`
- [ ] T027 Run Monkey C regression tests for model, variant, scoring, card, conversion, and haptic behavior and create or update the results notes in `tests/README.md`
- [ ] T028 Validate watch-scale readability for adjusted idle timer values on representative small and large round profiles and record results in `specs/003-idle-timer-controls/quickstart.md`
- [ ] T029 Confirm activity-recording start/stop behavior is unchanged when starting from an adjusted idle timer and record the result in `specs/003-idle-timer-controls/quickstart.md`
- [ ] T030 [P] Update user-facing control documentation for idle timer adjustment and active scoring state rules in `README.md`
- [ ] T031 [P] Create or update feature traceability notes for new idle timer controls in `tests/TEST_TRACEABILITY.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 Setup**: No dependencies.
- **Phase 2 Foundational**: Depends on Phase 1 and blocks all user stories.
- **US1 (Phase 3)**: Depends on Phase 2.
- **US2 (Phase 4)**: Depends on Phase 2 and may be implemented alongside US1 because it touches the same delegate state gate.
- **US3 (Phase 5)**: Depends on Phase 2 and should run after US1/US2 when working sequentially to verify regressions after idle routing changes.
- **Polish (Phase 6)**: Depends on all selected user stories.

### User Story Dependencies

- **US1**: Independent after foundation; delivers the timer-adjustment MVP.
- **US2**: Independent after foundation; delivers the score-dialog block while idle.
- **US3**: Independent regression story after foundation; confirms active-match score flows remain available.

### Parallel Opportunities

- T002 and T003 can run in parallel after T001 starts because they inspect different files/artifacts.
- T006 and T007 can run in parallel after T004 and T005 define the expected model/config behavior.
- US1 test tasks T008, T009, and T010 can run in parallel before implementation.
- US2 test tasks T015, T016, and T017 can run in parallel before implementation.
- US3 test tasks T020, T021, T022, and T023 can run in parallel before implementation.
- Documentation tasks T030 and T031 can run in parallel after behavior is implemented.

---

## Parallel Example: User Story 1

```bash
# Independent test tasks:
Task T008: Add idle Up/Menu increment delegate tests in tests/Test_RugbyIdleTimerControls.mc
Task T009: Add idle Down decrement delegate tests in tests/Test_RugbyIdleTimerControls.mc
Task T010: Add match-start-from-adjusted-idle-timer tests in tests/Test_RugbyGameModel.mc
```

---

## Implementation Strategy

### MVP First

1. Complete Phase 1 setup.
2. Complete Phase 2 foundational model/config behavior.
3. Complete US1 and US2 because they share the idle button-routing fix.
4. Stop and validate: idle Up/Menu increments, idle Down decrements, idle score dialog remains blocked, and match start uses the adjusted timer.

### Incremental Delivery

1. Add bounded idle timer model behavior.
2. Add idle button routing and score-dialog block.
3. Add active-match score routing regression checks.
4. Run quickstart and full model/variant regression checks.

### Notes

- [P] tasks use different files or can be drafted independently before integration.
- Each user-story task includes a file path for traceability.
- Tests should fail before implementation when practical.
- Keep implementation limited to existing model/delegate/view/resource boundaries unless a task discovers a constitution-safe reason to expand scope.
