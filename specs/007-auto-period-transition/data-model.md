# Data Model: Auto Period Transition

## Match Period State

- `clockState`: not started, running, paused, between periods, or match ended.
- `periodIndex`: current configured period number.
- `periodCount`: total periods for the selected match setup.
- `activeElapsedMs`: active play time accumulated in the current period.
- `periodStartedAtMs`: local time anchor used while the period is running.

### Rules

- A running non-final period transitions to between-period state when the main countdown reaches 00:00.
- A running final period transitions to match-ended state when the main countdown reaches 00:00.
- A paused period does not auto-transition simply because a displayed countdown is 00:00.
- Manual end-period and end-match paths remain available and must produce the same destination states.

## Main Countdown

- `durationSeconds`: configured period length from selected setup.
- `remainingSeconds`: duration minus active elapsed time, clamped to 00:00.
- `expiredThisUpdate`: true only for the active timing update that crosses or reaches 00:00 from a running period.

### Rules

- Drives automatic period or match transition.
- Must transition at most once for a given expiry.
- Must be computed from the same active elapsed time as count-up and yellow-card timers.

## Yellow Card Timer

- `id`: sanction identifier within the current match.
- `teamId`: Home or Away.
- `durationSeconds`: sanction duration selected when the card was created.
- `remainingSeconds`: current remaining active play time.
- `state`: active, paused-for-period, expired, or cleared.
- `nearExpiryAlertFired`: whether the near-expiry alert has already fired.

### Rules

- Active unexpired yellow-card timers pause at non-final period end.
- Paused-for-period yellow-card timers carry the same team assignment, remaining time, and alert state into the next period.
- Carried yellow-card timers resume when the next period starts.
- Yellow-card timers that expire before or during the same update as period expiry are not carried forward as active timers.
- Yellow-card timers are expired or otherwise stopped by final match end because there is no next period.

## Half-Time Timer

- `visible`: true while the app is between non-final periods.
- `startedAtMs`: local time anchor captured when the non-final period ends.
- `elapsedSeconds`: wall-clock elapsed break time since `startedAtMs`, displayed from 00:00 upward.
- `stoppedAtMs`: optional local time when the next period starts or the between-period flow exits.

### Rules

- Starts at 00:00 when a non-final period ends automatically or through the deliberate end-period path.
- Tracks elapsed break time only; it does not change active match elapsed time.
- Does not decrement the main countdown or any carried yellow-card timer while visible.
- Stops or leaves view when the referee starts the next period.
- Does not appear after final-period match end.

## Between-Period Flow

- `visible`: true after a non-final period ends.
- `nextPeriodIndex`: period number that will start after referee confirmation.
- `carriedYellowCards`: yellow-card timers preserved for the next period.
- `halfTimeTimer`: elapsed break timer shown while waiting for the next period.

### Rules

- Entered automatically when a non-final running period countdown reaches 00:00.
- Reuses the existing start-next-period referee flow.
- Does not decrement carried yellow-card timers during the break.
- Shows the half-time timer from 00:00 until the next period starts.

## Match-End Summary

- `visible`: true after final-period automatic end or deliberate end-match.
- `scoreState`: final Home/Away score and counters.
- `eventLog`: existing current-match event entries.
- `activitySaveState`: existing save/fallback state.

### Rules

- Entered automatically when the final running period countdown reaches 00:00.
- Preserves score, event log, card records, and save state as of expiry.
- Stops active countdown timers because no next period remains.
