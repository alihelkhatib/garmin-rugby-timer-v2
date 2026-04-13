# Data Model: Match Event Management

## Conversion Attempt

- `teamId`: `home` or `away`.
- `startedAtActiveMs`: match elapsed anchor used by the conversion countdown.
- `durationSeconds`: selected variant conversion duration.
- `active`: true while conversion is pending.
- `nearExpiryAlertFired`: true after the near-expiry haptic has fired.

### Rules

- Created only when a try is recorded.
- Created even if the main match clock is paused.
- Cleared when conversion is made, missed, expired, match ends, or match resets.
- Does not start for penalty goals, drop goals, made conversions, or card events.

## Paused Match Reminder

- `paused`: derived from match clock state.
- `intervalSeconds`: approximately 10 seconds.
- `active`: true only while match state is paused.
- `lastReminderAtMs`: last local timer moment when the pause reminder fired.

### Rules

- Starts when match transitions from running to paused.
- Stops when match resumes, ends, or resets.
- May report haptic unavailable without affecting match state.

## Match Event Log Entry

- `id`: monotonic sequence number within the current match.
- `teamId`: `home` or `away`.
- `action`: one of `try`, `conversionMade`, `penaltyGoal`, `dropGoal`, `yellowCard`, `redCard`.
- `matchElapsedSeconds`: elapsed match time when the event occurred.
- `createdAtSnapshotId`: optional diagnostic snapshot id for local tracing.

### Rules

- Records only point-scoring actions and issued cards.
- Uses match elapsed time, not wall-clock time.
- Is ordered by `id`.
- Is cleared by Reset match or new match start after a completed match.
- Contains no player names or PII.

## Match Summary

- `eventLog`: current match event log entries.
- `activitySaveState`: saved, unsupported, or failed status from existing recorder behavior.
- `visible`: true after End match until Reset/new match clears the current match summary.

### Rules

- Shows the event log at match end.
- Does not require activity-file event export to succeed.
- Must remain readable at watch scale.

## Back Match Option

- `option`: `endMatch`, `resetMatch`, or `cancel`.
- `requiresConfirmation`: true for end and reset options.
- `effect`: save/end, discard/reset, or no-op.

### Rules

- Back opens options during active or completed match states.
- End match ends and saves activity/match.
- Reset match discards current unsaved activity/match, clears runtime state and event log, and returns to pre-match setup.
- Cancel/back from options leaves match state unchanged.

## Activity Event Export

- `supported`: true only if platform/activity recorder supports event attachment.
- `attempted`: true when End match tries to include event log with saved activity.
- `result`: saved, unsupported, failed, or skipped.

### Rules

- Best effort only.
- Failure or unsupported export must not block activity/match save.
- Diagnostics must describe whether export was attempted and the result.
