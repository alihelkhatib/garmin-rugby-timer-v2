# Tasks: Rugby Variant Menu

## Phase 1 - Setup

- [ ] T001 [P] Create `specs/006-rugby-variant-menu/research.md` documenting existing variant presets, persistence options, and UI constraints on target devices
- [ ] T002 [P] Create `specs/006-rugby-variant-menu/data-model.md` documenting RugbyVariant entity: id, label, halfLengthSeconds, yellowDurationSeconds, conversionDurationSeconds
- [ ] T003 [P] Create `specs/006-rugby-variant-menu/quickstart.md` with simulator steps to validate variant selection on fenix 6 and Forerunner/vivoactive profiles

## Phase 2 - Foundational Implementation (blocking)

- [ ] T004 Implement resource menu `resources/menus/variant_menu.xml` with menu-item ids: `variant_fifteens`, `variant_sevens`, `variant_tens`, `variant_u19` and corresponding labels in `resources/strings/strings.xml`
- [ ] T005 [P] Add optional resource-first layout `resources/layouts/variant_selection_layout.xml` if a custom layout is required for small screens (fallback to menu2 if not needed)
- [ ] T006 Add tests `tests/variant_menu_render_test.mc` to preview menu rendering and assert labels appear without truncation on representative profiles

## Phase 3 - User Stories (Priority order)

### User Story 1 - Select Variant Before Match (P1)

- [ ] T007 [US1] Wire `MatchOptionDelegate`/`MatchOptionDelegate.onSelect` to push `Rez.Menus.VariantMenu()` or `resources/menus/variant_menu.xml` — edit `source/RugbyTimerDelegate.mc` and `source/MatchOptionDelegate` (if present)
- [ ] T008 [US1] Implement selection handler that applies selected variant defaults to match setup state (edit `source/RugbyTimerDelegate.mc` and `source/RugbyGameModel.mc`) and add integration test `tests/variant_selection_test.mc` verifying half length and defaults are applied

### User Story 2 - Prevent Mid-Match Variant Changes (P2)

- [ ] T009 [US2] Add guard in variant selection code to block changing variants when match is running/paused/half-ended — edit `source/RugbyTimerDelegate.mc` and add `tests/variant_selection_guard_test.mc`
- [ ] T010 [US2] Add diagnostic traces for blocked selection attempts (instrumentation in `source/Diagnostics.mc` or using existing logging) and verify with `tests/variant_selection_guard_test.mc`

### User Story 3 - Preserve Variant Choice During Pre-Match Adjustments (P3)

- [ ] T011 [US3] Ensure selecting a variant resets any pre-match idle timer adjustments and applies the variant defaults — edit `source/RugbyGameModel.mc` (applyVariant/restoreDefaults function)
- [ ] T012 [US3] Add test `tests/variant_preserve_adjustments_test.mc` that selects a variant, adjusts idle timer, and verifies correct applied value at match start

## Final Phase - Polish & Cross-cutting

- [ ] T013 Update docs: finalize `specs/006-rugby-variant-menu/research.md`, `specs/006-rugby-variant-menu/data-model.md`, and `specs/006-rugby-variant-menu/quickstart.md`
- [ ] T014 Produce device validation report `specs/006-rugby-variant-menu/device-validation-report.md` showing rendering and behavior across fenix 6 and Forerunner/vivoactive profiles
- [ ] T015 Add release notes and small UX copy changes in `resources/strings/strings.xml` and `docs/` as appropriate

## Dependencies

- Phase 1 tasks (T001-T003) must complete before resource work (T004-T006).
- Variant wiring (T007-T008) depends on resources (T004) and data-model (T002).

## Parallel opportunities

- T001, T002, T003 can run in parallel ([P]).
- Menu resource authoring (T004) and layout preview tests (T006) can be parallelized where possible.

## Notes

- Keep changes isolated to pre-match flows to satisfy Constitution VI (Regression Isolation). If persistence of last-selected variant is later required, create a follow-on task with privacy considerations.
