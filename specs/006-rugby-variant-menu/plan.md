# Implementation Plan: Rugby Variant Menu (006-rugby-variant-menu)

Technical Context
- Provide a pre-match variant selection UI (15s, 7s, 10s, U19). Must be resource-first, local-only, and guarded so changes cannot mutate a running match. Target Connect IQ SDK >= 4.1.6; representative devices: fenix 6 (large-round), Forerunner/vivoactive (small-round).

Constitution Check
- Follow VII (Declarative Resource-First UI): implement menu via resources/menus and strings. Follow IV (device compatibility): record device fallbacks if layout limits arise.

Phase 0 — Research (deliver: research.md)
- R0.1: Inventory existing variant presets and preference storage; identify last-selected-variant persistence support (specs/006).
- R0.2: Prototype variant menu layout on small/large round simulators; measure readability/truncation.
- R0.3: Confirm interactions with idle timer adjustments and document expected UX for resets and cancels.

Phase 1 — Design (deliver: data-model.md, quickstart.md, resources)
- D1.1: data-model.md: define RugbyVariant entity (id,label,halfLength,yellowDuration,conversionDuration,defaults).
- D1.2: quickstart.md: simulator steps to validate variant selection and pre-match behavior.
- D1.3: resources/menus/variant_menu.xml and strings entries; accessibility and font sizing for small screens.

Phase 2 — Implementation
- I2.1: Add menu resources and string IDs; wire MatchOptionDelegate to open variant menu.
- I2.2: Implement selection handler in RugbyTimerDelegate to apply variant defaults to Match Setup state (pre-match only).
- I2.3: Add guard tests to ensure selection is blocked when match state is running/paused/half-ended.
- I2.4: Add integration tests (tests/variant_selection_*), device validation entries in device-validation-report.md.

Outputs
- specs/006-rugby-variant-menu/research.md
- specs/006-rugby-variant-menu/data-model.md
- specs/006-rugby-variant-menu/quickstart.md
- resources/menus/variant_menu.xml, resources/strings/* updates

Notes
- Keep changes small and isolated (Constitution VI). If persistence of last-selected variant is later required, add as follow-on task with clear privacy note.
