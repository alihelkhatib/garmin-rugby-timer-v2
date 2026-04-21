# Quickstart: Referee Field Controls Validation

## Prerequisites

- Garmin Connect IQ SDK installed with `monkeyc` and simulator tools on PATH.
- Java runtime compatible with the installed SDK.
- Working branch: `010-referee-field-controls`.

## Build

From the repository root:

```powershell
monkeyc -f monkey.jungle -o build/rugby-field-controls.prg
```

If SDK tools are unavailable, document that limitation in the PR and validate by code review plus any available unit-test harness.

## Unit Test Focus

Run the Monkey C test harness supported by the local SDK/IDE and verify:

- Latest-only undo for try, conversion, penalty goal, drop goal, yellow card, and red card.
- Undo confirmation cancel path leaves state unchanged.
- Undo clears a live conversion opportunity only when undoing the try that created it.
- Regulation expiry enters time-up overtime rather than half-ended/match-ended.
- Time-up overtime tracks overtime seconds for at least five simulated minutes.
- Back-button menu confirmation ends a non-final period or final match from time-up.
- Select/Start remains pause/resume during time-up.
- Summary presents newest-first order and excludes undone events.

## Simulator Smoke Flow

1. Launch on a representative large round profile such as fenix 6.
2. Start a 15s match.
3. Record home try, conversion made, away penalty goal, home yellow card, away red card.
4. Open Back-button match menu and confirm undo. Verify the red card is removed and summary no longer shows it.
5. Open summary. Verify newest visible first, scroll to older rows, and exit back to match.
6. Run the first half to `0:00`. Verify the app shows time-up/overtime and does not enter half-time automatically.
7. During time-up, pause/resume with Select/Start. Verify Select/Start does not end the period.
8. During time-up, record a score/card. Verify it appears in summary with consistent match time.
9. Open Back-button match menu and confirm end half. Verify half-time state begins.
10. Start second half, run to `0:00`, and confirm match end from the Back-button match menu. Verify activity save/summary behavior still works.

Repeat the readability check on a representative small round profile and any rectangular profile supported by the manifest.

## Performance Checks

- Confirm timer updates remain one-second cadence in running, half-time, and time-up states.
- Confirm no repeated time-up haptic occurs on each refresh.
- With at least 20 events, summary scrolling remains responsive and does not overlap text on small screens.
- Compare compiled artifact size against the previous release artifact; investigate unexpected growth.

## Release Checklist

- Unit tests pass or documented SDK limitation exists.
- Simulator smoke flow completed on large and small watch profiles.
- Activity save/discard verified after time-up match-end and reset.
- Existing score/card/conversion flows regression checked.
- No new network, telemetry, persistent storage, or dependencies added.
- Store/release notes mention that period expiry is now referee-confirmed rather than automatic.

## Rollback

If validation fails before release, revert this feature branch to restore prior behavior. If a narrow emergency patch is needed, hide the new undo/summary menu entries and restore automatic expiry while preserving stable start/pause/resume behavior.
