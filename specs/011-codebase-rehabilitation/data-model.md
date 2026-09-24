# Data Model: Codebase Rehabilitation

## Match

Fields:

- `schemaVersion`: recovery compatibility version.
- `state`: `notStarted`, `running`, `paused`, `betweenPeriods`, or `matchEnded`.
- `variantId`, `variantName`: chosen rule preset or custom configuration.
- `periodIndex`, `periodCount`, `periodDurationSeconds`: current period configuration.
- `accumulatedActiveMs`: completed active time in the current period.
- `runningAnchorMs`: monotonic anchor, present only while running in memory.
- `betweenPeriodsAnchorMs`: monotonic half-time anchor while between periods.
- `teams`: exactly home and away.
- `events`: ordered match event collection.
- `sanctions`: current and historical sanctions needed by UI/summary.
- `conversionAttempt`: zero or one active attempt.
- `nextEventId`, `nextSanctionId`: monotonically increasing identifiers.
- `pendingConfirmation`: optional destructive action.

Validation:

- Indices and counts are positive and `periodIndex <= periodCount`.
- Durations and accumulated values are non-negative and clamped to supported bounds.
- A running anchor exists only in `running`; a half-time anchor exists only in `betweenPeriods`.
- Stored recovery never contains `running`; it is normalized to `paused` with accumulated time folded in.
- Unknown schema versions or malformed dictionaries are discarded safely.

## Team

Fields: `id`, `label`, `score`, `tryCount`, `conversionCount`, `penaltyGoalCount`, `dropGoalCount`.

Validation:

- ID is exactly home or away.
- Scores and counters are non-negative.
- Score equals the sum represented by non-corrected scoring events after recovery validation.

## Match Event

Fields: `id`, `teamId`, `type`, `periodIndex`, `periodElapsedSeconds`, `matchElapsedSeconds`, `status`.

Validation:

- IDs are unique and ordered.
- Team and event type are recognized.
- Times are non-negative.
- Status is `active` or `corrected`; correcting an event updates both team aggregates and event status.

## Sanction

Fields: `id`, `teamId`, `cardType`, `state`, `durationSeconds`, `startedAtActiveMs`, `remainingAtPeriodEndSeconds`, `alertFired`.

Validation:

- Yellow cards have a positive duration and active-time anchor.
- Red cards have no countdown.
- State is `active`, `pausedForPeriod`, `expired`, or `cleared`.
- Remaining time never becomes negative.

## Conversion Attempt

Fields: `teamId`, `startedAtMs`, `durationSeconds`, `state`, `alertFired`.

Validation:

- Uses wall-time monotonic elapsed duration while the app process is alive.
- Recovery stores remaining duration and restarts paused application state from that bounded remaining value; it does not infer time across process termination.
- State is `active`, `made`, `missed`, or `expired`.

## Activity Recording

Fields: `state`, `session`, `fallbackReason`, `eventExportState`, `retryCount`.

States: `idle -> recording -> saved` or `idle/recording -> discarded`; failures retain an explicit fallback reason. Terminal calls are idempotent.

## Transition Table

| Current state | Action | Next state | Notes |
|---|---|---|---|
| notStarted | start | running | Starts first period and activity once. |
| running | pause | paused | Folds timestamp delta into accumulated active time. |
| paused | resume | running | Creates a new monotonic anchor. |
| running | duration reached | betweenPeriods | Non-final period; preserves yellow-card remaining time. |
| running | duration reached | matchEnded | Final period; emits one match-ended result. |
| running/paused | end match confirm | matchEnded | Saves once and keeps summary available. |
| running/paused/betweenPeriods | stop and exit confirm | matchEnded | Saves once, clears recovery, and closes the application. |
| betweenPeriods | start | running | Starts next period and resumes carried yellow cards. |
| active/completed | reset confirm | notStarted | Discards recorder and clears active recovery. |
| any | invalid action | unchanged | No data or side effects change. |

## Derived Snapshot

A render snapshot contains state, variant/period labels, countdown, count-up, half-time, immutable team projections, conversion projection, sanctions, pending confirmation text, and transition/alert results already produced by `advance`. It does not perform navigation, recording, persistence, or vibration.
