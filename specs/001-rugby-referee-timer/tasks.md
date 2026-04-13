# Tasks: Rugby Referee Timer

**Input**: Design documents from `/specs/001-rugby-referee-timer/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Required by project constitution and plan for synchronized timers, variant rules, scoring, sanctions, haptics, activity recording, and regression-sensitive behavior.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Garmin Connect IQ app**: `source/`, `resources/`, `manifest.xml`, `monkey.jungle`, and `tests/` where supported
- **Feature docs**: `specs/001-rugby-referee-timer/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the Connect IQ watch app skeleton and repository hygiene.

- [X] T001 Create Connect IQ source/resource/test directories in `source/`, `resources/layouts/`, `resources/strings/`, `resources/drawables/`, and `tests/`
- [X] T002 Create Garmin app manifest with Fit permission and API/device target placeholders in `manifest.xml`
- [X] T003 Create Connect IQ build configuration for the app in `monkey.jungle`
- [X] T004 [P] Create baseline strings resource file for app/team labels and timer labels in `resources/strings/strings.xml`
- [X] T005 [P] Create baseline layout/resource placeholders for the main watch view in `resources/layouts/layout.xml`
- [X] T006 [P] Create or update repository ignore patterns for Connect IQ build artifacts in `.gitignore`

**Checkpoint**: Project structure is ready for model, view, and test files.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared models and infrastructure that MUST be complete before user story implementation.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T007 [P] Create failing variant preset tests for 15s, 7s, 10s, U19, and custom overrides in `tests/Test_RugbyVariantConfig.mc`
- [X] T008 [P] Create failing match clock tests for start, pause, resume, end-half, and snapshot derivation in `tests/Test_RugbyGameModel.mc`
- [X] T009 [P] Create failing scoring tests for try, conversion, penalty goal, drop goal counters, and lightweight correction actions in `tests/Test_RugbyGameModel.mc`
- [X] T010 [P] Create failing sanction/conversion timer tests for yellow countdowns, red indicators, conversion replacement, and 60-second alerts in `tests/Test_RugbyGameModel.mc`
- [X] T011 [P] Create failing activity recorder tests for rugby sport target, match sub-sport target, and fallback state in `tests/Test_RugbyActivityRecorder.mc`
- [X] T012 Implement rugby variant preset and override data in `source/RugbyVariantConfig.mc`
- [X] T013 Implement shared match, team, conversion, and discipline state model in `source/RugbyGameModel.mc`
- [X] T014 Implement haptic alert threshold helper for 60-second warnings in `source/RugbyHaptics.mc`
- [X] T015 Implement activity recording session wrapper for rugby recording and fallback state in `source/RugbyActivityRecorder.mc`
- [X] T016 Create app shell and lifecycle wiring in `source/RugbyTimerApp.mc`
- [X] T017 Create input delegate shell that routes watch actions to the model in `source/RugbyTimerDelegate.mc`
- [X] T018 Create render shell that draws from one model snapshot in `source/RugbyTimerView.mc`

**Checkpoint**: Shared timing, variant, scoring, sanction, haptic, activity, app, delegate, and view foundations exist.

---

## Phase 3: User Story 1 - Run Match Clock (Priority: P1) MVP

**Goal**: Referee can run match time with dominant countdown, secondary count-up active match timer display, half indicator, and synchronized pause/resume behavior.

**Independent Test**: Start a selected variant match, pause/resume it, end a half, and verify countdown, secondary timer, and half indicator remain readable and synchronized.

### Tests for User Story 1

- [X] T019 [P] [US1] Add match clock acceptance tests for start/pause/resume/end-half confirmation behavior in `tests/Test_RugbyGameModel.mc`
- [X] T020 [P] [US1] Add render snapshot contract checks for countdown, count-up active match timer, and half indicator visibility in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 1

- [X] T021 [US1] Implement match clock start, pause, resume, end-half confirmation, and match-ended transitions in `source/RugbyGameModel.mc`
- [X] T022 [US1] Implement countdown and count-up active match derived snapshot fields in `source/RugbyGameModel.mc`
- [X] T023 [US1] Wire start, pause, resume, and end-half input actions in `source/RugbyTimerDelegate.mc`
- [X] T024 [US1] Render dominant countdown, secondary count-up active match timer, and half indicator from one snapshot in `source/RugbyTimerView.mc`
- [X] T025 [US1] Add US1 manual validation steps to `specs/001-rugby-referee-timer/quickstart.md`

**Checkpoint**: User Story 1 is independently functional and testable as the MVP.

---

## Phase 4: User Story 2 - Manage Scores and Conversion Timer (Priority: P2)

**Goal**: Referee can record common rugby scoring and automatically manage the conversion timer after tries.

**Independent Test**: Record try, conversion, penalty goal, and drop goal for each team and verify score, scoring counters, and conversion timer behavior.

### Tests for User Story 2

- [X] T026 [P] [US2] Add scoring acceptance tests for try, conversion, penalty goal, drop goal, and correction actions in `tests/Test_RugbyGameModel.mc`
- [X] T027 [P] [US2] Add conversion timer replacement and 60-second haptic threshold tests in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 2

- [X] T028 [US2] Implement score, scoring counter updates, and lightweight correction actions in `source/RugbyGameModel.mc`
- [X] T029 [US2] Implement conversion timer start, replacement, expiry, and pause/resume derivation in `source/RugbyGameModel.mc`
- [X] T030 [US2] Wire scoring, correction, and conversion actions in `source/RugbyTimerDelegate.mc`
- [X] T031 [US2] Render fixed Home/Away labels, score, scoring counters, correction state, and conversion timer in `source/RugbyTimerView.mc`
- [X] T032 [US2] Integrate conversion timer haptic trigger through `source/RugbyHaptics.mc`
- [X] T033 [US2] Add US2 manual validation steps to `specs/001-rugby-referee-timer/quickstart.md`

**Checkpoint**: User Stories 1 and 2 work independently and together.

---

## Phase 5: User Story 3 - Manage Discipline Timers (Priority: P3)

**Goal**: Referee can track yellow-card countdowns and persistent red-card indicators without losing match clock visibility.

**Independent Test**: Start yellow and red sanctions for either team and verify yellow countdowns, red indicators, non-color cues, synchronization, and haptic alerts.

### Tests for User Story 3

- [X] T034 [P] [US3] Add yellow-card countdown and pause/resume tests in `tests/Test_RugbyGameModel.mc`
- [X] T035 [P] [US3] Add red-card persistent indicator and clear/end-match tests in `tests/Test_RugbyGameModel.mc`
- [X] T036 [P] [US3] Add yellow-card 60-second haptic threshold tests in `tests/Test_RugbyGameModel.mc`

### Implementation for User Story 3

- [X] T037 [US3] Implement yellow-card sanction countdown state and expiry behavior in `source/RugbyGameModel.mc`
- [X] T038 [US3] Implement red-card persistent sanction indicator state and clear behavior in `source/RugbyGameModel.mc`
- [X] T039 [US3] Wire yellow-card, red-card, and clear sanction input actions in `source/RugbyTimerDelegate.mc`
- [X] T040 [US3] Render active yellow-card countdowns and red-card indicators with text/icon/position cues in `source/RugbyTimerView.mc`
- [X] T041 [US3] Integrate yellow-card haptic alert delivery through `source/RugbyHaptics.mc`
- [X] T042 [US3] Add US3 manual validation steps to `specs/001-rugby-referee-timer/quickstart.md`

**Checkpoint**: User Stories 1, 2, and 3 work independently and together.

---

## Phase 6: User Story 4 - Choose and Adjust Rugby Variant (Priority: P4)

**Goal**: Referee can choose 15s, 7s, 10s, U19, or custom timing and adjust half, sin-bin, and conversion lengths.

**Independent Test**: Select each built-in preset, adjust timing values, and verify later match, yellow-card, and conversion timers use the selected values.

### Tests for User Story 4

- [X] T043 [P] [US4] Add preset coverage tests for 15s, 7s, 10s, U19, and custom in `tests/Test_RugbyVariantConfig.mc`
- [X] T044 [P] [US4] Add timing override tests for half length, sin-bin length, and conversion length in `tests/Test_RugbyVariantConfig.mc`
- [X] T045 [P] [US4] Add preference persistence tests for selected variant and timing overrides in `tests/Test_RugbyVariantConfig.mc`

### Implementation for User Story 4

- [X] T046 [US4] Implement variant selection and override application in `source/RugbyVariantConfig.mc`
- [X] T047 [US4] Implement lightweight preference load/save for selected variant and timing overrides in `source/RugbyVariantConfig.mc`
- [X] T048 [US4] Wire variant setup and timing adjustment input actions in `source/RugbyTimerDelegate.mc`
- [X] T049 [US4] Render lightweight variant setup and timing adjustment UI in `source/RugbyTimerView.mc`
- [X] T050 [US4] Connect variant setup values to match, yellow-card, and conversion timers in `source/RugbyGameModel.mc`
- [X] T051 [US4] Add US4 manual validation steps to `specs/001-rugby-referee-timer/quickstart.md`

**Checkpoint**: All user stories are independently functional and integrated.

---

## Phase 7: Activity Recording Integration

**Purpose**: Integrate rugby FIT activity recording across the completed match flow.

- [X] T052 Add activity recording lifecycle tests for start, stop, save, unsupported, and fallback states in `tests/Test_RugbyActivityRecorder.mc`
- [X] T053 Implement `ActivityRecording.createSession()` start/stop/save integration in `source/RugbyActivityRecorder.mc`
- [X] T054 Wire match start and match end to activity recording lifecycle in `source/RugbyTimerApp.mc`
- [X] T055 Document target-device rugby/fallback validation expectations in `specs/001-rugby-referee-timer/quickstart.md`

**Checkpoint**: Match recording behavior is planned and validated without scattering FIT session ownership.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Validate constitution gates, regression-sensitive behavior, and documentation before implementation completion.

- [ ] T056 Run regression checks for timer, scoring, sanctions, variants, UI snapshot state, haptics, storage, and activity recording; record results in `specs/001-rugby-referee-timer/quickstart.md`
- [ ] T057 Validate synchronized timer rendering has no visible drift across main countdown, count-up active match timer, yellow cards, conversion timer, red indicators, and haptics; record results in `specs/001-rugby-referee-timer/quickstart.md`
- [ ] T058 Validate dark color-blind-friendly layout on representative small and large round Garmin watch screens; record results in `specs/001-rugby-referee-timer/quickstart.md`
- [ ] T059 Validate Connect IQ API 4.1.6 rugby activity recording or documented fallback/exclusion per target; record results in `specs/001-rugby-referee-timer/quickstart.md`
- [X] T060 Update `AGENTS.md` with any new implementation commands or final source layout adjustments discovered during implementation
- [X] T061 Refactor match screen structure into Connect IQ XML layouts and keep `RugbyTimerView` limited to state binding in `resources/layouts/layout.xml`, `source/RugbyLayoutSupport.mc`, and `source/RugbyTimerView.mc`
- [X] T062 Add scoring team/type dialog and conversion action screen behavior in `source/RugbyScoringMenus.mc`, `source/RugbyConversionView.mc`, `source/RugbyTimerDelegate.mc`, and `resources/layouts/layout.xml`, and XML menus under `resources/menus/`
- [X] T063 Restrict idle half-length +/- controls to the not-started screen and add XML-backed discipline/sanction menus for active match DOWN input in `source/RugbyTimerDelegate.mc`, `source/RugbyCardMenus.mc`, and `resources/menus/`
- [ ] T064 Ensure active-match card issuance pauses the match before creating yellow/red sanction state and renders yellow cards as `Y#  M:SS` under the affected team score in `source/RugbyGameModel.mc`, `source/RugbyTimerView.mc`, and related tests

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; must create project structure first.
- **Foundational (Phase 2)**: Depends on Setup; blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational; MVP scope.
- **User Story 2 (Phase 4)**: Depends on Foundational and can be developed after US1 for easiest UI integration.
- **User Story 3 (Phase 5)**: Depends on Foundational and can be developed after US1 for easiest UI integration.
- **User Story 4 (Phase 6)**: Depends on Foundational and should land after timer/scoring semantics are stable.
- **Activity Recording Integration (Phase 7)**: Depends on match lifecycle from US1 and target API decisions from Foundational.
- **Polish (Phase 8)**: Depends on all desired story phases.

### User Story Dependencies

- **User Story 1 (P1)**: Start after Foundational; no dependency on other stories.
- **User Story 2 (P2)**: Start after Foundational; integrates with US1 display state.
- **User Story 3 (P3)**: Start after Foundational; integrates with US1 display state.
- **User Story 4 (P4)**: Start after Foundational; affects timer durations used by US1, US2, and US3.

### Within Each User Story

- Tests/checks first, then model changes, then delegate/input wiring, then view rendering, then quickstart updates.
- Tasks touching `source/RugbyGameModel.mc` must run sequentially within a story.
- Tasks touching `source/RugbyTimerView.mc` must run sequentially after model snapshot fields exist.
- Quickstart documentation tasks should follow implementation tasks for the same story.

### Parallel Opportunities

- Setup resource tasks T004-T006 can run in parallel after T001.
- Foundational tests T007-T011 can run in parallel before implementation.
- Story-specific tests within each user story can run in parallel when they touch distinct test concerns.
- US2 and US3 may be implemented in parallel after US1 if changes to shared files are coordinated sequentially.

---

## Parallel Example: User Story 2

```text
# Launch US2 test tasks together:
Task: "T026 [P] [US2] Add scoring acceptance tests for try, conversion, penalty goal, drop goal, and correction actions in tests/Test_RugbyGameModel.mc"
Task: "T027 [P] [US2] Add conversion timer replacement and 60-second haptic threshold tests in tests/Test_RugbyGameModel.mc"

# Then implement sequentially because both model and view paths are shared:
Task: "T028 [US2] Implement score, scoring counter updates, and lightweight correction actions in source/RugbyGameModel.mc"
Task: "T029 [US2] Implement conversion timer start, replacement, expiry, and pause/resume derivation in source/RugbyGameModel.mc"
Task: "T030 [US2] Wire scoring, correction, and conversion actions in source/RugbyTimerDelegate.mc"
Task: "T031 [US2] Render fixed Home/Away labels, score, scoring counters, correction state, and conversion timer in source/RugbyTimerView.mc"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Stop and validate match clock start/pause/resume/end-half with synchronized display state.

### Incremental Delivery

1. Add US1 match clock MVP.
2. Add US2 scoring and conversion timer.
3. Add US3 sanctions and haptics.
4. Add US4 variant setup and overrides.
5. Add activity recording integration.
6. Run polish and regression validation.

### Notes

- [P] tasks = different files or separable checks with no dependency on incomplete tasks.
- [Story] label maps task to a specific user story for traceability.
- Each user story should be independently completable and testable.
- Mark each completed task as `[X]` in this file during implementation.
- Avoid broad refactors; preserve existing functioning behavior and isolate changes to the smallest practical file set.
