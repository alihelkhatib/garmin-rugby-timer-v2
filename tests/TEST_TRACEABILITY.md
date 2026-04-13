# Test Traceability

## 003-idle-timer-controls

- US1 Adjust Main Timer Before Kickoff: `tests/Test_RugbyIdleTimerControls.mc`, `tests/Test_RugbyGameModel.mc`, and `tests/Test_RugbyVariantConfig.mc` cover idle Up/Menu increment, idle Down decrement, 00:00 lower bound, selected variant normal-half upper bound, and match start from the adjusted idle value.
- US2 Block Score Menu While Idle: `tests/Test_RugbyIdleTimerControls.mc` covers not-started score/card menu blocking and match-ended score-dialog blocking.
- US3 Preserve In-Match Score Controls: `tests/Test_RugbyIdleTimerControls.mc` covers running, paused, and half-ended score/card dialog availability; `tests/Test_RugbyGameModel.mc` covers try, conversion, penalty goal, and drop goal scoring after an idle timer adjustment.

Validation status:

- Compile and unit-test compile passed for `fenix7` on 2026-04-13.
- Simulator execution is pending because `monkeydo` could not connect to the Connect IQ simulator in this environment.
