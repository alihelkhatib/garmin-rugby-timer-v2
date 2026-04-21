# Test Traceability

## 001-rugby-referee-timer

- US1 Match Exit And Start Confirmation: `source/RugbyTimerDelegate.mc`, `source/RugbyTimerView.mc`, `source/RugbyHaptics.mc`, `tests/match_summary_endflow_test.mc`, and `tests/match_summary_regression_test.mc` cover the pre-match and terminal exit path plus the match-start vibration wiring.
- US2 Conversion Overlay Countdown: `source/RugbyConversionView.mc` and `tests/Test_RugbyGameModel.mc` cover the conversion overlay countdown remaining visible at the top while the match clock is paused; `tests/test_eventlog.mc` keeps event logging smoke coverage in place for scoring flow regressions.
- US3 Discipline Timing And Half Warnings: `source/RugbyGameModel.mc`, `source/RugbyTimerView.mc`, and `source/RugbyHaptics.mc` cover yellow/red sanction visibility, pause reminders, and the one-time 2-minute half-warning alert; `tests/Test_RugbyGameModel.mc` covers the haptic event emission behavior.
- US6 Rugby Activity Recording, Distance, And Speed: `source/RugbyActivityRecorder.mc` and `tests/Test_RugbyActivityRecorder.mc` cover rugby-equivalent labeling, motion-data capture, and non-blocking save fallback; `tests/impl_activity_export.mc` and `tests/impl_export_error_handling.mc` add recorder smoke coverage.

Validation status:

- `git diff --check` is clean after CRLF normalization.
- Signed Connect IQ compile and simulator validation remain pending in this workspace because the SDK CLI could not complete without a signing private key.

## 003-idle-timer-controls

- US1 Adjust Main Timer Before Kickoff: `tests/Test_RugbyIdleTimerControls.mc`, `tests/Test_RugbyGameModel.mc`, and `tests/Test_RugbyVariantConfig.mc` cover idle Up/Menu increment, idle Down decrement, raw physical Up/Menu/Down/Select-Start key routing, 00:00 lower bound, selected variant normal-half upper bound, and match start from the adjusted idle value.
- US2 Block Score Menu While Idle: `tests/Test_RugbyIdleTimerControls.mc` covers not-started score/card menu blocking and match-ended score-dialog blocking.
- US3 Preserve In-Match Score Controls: `tests/Test_RugbyIdleTimerControls.mc` covers running, paused, and half-ended score/card dialog availability; `tests/Test_RugbyGameModel.mc` covers try, conversion, penalty goal, and drop goal scoring after an idle timer adjustment.
- US4 Keep Idle Screen Readable and Match-Ready: `source/RugbyTimerView.mc` removes raw lifecycle status display from the idle screen, and `resources/layouts/layout.xml` recenters the resource-backed countdown label. Simulator or physical-device screenshot validation remains required for final visual acceptance.

Validation status:

- Compile and unit-test compile passed for `fenix7` on 2026-04-13, including the raw physical-key and idle-display regression fix.
- Simulator execution is pending because `monkeydo` could not connect to the Connect IQ simulator in this environment.

## 005-match-event-management

- US1 Automatic Conversion After Try: `tests/Test_RugbyGameModel.mc` covers paused try conversion countdowns driven by wall-clock time and non-try scores not starting a conversion; `source/RugbyConversionView.mc` owns a one-second overlay refresh timer for visible countdown updates while the main match is paused.
- US2 Pause Awareness And Card Pause Behavior: `tests/Test_RugbyGameModel.mc` covers pause reminder snapshot state, card-triggered pause for yellow and red cards, same-team multiple-yellow timers, and separate red-card marker state; `source/RugbyTimerDelegate.mc`, `source/RugbyTimerView.mc`, and `source/RugbyHaptics.mc` cover immediate pause haptics, recurring paused reminders, plain yellow timer text, multiple yellow timers, and compact red-card markers.
- US3 Match Event Log: `tests/Test_RugbyGameModel.mc` covers scoring/card event log entries and reset/new-match clearing; `tests/Test_RugbyActivityRecorder.mc` covers best-effort activity export fallback state.
- US4 End Or Reset From Back: `tests/Test_RugbyIdleTimerControls.mc` covers Back option availability and reset confirmation clearing model state and discarding the recorder; `source/RugbyMatchSummaryView.mc` renders the current match event log after End match.

Validation status:

- Compile and unit-test compile passed for `fenix7` on 2026-04-13.
- Simulator execution is pending because `monkeydo` could not connect to the Connect IQ simulator in this environment.

## 006-rugby-variant-menu

- US1 Select Variant Before Match: `tests/Test_RugbyIdleTimerControls.mc` covers pre-match variant menu availability and applying built-in 7s defaults from the delegate/model path.
- US2 Prevent Mid-Match Variant Changes: `tests/Test_RugbyIdleTimerControls.mc` covers running, paused, and match-ended variant-menu blocking plus set-variant ignored after match start.
- US3 Preserve Variant Choice During Pre-Match Adjustments: `tests/Test_RugbyIdleTimerControls.mc` covers selecting a built-in variant after an idle timer adjustment and resetting to the selected variant defaults.

Validation status:

- Compile and unit-test compile passed for `fenix7` on 2026-04-13.

## 007-auto-period-transition

- US1 Auto-End Non-Final Period: `tests/Test_RugbyGameModel.mc` covers running non-final countdown expiry, manual end-half regression, and the half-time timer count-up during the between-period state; `source/RugbyGameModel.mc` performs the automatic transition through the existing half-ended state and derives `halfTimeSeconds`, while `source/RugbyTimerView.mc` binds that value as the visible `HT` timer.
- US2 Auto-End Final Period And Match: `tests/Test_RugbyGameModel.mc` covers final-period countdown expiry, summary state preservation, one-shot auto-save flag consumption, and manual end-match regression; `source/RugbyGameModel.mc` reuses the existing match-ended state and timer shutdown path, and `source/RugbyTimerView.mc` consumes automatic final expiry once to call the existing recorder save and match summary view path.
- US3 Carry Active Card Timers Into Next Period: `tests/Test_RugbyGameModel.mc` covers single and multiple yellow-card carry-forward, yellow-card pause during half-time timer count-up, simultaneous yellow expiry at a period boundary, paused-at-00:00 behavior, and red-card/conversion timer non-regression; `source/RugbyGameModel.mc` preserves unexpired yellow-card remaining time before period elapsed resets.

Validation status:

- Compile and unit-test compile passed for `fenix7` on 2026-04-13.
- Simulator test artifact ran with `monkeydo build\garmin-rugby-timer-fenix7-test.prg fenix7 /t`; interactive quickstart validation remains pending for a manual simulator/device session.
- Half-time timer correction compile, unit-test compile, and simulator test artifact passed for `fenix7` on 2026-04-14.

## 010-referee-field-controls

- US1 Undo Last Event: `source/RugbyGameModel.mc`, `source/RugbyTimerDelegate.mc`, `resources/menus/match_options.xml`, `resources/strings/strings.xml`, and `tests/Test_RugbyGameModel.mc` cover latest-only score/card undo, confirmation cancel/no-op behavior, conversion rollback edge cases, and summary event removal.
- US2 Referee-Confirmed Time Expiry: `source/RugbyGameModel.mc`, `source/RugbyTimerView.mc`, `source/RugbyHaptics.mc`, and `tests/Test_RugbyGameModel.mc` cover time-up overtime state, one-time haptic event emission, Back-button confirmation, Select/Start pause/resume preservation, and card/conversion behavior around regulation expiry.
- US3 Scrollable Recent-First Match Summary: `source/RugbyMatchSummaryView.mc`, `source/RugbyTimerDelegate.mc`, `tests/match_summary_regression_test.mc`, `tests/match_summary_endflow_test.mc`, and `tests/match_summary_empty_state_test.mc` cover newest-first summary ordering, summary access from match states, empty state, and state-preserving summary exit.

Validation status:

- `monkeyc -f monkey.jungle -d fenix7 -o build\garmin-rugby-timer-fenix7-test.prg -t -y build\codex-garmin-rugby-timer-key.der -w`: PASS on 2026-04-21.
- `monkeydo build\garmin-rugby-timer-fenix7-test.prg fenix7 /t`: BLOCKED, unable to connect to simulator.
