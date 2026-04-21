# Test Results

## 2026-04-18 Rugby Referee Timer

- Added smoke coverage in `tests/test_eventlog.mc`, `tests/match_summary_empty_state_test.mc`, `tests/match_summary_endflow_test.mc`, `tests/match_summary_regression_test.mc`, `tests/impl_activity_export.mc`, and `tests/impl_export_error_handling.mc`.
- Normalized the modified test and source files to CRLF and confirmed `git diff --check` is clean.
- Full Monkey C compile and simulator validation still need a signed SDK run in this workspace; the local CLI would not complete without a signing private key.

Coverage added:

- Event-log snapshot and serialization smoke coverage in `tests/test_eventlog.mc`.
- Empty-state summary helper coverage in `tests/match_summary_empty_state_test.mc`.
- Summary entry-point wiring coverage in `tests/match_summary_endflow_test.mc` and `tests/match_summary_regression_test.mc`.
- Rugby recorder state and export-failure smoke coverage in `tests/impl_activity_export.mc` and `tests/impl_export_error_handling.mc`.

## 2026-04-13 Idle Timer Controls

- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7.prg -y /tmp/codex-garmin-rugby-timer-key.der -w`: PASS with existing warnings for invalid manifest device ids only.
- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7-test.prg -t -y /tmp/codex-garmin-rugby-timer-key.der -w`: PASS with existing warnings for invalid manifest device ids only.
- `monkeydo build/garmin-rugby-timer-fenix7-test.prg fenix7 -t`: BLOCKED, unable to connect to simulator.
- Regression compiles after the raw physical-key and idle-display fix: PASS for both app and unit-test builds with existing warnings for invalid manifest device ids only.

Coverage added:

- Idle timer lower and upper bounds in `tests/Test_RugbyGameModel.mc`.
- Match start from an adjusted idle timer in `tests/Test_RugbyGameModel.mc`.
- Score action regression after idle timer adjustment in `tests/Test_RugbyGameModel.mc`.
- Variant normal-half bounds in `tests/Test_RugbyVariantConfig.mc`.
- Idle Up/Menu, idle Down, match-ended block, active score dialog, and active card dialog state gates in `tests/Test_RugbyIdleTimerControls.mc`.
- Raw physical Up/Menu, Down, and Select/Start key routing in `tests/Test_RugbyIdleTimerControls.mc`.

## 2026-04-13 Match Event Management

- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7.prg -y /tmp/codex-garmin-rugby-timer-key.der -w`: PASS.
- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7-test.prg -t -y /tmp/codex-garmin-rugby-timer-key.der -w`: PASS.
- `monkeydo build/garmin-rugby-timer-fenix7-test.prg fenix7 -t`: BLOCKED, unable to connect to simulator.
- Quickstart manual scenarios: BLOCKED in this environment because simulator/device execution is unavailable.
- Red-plus-yellow display priority amendment: PASS for app and test compiles on 2026-04-13.
- Multiple-yellow and separate-red-marker amendment: PASS for app and test compiles on 2026-04-13.

## 2026-04-13 Rugby Variant Menu

- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7.prg -y /tmp/codex-garmin-rugby-timer-key.der -w`: PASS.
- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7-test.prg -t -y /tmp/codex-garmin-rugby-timer-key.der -w`: PASS.

Coverage added:

- Variant menu availability is limited to the not-started pre-match state.
- Selecting 7s before kickoff applies 7s defaults and clears prior idle half-length adjustment.
- Attempting to set another variant after match start leaves the selected variant unchanged.
- Up remains the idle timer increment control after Menu becomes variant selection.

Coverage added:

- Paused-match try starts a wall-clock conversion timer without resuming match time.
- Penalty goals and drop goals do not create conversion timers.
- Pause reminder interval state is present in model snapshots.
- Yellow and red cards pause a running match.
- Same-team active yellow card display uses plain countdown timers, supports multiple simultaneous yellow timers, and keeps red cards as separate team markers.
- Event log entries record try, made conversion, penalty goal, drop goal, yellow card, and red card actions with team and match elapsed seconds.
- Reset clears event log and returns runtime match state to not-started.
- Back option routing exposes active/match-ended option availability and reset confirmation behavior.
- Activity recorder reports best-effort event export fallback state and supports discard/reset.

## 2026-04-13 Auto Period Transition

- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7.prg -y build\codex-garmin-rugby-timer-key.der -w`: PASS.
- `monkeyc -f monkey.jungle -d fenix7 -o build/garmin-rugby-timer-fenix7-test.prg -t -y build\codex-garmin-rugby-timer-key.der -w`: PASS.
- `monkeydo build\garmin-rugby-timer-fenix7-test.prg fenix7 /t`: PASS.
- 2026-04-14 half-time timer correction: app compile PASS, test compile PASS, simulator test artifact PASS.
- Quickstart manual scenarios: BLOCKED, no interactive simulator/device session was exercised in this run.

Coverage added:

- Non-final period countdown expiry automatically enters the between-period state.
- Half-time timer snapshots start at 00:00, count elapsed break time upward during automatic and deliberate non-final period breaks, and stop/leave view when the next half starts.
- Final period countdown expiry automatically enters the match-ended summary state.
- Unexpired yellow-card timers carry into the next period with team and remaining time preserved.
- Carried yellow-card timers do not decrement while the half-time timer advances.
- Paused-at-00:00 snapshots do not unexpectedly auto-transition.
- Red-card non-countdown behavior and conversion timer behavior remain unchanged around period expiry.
- Security/privacy check: no new persistence, network behavior, dependencies, telemetry, or red-card countdown behavior was added.
