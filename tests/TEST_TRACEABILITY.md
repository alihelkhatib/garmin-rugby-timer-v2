# Test Traceability

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
- US2 Pause Awareness And Card Pause Behavior: `tests/Test_RugbyGameModel.mc` covers pause reminder snapshot state and card-triggered pause for yellow and red cards; `source/RugbyTimerDelegate.mc`, `source/RugbyTimerView.mc`, and `source/RugbyHaptics.mc` cover immediate pause haptics and recurring paused reminders.
- US3 Match Event Log: `tests/Test_RugbyGameModel.mc` covers scoring/card event log entries and reset/new-match clearing; `tests/Test_RugbyActivityRecorder.mc` covers best-effort activity export fallback state.
- US4 End Or Reset From Back: `tests/Test_RugbyIdleTimerControls.mc` covers Back option availability and reset confirmation clearing model state and discarding the recorder; `source/RugbyMatchSummaryView.mc` renders the current match event log after End match.

Validation status:

- Compile and unit-test compile passed for `fenix7` on 2026-04-13.
- Simulator execution is pending because `monkeydo` could not connect to the Connect IQ simulator in this environment.
