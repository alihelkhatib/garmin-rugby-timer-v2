# Tasks: Codebase Rehabilitation

**Input**: Design documents from `/specs/011-codebase-rehabilitation/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Tests are required by the specification and constitution. Write or repair the focused test before the associated behavior change where practical.

## Phase 1: Setup and Baseline

**Purpose**: Preserve evidence, restore build observability, and remove only proven build blockers.

- [x] T001 Record baseline build commands, failures, repository history findings, and initial architecture risks in `CLEANUP_NOTES.md`
- [x] T002 Remove or replace the unused invalid summary resource in `resources/layouts/match_summary_layout.xml` and normalize duplicate permissions in `manifest.xml`
- [x] T003 Re-run warning-enabled application builds for `fenix6`, `fenix7`, and `instinct2` using `monkey.jungle` and record all newly exposed failures in `CLEANUP_NOTES.md`
- [x] T004 Create an explicit unit-test build configuration in `tests/monkey.jungle` without adding tests to the production source path
- [x] T005 [P] Add reproducible local validation commands in `scripts/validate.ps1` and keep keys/output outside version control via `.gitignore`

---

## Phase 2: Foundational Architecture

**Purpose**: Establish shared timing, state, persistence, and orchestration seams that block all user stories.

- [x] T006 Add deterministic elapsed-time and clock-format helpers with wrap/backward guards in `source/RugbyTime.mc`
- [x] T007 Refactor authoritative state advancement and pure render snapshots in `source/RugbyGameModel.mc`
- [x] T008 Add versioned serialization, validation, and paused recovery restoration in `source/RugbyGameModel.mc`
- [x] T009 Implement variant preference and active-match recovery storage in `source/RugbyPersistence.mc` and `source/RugbyVariantConfig.mc`
- [x] T010 Implement one-shot model/recorder/persistence orchestration in `source/RugbyMatchController.mc`
- [x] T011 Make activity start/save/discard/retry terminal behavior idempotent in `source/RugbyActivityRecorder.mc`
- [x] T012 Update app initialization, stop handling, and dependency wiring in `source/RugbyTimerApp.mc`
- [x] T013 Build `fenix6`, `fenix7`, and `instinct2` after foundational changes and resolve all compiler errors in `source/`, `resources/`, `manifest.xml`, and `monkey.jungle`

**Checkpoint**: The application builds and exposes a deterministic controller/model API before story work continues.

---

## Phase 3: User Story 1 — Referee Runs a Reliable Match (Priority: P1) MVP

**Goal**: A complete start/pause/resume/period/match/reset flow remains accurate under delayed callbacks and interruption.

**Independent Test**: Controlled timestamps drive two periods, pauses, a delayed boundary tick, invalid transitions, reset, and paused recovery with all snapshots matching expected durations.

### Tests for User Story 1

- [x] T014 [US1] Replace timing/state placeholders with deterministic transition, delayed-callback, zero/boundary, invalid-transition, and reset tests in `tests/Test_RugbyGameModel.mc`
- [x] T015 [P] [US1] Add wrap/backward-delta and formatting tests in `tests/Test_RugbyTime.mc`
- [x] T016 [P] [US1] Add valid, malformed, incompatible, and running-to-paused recovery tests in `tests/Test_RugbyPersistence.mc`
- [x] T017 [US1] Add one-shot automatic period/match completion and recorder-call tests in `tests/Test_RugbyMatchController.mc`

### Implementation for User Story 1

- [x] T018 [US1] Route start, pause, resume, confirmation, reset, and periodic ticks through `RugbyMatchController` in `source/RugbyTimerDelegate.mc`
- [x] T019 [US1] Make main refresh and pause-reminder timers visibility-safe in `source/RugbyTimerView.mc`
- [x] T020 [US1] Restore interrupted active matches visibly paused and clear recovery on reset in `source/RugbyTimerApp.mc`, `source/RugbyMatchController.mc`, and `source/RugbyTimerView.mc`
- [x] T021 [US1] Run the User Story 1 unit-test target and full-match delayed-tick smoke flow defined in `specs/011-codebase-rehabilitation/quickstart.md`

---

## Phase 4: User Story 2 — Referee Records Match Events Safely (Priority: P1)

**Goal**: Scoring, corrections, conversions, and cards are validated, one-shot, synchronized, and reflected consistently in the summary.

**Independent Test**: Each event is recorded in allowed/disallowed states, rapid duplicates are checked, conversions and multiple yellow cards cross pauses/periods, and corrections reconcile score plus history.

### Tests for User Story 2

- [x] T022 [US2] Add allowed-state, invalid-team/type, correction-history, duplicate-event, and event-boundary tests in `tests/Test_RugbyGameModel.mc`
- [x] T023 [P] [US2] Add wall-time conversion and active-time sanction tests across pause, delayed tick, and period boundaries in `tests/Test_RugbyGameModel.mc`
- [x] T024 [P] [US2] Add idempotent recorder start/save/discard and retry-cancellation tests in `tests/Test_RugbyActivityRecorder.mc`

### Implementation for User Story 2

- [x] T025 [US2] Validate event operations by team/type/state and make score corrections reconcile event status in `source/RugbyGameModel.mc`
- [x] T026 [US2] Route scoring, conversion, and card actions through the controller in `source/RugbyTimerDelegate.mc`, `source/RugbyTeamActionDelegate.mc`, and `source/RugbyConversionView.mc`
- [x] T027 [US2] Preserve explicit wall-time conversion and active-time yellow-card behavior in `source/RugbyGameModel.mc`
- [x] T028 [US2] Keep activity export failure non-blocking and summary data available in `source/RugbyActivityRecorder.mc` and `source/RugbyMatchController.mc`
- [x] T029 [US2] Run User Story 2 tests and the score/card/conversion smoke flow from `specs/011-codebase-rehabilitation/quickstart.md`

---

## Phase 5: User Story 3 — Referee Uses a Clear Watch Interface (Priority: P2)

**Goal**: Inputs are predictable and the main, conversion, prompt, menu, and summary screens are readable across supported shapes.

**Independent Test**: Each hardware action produces one operation, destructive actions name their confirmation, and compact round/large round/rectangular profiles render required information without clipping.

### Tests for User Story 3

- [x] T030 [US3] Replace delegate placeholder coverage with one-action-per-input and state-gating tests in `tests/Test_RugbyIdleTimerControls.mc`
- [x] T031 [P] [US3] Add layout-family coverage in `tests/Test_RugbyLayoutSupport.mc` and validate visible-state bindings in the simulator
- [x] T032 [P] [US3] Cover empty, bounded, and corrected event-summary behavior through model tests and simulator validation

### Implementation for User Story 3

- [x] T033 [US3] Remove overlapping input routes and centralize menu action IDs in `source/RugbyTimerDelegate.mc`, `source/RugbyTeamSelectionDelegate.mc`, and `source/RugbyTeamActionDelegate.mc`
- [x] T034 [P] [US3] Move remaining static UI text and prompt labels into `resources/strings/strings.xml` and valid layouts in `resources/layouts/layout.xml`
- [x] T035 [US3] Bind explicit confirmation/status text and non-color-only card indicators in `source/RugbyTimerView.mc`
- [x] T036 [US3] Make conversion view lifecycle and countdown rendering controller-driven in `source/RugbyConversionView.mc`
- [x] T037 [US3] Implement a bounded readable event summary using valid resources plus justified dynamic rows in `source/RugbyMatchSummaryView.mc` and `resources/layouts/layout.xml`
- [x] T038 [US3] Validate simulator layouts and navigation on compact round, large round, and rectangular profiles and record evidence in `CLEANUP_NOTES.md`

---

## Phase 6: User Story 4 — Developer Maintains and Validates the App (Priority: P2)

**Goal**: The repository is small, understandable, reproducibly buildable/testable, and accurately documented.

**Independent Test**: A clean-checkout walkthrough builds representative targets, runs executable tests, maps each responsibility to one owner, and finds no unexplained prototypes/placeholders/debug hacks.

### Tests and Validation for User Story 4

- [x] T039 [US4] Compile and run every executable unit test through `tests/monkey.jungle`, removing or replacing non-executable stubs in `tests/`
- [x] T040 [P] [US4] Add repository checks for generated artifacts, signing keys, placeholder tests, unconditional debug logging, and invalid XML to `scripts/validate.ps1`

### Implementation for User Story 4

- [x] T041 [US4] Remove confirmed prototypes and duplicate implementations from `source/BackButtonSummaryPrototype.mc`, `source/RugbyEventLog.mc`, `source/RugbySummaryView.mc`, and superseded test stubs in `tests/`
- [x] T042 [US4] Remove unconditional debug logging, swallowed exceptions, stale headers, and commented-out code throughout `source/`
- [x] T043 [US4] Reconcile manifest product IDs, minimum API, permissions, and launcher assets in `manifest.xml` and `resources/drawables/`
- [x] T044 [P] [US4] Rewrite architecture, state/timing, controls, build/test, device support, privacy, and limitations in `README.md` and `docs/DEVELOPER.md`
- [x] T045 [P] [US4] Update test inventory and traceability to actual executable coverage in `docs/testing.md`, `docs/test-summaries.md`, and `tests/TEST_TRACEABILITY.md`
- [x] T046 [P] [US4] Document release/rollback, incident reporting, dependency inventory, app-store checks, and contributor expectations in `docs/RELEASING.md` and `docs/CONTRIBUTING.md`
- [x] T047 [US4] Run the documented clean-checkout workflow and correct any command or architecture documentation drift in `README.md`, `docs/`, and `scripts/validate.ps1`

---

## Phase 7: Final Audit and Release Evidence

**Purpose**: Prove the rehabilitation is complete and catch regressions introduced during cleanup.

- [x] T048 Run warning/type-check/build-stat builds for `fenix6`, `fenix7`, and `instinct2` using `scripts/validate.ps1` and record results in `CLEANUP_NOTES.md`
- [x] T049 Run the complete unit-test suite and required full-match simulator smoke flow, recording pass/fail and device-only gaps in `CLEANUP_NOTES.md`
- [x] T050 Review `git diff` and `git diff --check` for accidental behavior changes, secrets, generated files, malformed resources, and documentation mismatch
- [x] T051 Perform a second repository audit against FR-001 through FR-021 and SC-001 through SC-009, fixing every remaining serious issue in the affected files
- [x] T052 Update `CLEANUP_NOTES.md` with final problems, root causes, decisions, removals, tests, build results, limitations, and recommended next steps
- [x] T053 Add explicit idle/completed and active-match exit routes with recovery-safe behavior in `source/RugbyTimerDelegate.mc` and `resources/menus/match_options.xml`
- [x] T054 Expose manual period completion and latest-event correction through match options and cover model behavior in `tests/Test_RugbyGameModel.mc`
- [x] T055 Exercise the complete button/menu/navigation flow in the simulator and record verified and device-only gaps in `CLEANUP_NOTES.md`
- [x] T056 Add GPS acquisition and Garmin elapsed-distance tracking to `source/RugbyActivityRecorder.mc`, lifecycle wiring to `source/RugbyTimerApp.mc`, and the Positioning permission to `manifest.xml`
- [x] T057 Keep GPS and mileage in the saved FIT activity rather than the match UI, while retaining compact monochrome-safe rendering in `source/RugbyTimerView.mc`, `source/RugbyMatchSummaryView.mc`, and `source/RugbyConversionView.mc`
- [x] T058 Preserve cumulative mileage across recovery segments and test recorder, recovery, exit, undo, and navigation state behavior in `tests/`
- [x] T059 Re-run the full build/test/simulator matrix and document GPS/FIT physical-device validation requirements in `CLEANUP_NOTES.md` and `docs/testing.md`
- [x] T060 Add and validate a confirmed terminal Stop & exit action that saves the FIT activity, clears recovery, and closes the application in `source/RugbyGameModel.mc`, `source/RugbyTimerDelegate.mc`, and `resources/menus/match_options.xml`
- [x] T061 [US2] Add executable tests for heart-rate lifecycle state, readable FIT event mapping, one-time event/correction export, and restored-event priming in `tests/Test_RugbyActivityRecorder.mc` and `tests/Test_RugbyMatchController.mc`
- [x] T062 [US2] Enable Garmin heart-rate capture and best-effort rugby event lap/developer-field export in `source/RugbyActivityRecorder.mc`, `source/RugbyMatchController.mc`, `source/RugbyTimerApp.mc`, `resources/fitfields.xml`, `resources/strings/strings.xml`, and `manifest.xml`
- [x] T063 [US4] Re-run the complete test/build matrix and document Garmin Connect developer-field limitations plus physical-device heart-rate/event verification in `README.md`, `docs/testing.md`, and `CLEANUP_NOTES.md`
- [x] T064 [US2] Add regression tests for runtime-compatible FIT sport selection and compact pre-match GPS readiness text in `tests/Test_RugbyActivityRecorder.mc` and `tests/Test_RugbyGameModel.mc`
- [x] T065 [US2] Select runtime-supported sport metadata and expose pre-match GPS readiness without mileage in `source/RugbyActivityRecorder.mc`, `source/RugbyTimerView.mc`, and `resources/strings/strings.xml`
- [x] T066 [US4] Inspect the physical Fēnix 6 FIT output, rerun the build/test matrix, document the Garmin Connect map prerequisites, rebuild, and redeploy the corrected watch binary
- [x] T067 [US2] Add regression tests for legacy supported-sport fallback and one-shot yellow-card warning/expiration events and patterns in `tests/Test_RugbyActivityRecorder.mc` and `tests/Test_RugbyGameModel.mc`
- [x] T068 [US2] Use soccer/match compatibility metadata on pre-4.1.6 runtimes and implement distinct yellow-card warning/expiration vibrations in `source/RugbyActivityRecorder.mc`, `source/RugbyGameModel.mc`, `source/RugbyHaptics.mc`, and `source/RugbyTimerView.mc`
- [ ] T069 [US4] Compare decoded Rugby Timer and FC Timer FIT structure, validate physical save/sync/GPS behavior, rebuild all targets, and redeploy the compatibility build
- [x] T070 [US1] Add regression tests for exactly one paused-to-running haptic and ended-match timer reset with retained score/event summary in `tests/Test_RugbyIdleTimerControls.mc` and `tests/Test_RugbyGameModel.mc`
- [x] T071 [US1] Implement a single resume haptic and reset all timer projections on manual or automatic match end without clearing final match data in `source/RugbyTimerDelegate.mc`, `source/RugbyHaptics.mc`, and `source/RugbyGameModel.mc`
- [x] T072 [US4] Re-run the complete build/test matrix, document the behavior, commit and push, then redeploy the verified Fēnix 6 binary

---

## Dependencies & Execution Order

- Phase 1 is sequential because each build exposes the next defect.
- Phase 2 depends on Phase 1 and blocks all user stories.
- User Story 1 establishes the runtime control path and precedes controller integration in User Story 2.
- User Story 2 can begin its model tests after Phase 2, but UI integration depends on User Story 1 controller routing.
- User Story 3 depends on stable snapshots and controller actions from User Stories 1 and 2.
- User Story 4 cleanup waits until production replacements are verified; documentation tasks marked `[P]` can run after architecture stabilizes.
- Final audit depends on all desired stories.

## Parallel Opportunities

- T005 can proceed while T004 is prepared.
- T015 and T016 can run in parallel after foundational APIs settle.
- T023 and T024 cover independent model and recorder files.
- T031 and T032 cover independent layout and summary concerns.
- T034 can proceed alongside input consolidation once snapshot fields are stable.
- T040, T044, T045, and T046 affect distinct files after behavior stabilizes.

## Implementation Strategy

1. Restore a compiling baseline and explicit test target.
2. Complete the foundational model/controller/persistence seam.
3. Deliver User Story 1 as the minimum reliable timer MVP and validate it before event/UI work.
4. Add event integrity, then UI/input reliability, then developer cleanup.
5. Finish only after full builds/tests, diff review, and the second audit.

## Format Validation

All 69 tasks use the required checkbox, sequential ID, optional parallel marker, story label where applicable, concrete action, and exact file path or named build artifact.

