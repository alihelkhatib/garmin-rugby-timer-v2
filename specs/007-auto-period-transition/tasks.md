# Tasks: Auto Period Transition

**Input**: Design documents from `/specs/007-auto-period-transition/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/period-transition-contract.md, quickstart.md

**Tests**: Tests are included because the constitution requires regression coverage for timer synchronization, card timer expiry, manual period/match controls, and activity-recording behavior touched by this feature.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm active feature scope and repository hygiene before implementation.

- [X] T001 Review `specs/007-auto-period-transition/spec.md`, `specs/007-auto-period-transition/plan.md`, `specs/007-auto-period-transition/research.md`, `specs/007-auto-period-transition/data-model.md`, and `specs/007-auto-period-transition/contracts/period-transition-contract.md` before editing code
- [X] T002 Verify `.gitignore` already covers generated Connect IQ outputs such as `bin/`, build artifacts, temporary files, and logs without modifying unrelated ignore settings
- [X] T003 [P] Add 007 traceability placeholders for the three user stories in `tests/TEST_TRACEABILITY.md`
- [X] T004 [P] Add 007 validation status placeholders for compile, test, simulator, and device checks in `tests/README.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared model helpers and test seams needed by all user stories.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T005 Inspect current half transition, match end, active elapsed, sanction snapshot, and timer expiry paths in `source/RugbyGameModel.mc`
- [X] T006 Add model helper tests for detecting countdown expiry and final-period boundaries in `tests/Test_RugbyGameModel.mc`
- [X] T007 Implement shared countdown-expiry/final-period helper methods in `source/RugbyGameModel.mc`
- [X] T008 Implement shared yellow-card remaining-time preservation helper methods for period boundaries in `source/RugbyGameModel.mc`
- [X] T009 Add focused diagnostics for automatic period expiry, automatic match expiry, and yellow-card carry-forward in `source/RugbyGameModel.mc`

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Auto-End Non-Final Period (Priority: P1) MVP

**Goal**: A running non-final period automatically enters the existing between-period flow when the main countdown reaches 00:00.

**Independent Test**: Start a match in a non-final period, advance active match time to the countdown expiry boundary, and verify the snapshot leaves running timing for the between-period state without manual end-period confirmation.

### Tests for User Story 1

- [X] T010 [US1] Add non-final running period auto-end tests in `tests/Test_RugbyGameModel.mc`
- [X] T011 [US1] Add manual end-half regression tests confirming existing explicit end-half behavior still reaches the same between-period state in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 1

- [X] T012 [US1] Invoke automatic non-final period transition during model snapshot/update evaluation in `source/RugbyGameModel.mc`
- [X] T013 [US1] Preserve existing half-ended start-next-period state fields after automatic non-final period transition in `source/RugbyGameModel.mc`
- [X] T014 [US1] Add non-final period transition traceability notes in `tests/TEST_TRACEABILITY.md`

**Checkpoint**: User Story 1 is functional and independently testable.

---

## Phase 4: User Story 2 - Auto-End Final Period And Match (Priority: P1)

**Goal**: A running final period automatically enters the existing match-ended summary/save flow when the main countdown reaches 00:00.

**Independent Test**: Start or advance to the final configured period, advance active match time to the countdown expiry boundary, and verify the model enters match-ended state with score, event log, card state, and summary state preserved.

### Tests for User Story 2

- [X] T015 [US2] Add final-period running countdown auto-end tests in `tests/Test_RugbyGameModel.mc`
- [X] T016 [US2] Add final-period score, event log, card state, and summary preservation tests in `tests/Test_RugbyGameModel.mc`
- [X] T017 [US2] Add manual end-match regression tests confirming explicit end-match behavior still reaches the existing summary/save state in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 2

- [X] T018 [US2] Invoke automatic final-period match transition during model snapshot/update evaluation in `source/RugbyGameModel.mc`
- [X] T019 [US2] Preserve existing match-ended summary and active timer shutdown behavior after automatic final-period transition in `source/RugbyGameModel.mc`
- [X] T020 [US2] Review whether automatic final match end needs delegate-side recorder handling and, only if required, integrate the existing recorder save path in `source/RugbyTimerDelegate.mc`
- [X] T021 [US2] Add final-period transition traceability notes in `tests/TEST_TRACEABILITY.md`

**Checkpoint**: User Stories 1 and 2 are functional and independently testable.

---

## Phase 5: User Story 3 - Carry Active Card Timers Into Next Period (Priority: P1)

**Goal**: Unexpired yellow-card timers pause at a non-final period boundary and resume in the next period with the same team assignment and remaining time.

**Independent Test**: Start yellow-card timers near a non-final period boundary, advance the main countdown to 00:00, confirm unexpired timers pause and remain present during the break, then start the next period and confirm they resume from preserved remaining time.

### Tests for User Story 3

- [X] T022 [US3] Add single yellow-card carry-forward test across non-final period expiry in `tests/Test_RugbyGameModel.mc`
- [X] T023 [US3] Add multiple Home/Away yellow-card carry-forward tests preserving team assignment and remaining time in `tests/Test_RugbyGameModel.mc`
- [X] T024 [US3] Add simultaneous yellow-card expiry and period-expiry regression test preventing expired timers from being revived in `tests/Test_RugbyGameModel.mc`
- [X] T025 [US3] Add paused-at-00:00 regression test preventing unexpected automatic transition on paused snapshots in `tests/Test_RugbyGameModel.mc`
- [X] T026 [US3] Add red-card and conversion timer non-regression assertions around period expiry in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 3

- [X] T027 [US3] Preserve unexpired yellow-card remaining time before non-final period active elapsed resets in `source/RugbyGameModel.mc`
- [X] T028 [US3] Resume carried yellow-card timers when the next period starts in `source/RugbyGameModel.mc`
- [X] T029 [US3] Prevent expired or cleared yellow-card timers from being carried into the next period in `source/RugbyGameModel.mc`
- [X] T030 [US3] Ensure paused-at-00:00 snapshots do not trigger automatic period or match transition in `source/RugbyGameModel.mc`
- [X] T031 [US3] Preserve existing red-card non-countdown and conversion timer behavior around period expiry in `source/RugbyGameModel.mc`
- [X] T032 [US3] Add carried yellow-card timer traceability notes in `tests/TEST_TRACEABILITY.md`

**Checkpoint**: All user stories are functional and independently testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and documentation across all user stories.

- [X] T033 Run full Monkey C app compile for `fenix7` using `monkey.jungle` and record the result in `tests/README.md`
- [X] T034 Run full Monkey C test compile for `fenix7` using `monkey.jungle` and record the result in `tests/README.md`
- [X] T035 Run simulator test artifact with `monkeydo build/garmin-rugby-timer-fenix7-test.prg fenix7 -t` when simulator access is available and record the result or blocker in `tests/README.md`
- [X] T036 Validate `specs/007-auto-period-transition/quickstart.md` scenarios on simulator or device when available and record manual status in `tests/README.md`
- [X] T037 [P] Update developer-facing behavior notes for automatic period transition in `README.md`
- [X] T038 Review `source/RugbyGameModel.mc`, `source/RugbyTimerDelegate.mc`, `tests/Test_RugbyGameModel.mc`, and `tests/TEST_TRACEABILITY.md` for simplicity, regression isolation, and no speculative abstractions
- [X] T039 Confirm no new persistence, network behavior, dependencies, or red-card countdown behavior were introduced and record the security/privacy result in `tests/README.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational and is the MVP.
- **User Story 2 (Phase 4)**: Depends on Foundational; can be validated independently but shares `source/RugbyGameModel.mc` with US1.
- **User Story 3 (Phase 5)**: Depends on Foundational; should be integrated after US1 because it relies on non-final period transition behavior.
- **Polish (Phase 6)**: Depends on all selected user stories.

### User Story Dependencies

- **US1 Auto-End Non-Final Period**: MVP; no dependency on other user stories after foundation.
- **US2 Auto-End Final Period And Match**: no dependency on US3; shares expiry helper behavior with US1.
- **US3 Carry Active Card Timers Into Next Period**: depends on the non-final period transition behavior from US1 for complete carry-forward validation.

### Parallel Opportunities

- T003 and T004 can run in parallel after T001.
- Most story implementation tasks touch `source/RugbyGameModel.mc` and should be sequential.
- Documentation tasks T014, T021, and T032 can run after their corresponding story tests and implementation are stable.
- T037 can run in parallel with T038 and T039 after implementation behavior is stable.

---

## Parallel Example: Setup Documentation

```bash
Task: "T003 Add 007 traceability placeholders for the three user stories in tests/TEST_TRACEABILITY.md"
Task: "T004 Add 007 validation status placeholders for compile, test, simulator, and device checks in tests/README.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete Phase 3 for non-final period automatic transition.
3. Stop and validate that a non-final running period reaches the existing between-period state at 00:00 without manual confirmation.

### Incremental Delivery

1. Deliver US1 automatic non-final period transition.
2. Add US2 automatic final-period match end.
3. Add US3 yellow-card carry-forward and paused-boundary safeguards.
4. Run quickstart scenarios and regression compile/test validation.

### Simplicity Guardrails

- Keep countdown expiry and carried yellow-card logic in `source/RugbyGameModel.mc`; do not introduce a second timer loop or scheduler.
- Reuse existing between-period and match-ended flows; do not add a new full-time or auto-ended screen.
- Keep red cards non-countdown and conversion timer behavior unchanged unless an existing regression requires a narrow fix.
- Do not add persistent storage, network behavior, telemetry, or dependencies.
