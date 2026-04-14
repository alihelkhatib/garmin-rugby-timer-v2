# Implementation Plan: Match Control Feedback (004-match-control-feedback)

Technical Context
- Fix live timer updates, start haptic confirmation, yellow-card display labels, correct menu routing between score/card flows, and add targeted diagnostics. Target Connect IQ SDK >= 4.1.6; validate on fenix 6 (large-round) and Forerunner/vivoactive (small-round).

Constitution Check
- Adhere to II (Single Synchronized Timebase): ensure UI timers derive from a single monotonic source. Adhere to VI (Regression Isolation): keep fixes limited and add regression tests.

Phase 0 — Research (deliver: research.md)
- R0.1: Reproduce reported failures on simulator profiles and capture logs for start/pause/timer update paths.
- R0.2: Inspect RugbyGameModel timer scheduling; identify whether timers use System.getTimer vs. ad-hoc loops.
- R0.3: Verify haptic API availability and behavior per device profile.

Phase 1 — Design (deliver: diagnostic spec, quickstart)
- D1.1: Define diagnostic trace format (timestamp, action, priorState, result, metadata) and add to spec.
- D1.2: Design minimal changes to timer scheduling to ensure continuous visible updates while match is running (use single tick source and requestUpdate frequency guidance).
- D1.3: Design UI fix for yellow-card label rendering (include identifier string binding rather than manual substring).

Phase 2 — Implementation
- I2.1: Implement diagnostic tracing hooks across input handlers and state transitions; add tests that assert trace entries produced for each primary flow.
- I2.2: Fix start behavior: ensure start path triggers _model.startMatch, recorder start, haptic fire (if available), and schedules UI updates immediately.
- I2.3: Update timer rendering to rely on synchronized timebase and remove any stale pause-only refresh assumptions.
- I2.4: Fix menu routing code so score-team -> score-type and card-team -> card-type sequences are correct; add regression tests.
- I2.5: Fix yellow-card label formatting and add unit tests for render text.

Outputs
- specs/004-match-control-feedback/research.md
- specs/004-match-control-feedback/diagnostics.md
- tests/* integration and unit tests for start/pausing, routing, and render

Notes
- Prioritize simple, testable changes and validate on device simulators to avoid regressions. If a timer scheduling refactor is needed, keep it behind a small, easily-reversible commit with regression tests.
