---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include tests or simulator checks when required by the feature specification or constitution, especially for timer synchronization and regression-sensitive behavior.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Garmin Connect IQ app**: `source/`, `resources/`, `manifest.xml`, `monkey.jungle`, and `tests/` where supported
- Paths shown below must be adjusted based on plan.md structure

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting tools
- [ ] T004 Document regression-sensitive existing behavior touched by this feature
- [ ] T004a Confirm behavior changes are captured in the active spec or create a new spec if this is a distinct feature

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T005 Setup Connect IQ project structure, manifest/device targets, or app resources needed by this feature
- [ ] T006 [P] Implement shared variant timing configuration or extend it without duplication
- [ ] T007 [P] Implement shared synchronized timebase plumbing required by the feature
- [ ] T008 Create or update base match state models/entities that all stories depend on
- [ ] T009 Configure haptic alert handling and device capability fallback paths
- [ ] T010 Configure Garmin simulator/device validation targets for representative watch sizes

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (OPTIONAL - only if tests requested) 

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**
> Include regression checks for existing functioning features affected by this story, especially shared timer, scoring, variant, rendering, storage, and activity-recording behavior.

- [ ] T011 [P] [US1] Monkey C unit test or simulator check for [timer/scoring behavior] in tests/[name].mc
- [ ] T012 [P] [US1] Regression check for affected existing behavior in tests/[name].mc

### Implementation for User Story 1

- [ ] T013 [P] [US1] Create [Entity1] model in source/[entity1].mc
- [ ] T014 [P] [US1] Create [Entity2] model in source/[entity2].mc
- [ ] T015 [US1] Implement [Service] in source/[service].mc (depends on T013, T014)
- [ ] T016 [US1] Implement [watch feature] in source/[file].mc
- [ ] T017 [US1] Add validation and error handling
- [ ] T018 [US1] Add haptic/activity/timer state handling needed for user story 1

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (OPTIONAL - only if tests requested)

- [ ] T019 [P] [US2] Monkey C unit test or simulator check for [behavior] in tests/[name].mc
- [ ] T020 [P] [US2] Regression check for affected existing behavior in tests/[name].mc

### Implementation for User Story 2

- [ ] T021 [P] [US2] Create [Entity] model in source/[entity].mc
- [ ] T022 [US2] Implement [Service] in source/[service].mc
- [ ] T023 [US2] Implement [watch feature] in source/[file].mc
- [ ] T024 [US2] Integrate with User Story 1 components (if needed)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (OPTIONAL - only if tests requested)

- [ ] T025 [P] [US3] Monkey C unit test or simulator check for [behavior] in tests/[name].mc
- [ ] T026 [P] [US3] Regression check for affected existing behavior in tests/[name].mc

### Implementation for User Story 3

- [ ] T027 [P] [US3] Create [Entity] model in source/[entity].mc
- [ ] T028 [US3] Implement [Service] in source/[service].mc
- [ ] T029 [US3] Implement [watch feature] in source/[file].mc

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX Run regression checks for all existing functioning timer, scoring, card, conversion, variant, UI, storage, and activity-recording behavior touched by the feature
- [ ] TXXX Validate synchronized timer rendering has no visible drift across main countdown, count-up/realtime, cards, conversion timer, and haptics
- [ ] TXXX Validate dark color-blind-friendly layout on representative small and large round Garmin watch screens
- [ ] TXXX Validate UI structure uses Connect IQ XML/resources where feasible and manual drawing is limited to justified dynamic visuals
- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional unit tests (if requested) in tests/unit/
- [ ] TXXX Garmin device compatibility and manifest/resource cleanup
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 -> P2 -> P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests/checks for User Story 1 together when required:
Task: "Monkey C unit test or simulator check for [timer/scoring behavior] in tests/[name].mc"
Task: "Regression check for affected existing behavior in tests/[name].mc"

# Launch all models for User Story 1 together:
Task: "Create [Entity1] model in source/[entity1].mc"
Task: "Create [Entity2] model in source/[entity2].mc"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational -> Foundation ready
2. Add User Story 1 -> Test independently -> Deploy/Demo (MVP!)
3. Add User Story 2 -> Test independently -> Deploy/Demo
4. Add User Story 3 -> Test independently -> Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence





