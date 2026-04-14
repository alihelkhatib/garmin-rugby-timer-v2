# Tasks: Center Prompts for Round Screens

**Input**: Design documents from `/specs/008-centered-prompts/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: Include simulator checks because the feature specification requires round-screen readability validation and the change is regression-sensitive for existing prompt/dialog flows.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the current affected dialog routes and prepare the layout edits needed for the readability fix

- [ ] T001 Review the affected prompt/dialog launch paths in `source/RugbyTimerDelegate.mc`, `source/RugbyConversionView.mc`, `source/RugbyTeamSelectionDelegate.mc`, `source/RugbyTeamActionDelegate.mc`, `source/RugbyScoringMenus.mc`, `source/RugbyCardMenus.mc`, and `resources/menus/*.xml`
- [ ] T002 [P] Identify the resource layouts and screen-safe labels that need placement changes in `resources/layouts/layout.xml` and `resources/menus/*.xml`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define the shared placement behavior needed before any affected dialog can be updated

- [ ] T003 Add a reusable centered-placement layout path for affected prompts and dialogs in `resources/layouts/layout.xml`
- [ ] T004 [P] Update any shared prompt/dialog labels or resource anchors needed to keep centered content within round-screen bounds in `resources/menus/*.xml`
- [X] T005 [P] Add shared screen-shape or layout helper logic for placement decisions in `source/RugbyLayoutSupport.mc` (implemented - skeleton wired to PromptUtils)
- [ ] T006 Verify the affected prompt/dialog routes still use the existing menu flow after the shared placement support is added in `source/RugbyTimerDelegate.mc`

**Checkpoint**: Shared placement support is ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Keep Prompts Fully Visible On Round Screens (Priority: P1) MVP

**Goal**: Ensure the affected prompts and dialogs are fully visible on circular watch screens without clipping.

**Independent Test**: Open each affected prompt/dialog on a circular watch profile and confirm all text and controls are visible within the screen bounds.

### Tests for User Story 1

- [ ] T007 [P] [US1] Add or update simulator coverage for circular-screen prompt/dialog readability in `tests/Test_RugbyTimerView.mc`
- [ ] T008 [P] [US1] Add regression coverage that verifies the affected dialogs remain readable on square screens in `tests/Test_RugbyTimerView.mc`

### Implementation for User Story 1

- [ ] T009 [P] [US1] Center the conversion prompt content so it remains fully visible on circular screens in `source/RugbyConversionView.mc` and `resources/layouts/layout.xml`
- [ ] T010 [P] [US1] Center the score-team and card-team menu presentation where bottom placement risks clipping in `resources/menus/score_team.xml`, `resources/menus/card_team.xml`, `resources/menus/score_home.xml`, `resources/menus/score_away.xml`, `resources/menus/card_home.xml`, and `resources/menus/card_away.xml`
- [ ] T011 [P] [US1] Adjust the match options and match summary dialog placement if they can clip on round screens in `resources/menus/match_options.xml` and `resources/menus/match_summary.xml`
- [ ] T012 [US1] Update the view binding or menu launch code to use the new centered placement paths without changing the action flow in `source/RugbyTimerDelegate.mc`, `source/RugbyTeamSelectionDelegate.mc`, `source/RugbyTeamActionDelegate.mc`, `source/RugbyScoringMenus.mc`, and `source/RugbyCardMenus.mc`

**Checkpoint**: User Story 1 should now be fully functional and testable independently

---

## Phase 4: User Story 2 - Preserve Existing Dialog Flow (Priority: P2)

**Goal**: Keep the same prompt meanings, ordering, and return behavior while only improving placement.

**Independent Test**: Exercise each affected prompt/dialog and verify the same choices, ordering, and match-state behavior remain available after the placement adjustment.

### Implementation for User Story 2

- [ ] T013 [US2] Confirm the back/cancel behavior for affected prompts and dialogs still returns to the same prior screen state in `source/RugbyTimerDelegate.mc`, `source/RugbyConversionView.mc`, and related menu delegates
- [ ] T014 [US2] Verify the selection flow for score, card, variant, match options, and summary dialogs still routes to the same actions after the placement change in `source/RugbyTimerDelegate.mc`, `source/RugbyTeamSelectionDelegate.mc`, `source/RugbyTeamActionDelegate.mc`, `source/RugbyScoringMenus.mc`, and `source/RugbyCardMenus.mc`
- [ ] T015 [US2] Add any small copy or layout adjustments needed to keep centered prompts readable without changing behavior in `resources/layouts/layout.xml` and `resources/menus/*.xml`

**Checkpoint**: User Stories 1 and 2 should both work independently

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across representative screens and prompt/dialog flows

- [ ] T016 Validate affected prompts and dialogs on representative circular and square Garmin watch profiles using the scenarios in `specs/008-centered-prompts/quickstart.md`
- [ ] T017 [P] Run a regression sweep for existing timer, scoring, conversion, card, variant, and summary dialog flows touched by the placement change and record the result in `specs/008-centered-prompts/quickstart.md`
- [ ] T018 Confirm the final layout keeps the primary timer and score readable while affected prompts are visible in `source/RugbyTimerView.mc` and `resources/layouts/layout.xml`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependencies on later stories
- **User Story 2 (P2)**: Can start after Foundational - validates existing flow after placement changes

### Within Each User Story

- Tests should be written before or alongside implementation where included
- Shared placement support should be in place before per-dialog layout updates
- Preserve existing navigation and state transitions while adjusting placement

### Parallel Opportunities

- `T002`, `T004`, and `T005` can run in parallel after the affected routes are identified
- `T007` and `T008` can run in parallel because they cover different readability checks
- `T009`, `T010`, and `T011` can run in parallel because they touch different resource files
- `T016` and `T017` can run in parallel during final validation

---

## Parallel Example: User Story 1

```text
Task: "Add or update simulator coverage for circular-screen prompt/dialog readability in tests/Test_RugbyTimerView.mc"
Task: "Add regression coverage that verifies the affected dialogs remain readable on square screens in tests/Test_RugbyTimerView.mc"
Task: "Center the conversion prompt content so it remains fully visible on circular screens in source/RugbyConversionView.mc and resources/layouts/layout.xml"
Task: "Center the score-team and card-team menu presentation where bottom placement risks clipping in resources/menus/score_team.xml, resources/menus/card_team.xml, resources/menus/score_home.xml, resources/menus/score_away.xml, resources/menus/card_home.xml, and resources/menus/card_away.xml"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Stop and validate the round-screen readability fix

### Incremental Delivery

1. Complete Setup + Foundational
2. Deliver User Story 1 and verify no clipping on circular screens
3. Deliver User Story 2 to confirm the flow and state transitions remain unchanged
4. Finish with round/square profile validation and regression sweep

### Parallel Team Strategy

1. One developer prepares shared placement support
2. Another updates the affected menu/layout files
3. A third runs the round/square readability validations once the resource changes land

---

## Notes

- [P] tasks can run in parallel when they touch different files and have no dependency on incomplete work
- Keep the scope to prompt/dialog placement only
- Preserve existing action flow, match state, and button behavior while changing presentation
