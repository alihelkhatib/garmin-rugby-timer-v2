# Data Model: Referee Field Controls

## Match Clock State

Represents the current period timing state for a single in-progress match.

Fields:

- `clockState`: One of `notStarted`, `running`, `paused`, `halfEnded`, `timeUp`, `matchEnded`.
- `halfIndex`: Current half/period number, starting at 1.
- `halfCount`: Number of periods in the selected variant.
- `halfLengthSeconds`: Regulation duration for the current period.
- `activeElapsedMs`: Active match elapsed time accumulated before the current running segment.
- `halfStartedAtMs`: Monotonic timer anchor for the current running or between-period segment.
- `timeUpAlertFired`: Boolean indicating whether the regulation-expiry haptic/status alert has already fired for the current period.

Validation rules:

- `timeUp` begins only after active elapsed time reaches or exceeds `halfLengthSeconds`.
- `timeUp` preserves `halfIndex` until the referee confirms period or match end.
- `mainCountdownSeconds` is clamped to zero in `timeUp`.
- `overtimeSeconds` is the elapsed active time beyond regulation and is zero/null outside `timeUp`.
- Select/Start does not transition out of `timeUp`; Back-button match menu confirmation does.

State transitions:

```text
notStarted --start--> running
running --pause--> paused
paused --resume--> running
running --regulation expiry--> timeUp
timeUp --pause--> paused/timeUp-paused equivalent
timeUp --Back menu confirms non-final period--> halfEnded
timeUp --Back menu confirms final period--> matchEnded
halfEnded --start next half--> running
running/paused/timeUp --manual end match confirm--> matchEnded
any active/completed state --reset confirm--> notStarted
```

## Undoable Event

Represents the latest score/card event that can be reversed.

Fields:

- `id`: Monotonic current-match event id.
- `teamId`: `home` or `away`.
- `action`: `try`, `conversionMade`, `penaltyGoal`, `dropGoal`, `yellowCard`, or `redCard`.
- `matchElapsedSeconds`: Match time when the event was recorded.
- `scoreDelta`: Points added by the event, if any.
- `countField`: Team counter affected by the event, if any.
- `sanctionId`: Sanction id created by a yellow/red card event, if any.
- `createdConversionTimer`: Boolean indicating whether a try event created the currently active conversion opportunity.

Validation rules:

- Only the latest score/card event is eligible for undo.
- Undo removes the event from the current-match event log.
- Undo reverses only state created by that event.
- Undoing a conversion removes the conversion points/count but not the preceding try.
- Undoing a try with an active related conversion opportunity clears that conversion opportunity.
- Undoing a card removes the sanction created by that card event and does not alter unrelated sanctions.

## Match Summary Event

Represents a user-visible match event in the summary.

Fields:

- `id`: Current-match event id.
- `teamId`: `home` or `away`.
- `action`: Event action label/type.
- `matchElapsedSeconds`: Match time for display and ordering.
- `displayText`: Formatted short text for watch display.

Validation rules:

- Summary displays newest-first by default.
- The underlying event data remains current-match only.
- Undone events are absent from the summary.
- Empty summaries show a clear empty state.

## Summary View State

Represents navigation state for the scrollable summary view.

Fields:

- `eventCount`: Number of visible current-match events.
- `topIndex`: Index of the first visible row in newest-first display order.
- `visibleRows`: Number of rows that fit on the current screen profile.
- `canScrollUp`: Whether newer hidden rows exist above the current window.
- `canScrollDown`: Whether older hidden rows exist below the current window.

Validation rules:

- `topIndex` is clamped to valid event bounds.
- Up/Down navigation changes `topIndex` only when more events exist.
- Exiting summary does not change match state.

## Match Menu Action

Represents a selectable action from the Back-button match menu.

Fields:

- `id`: Menu action identifier.
- `label`: User-visible label.
- `enabled`: Whether the action should be visible/selectable for the current state.
- `requiresConfirmation`: Whether selecting the action sets a pending confirmation first.

Validation rules:

- `undoLastEvent` appears only when a latest score/card event exists and match has not been reset.
- `matchSummary` appears during active, paused, half-ended, time-up, and match-ended states; not before match start or after reset.
- `endHalf` appears for time-up non-final periods and requires confirmation.
- `endMatch` appears for time-up final period and existing match-ending states and requires confirmation.
- `resetMatch` keeps existing confirmation behavior.
