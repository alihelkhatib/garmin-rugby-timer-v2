# Plan: Haptics enhancements and Match Summary show fix

Purpose

Implement referee-focused haptic alerts and fix Match Summary "select" action so the summary view opens reliably. Follow speckit plan phases: research, design, tasks, and test artifacts.

Scope

- Add model-driven haptic events for:
  - Two-minute remaining per half
  - One-minute remaining for yellow-card timers
  - Match/half start quick vibrate (already partly implemented)
- Ensure RugbyTimerDelegate.showMatchSummary reliably pushes RugbyMatchSummaryView; add diagnostics to detect failures and fix resource/layout issues if present.

Phase 0 — Research

- R0.1: Confirm existing haptic infra: RugbyHaptics.fireCoalesced and RugbyTimerView.handleHaptics.
- R0.2: Confirm snapshot lifecycle and where to inject dueHapticEvents() entries in RugbyGameModel.
- R0.3: Verify RugbyMatchSummaryView initialization path and resource layout ids.

Deliverable: specs/004-match-control-feedback/research-haptics-summary.md

Phase 1 — Design & Contracts

- D1.1: Data model: add HapticEvent entity { type: String, snapshotId: Number, payload: Dictionary }
- D1.2: Contract: RugbyGameModel.dueHapticEvents() returns Array<HapticEvent>
- D1.3: UI: RugbyTimerView.handleHaptics consumes haptic events and calls RugbyHaptics.fireCoalesced(snapshotId)

Deliverables: data-model.md excerpt, contracts/haptic-contract.md

Phase 2 — Tasks (ordered)

- T1: Add haptic event generation in RugbyGameModel.dueHapticEvents()
  - Detect mainCountdownSeconds <= 120 and mark event type `half_two_min` once per half
  - Detect sanction.remainingSeconds <= 60 and mark event type `card_one_min` once per sanction
  - Ensure duplicates are prevented per snapshotId
- T2: Emit diagnostic traces when haptic events are created (`haptic_warning_half` / `haptic_warning_card`) via System.println
- T3: Wire model events into existing view haptics handling (RugbyTimerView.handleHaptics already coalesces; ensure event types are recognized)
- T4: Ensure RugbyHaptics supports patterns for the new events (reuse fireCoalesced or add small wrappers that call Attention.vibrate with a short profile)
- T5: Add unit tests in Test_RugbyGameModel.mc for half two-minute and card one-minute haptic event creation and diagnostics
- T6: Add integration test in tests/integration/match_summary_open_test.mc to assert showMatchSummary push traces and RugbyMatchSummaryView.initialize traces
- T7: Add diagnostics in RugbyTimerDelegate.showMatchSummary (pre/post push), and in RugbyMatchSummaryView.initialize/onLayout
- T8: Run local simulator and fix any resource/layout validation errors reported; update resources/layouts/rugby_event_log.xml and match_summary_layout.xml if needed (follow Rez schema)
- T9: Update specs (spec.md and checklists) to include new haptic FRs (or include addendum file)

Phase 3 — Validation

- V1: Run unit tests: Test_RugbyGameModel mc tests
- V2: Run integration tests: match_summary_open_test.mc
- V3: Local build on representative device profile(s) (fenix6) to ensure no Rez or compiler errors

Artifacts produced

- specs/004-match-control-feedback/haptics-requirements.md (created)
- specs/009-match-summary-access/bugfix-showMatchSummary.md (created)
- specs/004-match-control-feedback/plan-haptics-summary.md (this file)
- tasks.md entries (below)

Tasks.md entries (for speckit-tasks)

- create-task: add-haptic-events-in-model — Add model-driven haptic events for half two-minute and card one-minute
- create-task: add-haptic-diagnostics — Emit `haptic_warning_half` and `haptic_warning_card` diagnostics
- create-task: wire-haptics-to-view — Ensure RugbyTimerView handles new events and RugbyHaptics vibrates
- create-task: add-haptic-tests — Unit tests for haptic event creation
- create-task: add-summary-diagnostics — Add pre/post push and view init traces
- create-task: add-summary-integration-test — Integration test asserting push and init traces exist
- create-task: fix-resource-layouts-if-needed — Fix Rez layout files for match summary / event log
- create-task: run-local-build-and-iterate — Run monkeyc locally and fix remaining issues

Notes & Constraints

- Local Connect IQ SDK required for builds and final validation; tests here rely on System.println traces and deterministic timers.
- Keep changes minimal and resource-first; avoid adding persistence.

Next steps

- Confirm plan acceptance, then run `/speckit-tasks` to produce tasks.md and create ticket entries. After that, implement with `/speckit-implement` or proceed manually.
