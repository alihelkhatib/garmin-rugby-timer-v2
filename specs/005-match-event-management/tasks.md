# Tasks: Match Event Management

**Input**: Design documents from `/specs/005-match-event-management/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/ui-interaction-contract.md, quickstart.md

**Tests**: Tests are included because the constitution requires regression coverage for timer synchronization, scoring, card, haptic, UI, and activity-recording behavior touched by this feature.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the feature artifacts and current code surface before implementation.

- [X] T001 Review `specs/005-match-event-management/spec.md`, `specs/005-match-event-management/plan.md`, `specs/005-match-event-management/data-model.md`, and `specs/005-match-event-management/contracts/ui-interaction-contract.md` for scope before editing code
- [X] T002 [P] Document 005 traceability placeholders in `tests/TEST_TRACEABILITY.md`
- [X] T003 [P] Add 005 validation section placeholders in `tests/README.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared model and diagnostics needed by all user stories.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Add model-owned event log fields and reset helpers to `source/RugbyGameModel.mc`
- [X] T005 Add model APIs for event-log snapshots, current match elapsed seconds, and current-match summary state in `source/RugbyGameModel.mc`
- [X] T006 Add diagnostic logging for event-log add/clear, reset match, and activity export decisions in `source/RugbyGameModel.mc`
- [X] T007 [P] Add haptic helper APIs for pause and pause reminder feedback in `source/RugbyHaptics.mc`
- [X] T008 [P] Add resource strings for match options, match summary, event actions, and reset/end labels in `resources/strings/strings.xml`
- [X] T009 [P] Add match option and match summary menu resource files in `resources/menus/match_options.xml` and `resources/menus/match_summary.xml`
- [X] T010 Run Garmin app compile after foundational changes using `monkey.jungle` and record the result in `tests/README.md`

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Automatic Conversion After Try (Priority: P1) MVP

**Goal**: A try opens the conversion overlay and starts the conversion countdown automatically, including when the main match clock is paused; non-try scores do not open a conversion overlay.

**Independent Test**: Pause the match, record a Home or Away try, and verify the conversion overlay appears with a running countdown without pressing Select.

### Tests for User Story 1

- [X] T011 [P] [US1] Add paused-match try conversion timer tests in `tests/Test_RugbyGameModel.mc`
- [X] T012 [P] [US1] Add non-try score no-conversion regression tests in `tests/Test_RugbyGameModel.mc`
- [X] T013 [P] [US1] Add delegate/menu try routing regression tests in `tests/Test_RugbyIdleTimerControls.mc`

### Implementation for User Story 1

- [X] T014 [US1] Update conversion timer start logic for paused tries in `source/RugbyGameModel.mc`
- [X] T015 [US1] Update try score routing to open conversion overlay after model conversion start in `source/RugbyTeamActionDelegate.mc`
- [X] T016 [US1] Add automatic conversion update logging in `source/RugbyTeamActionDelegate.mc` and `source/RugbyGameModel.mc`
- [X] T017 [P] [US1] Move only the conversion overlay timer upward in `resources/layouts/layout.xml`
- [X] T018 [US1] Update conversion overlay binding diagnostics and value-based team display in `source/RugbyConversionView.mc`
- [X] T019 [US1] Run app and test compiles for `fenix7` using `monkey.jungle` and record results in `tests/README.md`

**Checkpoint**: User Story 1 is functional and independently testable.

---

## Phase 4: User Story 2 - Pause Awareness And Card Pause Behavior (Priority: P1)

**Goal**: Pausing gives immediate haptic feedback, paused state gives recurring reminders, and card issuance pauses the match while recording the card.

**Independent Test**: Pause a running match, observe pause haptics/reminders, issue yellow and red cards, and verify the match is paused after each card.

### Tests for User Story 2

- [X] T020 [P] [US2] Add pause/resume reminder state tests in `tests/Test_RugbyGameModel.mc`
- [X] T021 [P] [US2] Add card-triggered pause tests for yellow and red cards in `tests/Test_RugbyGameModel.mc`
- [X] T022 [P] [US2] Add delegate-level card pause routing tests in `tests/Test_RugbyIdleTimerControls.mc`

### Implementation for User Story 2

- [X] T023 [US2] Update pause transition behavior and pause reminder state in `source/RugbyGameModel.mc`
- [X] T024 [US2] Implement pause and pause reminder haptic calls in `source/RugbyHaptics.mc`
- [X] T025 [US2] Add pause reminder timer start/stop integration in `source/RugbyTimerView.mc`
- [X] T026 [US2] Pause the match when yellow or red cards are issued in `source/RugbyTeamActionDelegate.mc`
- [X] T027 [US2] Add card pause and haptic diagnostic logs in `source/RugbyTeamActionDelegate.mc`, `source/RugbyHaptics.mc`, and `source/RugbyTimerView.mc`
- [X] T028 [US2] Run app and test compiles for `fenix7` using `monkey.jungle` and record results in `tests/README.md`

**Checkpoint**: User Stories 1 and 2 are functional and independently testable.

---

## Phase 5: User Story 3 - Match Event Log (Priority: P2)

**Goal**: Point-scoring and card events are logged with team, action, and match elapsed time, visible at match end, and exported with the activity only when supported.

**Independent Test**: Record try, made conversion, penalty goal, drop goal, yellow card, and red card events; end the match and verify event log ordering and current-match retention.

### Tests for User Story 3

- [X] T029 [P] [US3] Add event-log entry creation tests for point-scoring actions in `tests/Test_RugbyGameModel.mc`
- [X] T030 [P] [US3] Add event-log entry creation tests for yellow and red cards in `tests/Test_RugbyGameModel.mc`
- [X] T031 [P] [US3] Add event-log clear-on-reset and clear-on-new-match tests in `tests/Test_RugbyGameModel.mc`
- [X] T032 [P] [US3] Add activity export fallback tests in `tests/Test_RugbyActivityRecorder.mc`

### Implementation for User Story 3

- [X] T033 [US3] Record try, made conversion, penalty goal, and drop goal events in `source/RugbyGameModel.mc`
- [X] T034 [US3] Record yellow and red card events in `source/RugbyGameModel.mc`
- [X] T035 [US3] Add event log snapshot fields for match summary rendering in `source/RugbyGameModel.mc`
- [X] T036 [US3] Add best-effort activity event export diagnostics in `source/RugbyActivityRecorder.mc`
- [X] T037 [US3] Implement match summary menu/view routing for event log review in `source/RugbyTimerDelegate.mc`
- [X] T038 [US3] Bind match summary event labels using resources in `resources/menus/match_summary.xml` and `resources/strings/strings.xml`
- [X] T039 [US3] Run app and test compiles for `fenix7` using `monkey.jungle` and record results in `tests/README.md`

**Checkpoint**: User Stories 1, 2, and 3 are functional and independently testable.

---

## Phase 6: User Story 4 - End Or Reset From Back (Priority: P2)

**Goal**: Back presents explicit End match and Reset match choices; End saves, Reset discards and returns to pre-match setup, and cancel leaves state unchanged.

**Independent Test**: Press Back during a match, cancel once, end/save once, and reset/discard once; verify state and event log outcomes.

### Tests for User Story 4

- [X] T040 [P] [US4] Add model reset-to-pre-match tests in `tests/Test_RugbyGameModel.mc`
- [X] T041 [P] [US4] Add end-match event summary retention tests in `tests/Test_RugbyGameModel.mc`
- [X] T042 [P] [US4] Add Back option delegate routing tests in `tests/Test_RugbyIdleTimerControls.mc`

### Implementation for User Story 4

- [X] T043 [US4] Add reset-match model behavior that clears scores, timers, cards, conversion state, pending actions, event log, and unsaved current activity in `source/RugbyGameModel.mc`
- [X] T044 [US4] Add recorder discard/reset support for Reset match in `source/RugbyActivityRecorder.mc`
- [X] T045 [US4] Replace direct Back cancellation with match options routing in `source/RugbyTimerDelegate.mc`
- [X] T046 [US4] Implement match option selection delegate behavior in `source/RugbyTimerDelegate.mc`
- [X] T047 [P] [US4] Add End match and Reset match option resources in `resources/menus/match_options.xml` and `resources/strings/strings.xml`
- [X] T048 [US4] Add End match, Reset match, and cancel diagnostics in `source/RugbyTimerDelegate.mc`, `source/RugbyGameModel.mc`, and `source/RugbyActivityRecorder.mc`
- [X] T049 [US4] Run app and test compiles for `fenix7` using `monkey.jungle` and record results in `tests/README.md`

**Checkpoint**: All user stories are functional and independently testable.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and documentation across all user stories.

- [X] T050 Run full Monkey C regression compile and test compile for `fenix7` using `monkey.jungle` and record results in `tests/README.md`
- [X] T051 Run simulator test artifact with `monkeydo build/garmin-rugby-timer-fenix7-test.prg fenix7 -t` and record simulator availability/result in `tests/README.md`
- [ ] T052 Validate quickstart scenarios in `specs/005-match-event-management/quickstart.md` on simulator or device and record manual status in `tests/README.md`
- [X] T053 Update 005 traceability mappings in `tests/TEST_TRACEABILITY.md`
- [X] T054 [P] Update developer-facing behavior notes in `README.md`
- [X] T055 Review code for simplicity and remove redundant diagnostics or speculative abstractions from `source/RugbyGameModel.mc`, `source/RugbyTimerDelegate.mc`, `source/RugbyTimerView.mc`, and `source/RugbyHaptics.mc`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational and is the MVP.
- **User Story 2 (Phase 4)**: Depends on Foundational; can run after US1 or in parallel with careful file coordination, but shares `RugbyGameModel.mc`, `RugbyHaptics.mc`, and `RugbyTimerView.mc`.
- **User Story 3 (Phase 5)**: Depends on Foundational and benefits from US1/US2 event sources being present.
- **User Story 4 (Phase 6)**: Depends on Foundational and event-log/reset semantics from US3.
- **Polish (Phase 7)**: Depends on all selected user stories.

### User Story Dependencies

- **US1 Automatic Conversion After Try**: MVP; no dependency on other user stories after foundation.
- **US2 Pause Awareness And Card Pause Behavior**: no dependency on US3/US4, but shares pause state with US1 conversion behavior.
- **US3 Match Event Log**: depends on scoring/card action points implemented or preserved in US1/US2.
- **US4 End Or Reset From Back**: depends on event log entities and recorder behavior from US3 for complete reset/end semantics.

### Parallel Opportunities

- T002 and T003 can run in parallel.
- T007, T008, and T009 can run in parallel after T004/T005 are understood.
- Test-writing tasks within each user story can be drafted in parallel where they touch different test files.
- Resource-only tasks T017 and T047 can run in parallel with model/delegate work if file ownership is coordinated.
- Documentation tasks T053 and T054 can run in parallel after implementation behavior stabilizes.

---

## Parallel Example: User Story 1

```bash
# Independent test tasks
Task: "T011 Add paused-match try conversion timer tests in tests/Test_RugbyGameModel.mc"
Task: "T013 Add delegate/menu try routing regression tests in tests/Test_RugbyIdleTimerControls.mc"

# Independent resource/code tasks after tests are drafted
Task: "T017 Move only the conversion overlay timer upward in resources/layouts/layout.xml"
Task: "T018 Update conversion overlay binding diagnostics and value-based team display in source/RugbyConversionView.mc"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete Phase 3 for automatic conversion timing and conversion overlay layout.
3. Stop and validate paused-match Home/Away try conversion behavior and non-try regression behavior.

### Incremental Delivery

1. Deliver US1 automatic conversion after tries.
2. Add US2 pause haptics/reminders and card-triggered pause.
3. Add US3 current-match event log and match-end review.
4. Add US4 Back options for End match and Reset match.
5. Run quickstart scenarios and regression compile/test validation.

### Simplicity Guardrails

- Keep current-match event log in `RugbyGameModel.mc`; do not create persistence unless activity export support is proven available.
- Use existing view/delegate/menu patterns; avoid a new navigation framework.
- Keep red cards logged but do not add a red-card timer.
- Keep diagnostics targeted to conversion start, pause reminders, card pause, event log entries, activity export, end match, and reset match.
