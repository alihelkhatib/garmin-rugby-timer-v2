# Data Model: Rugby Referee Timer

## MatchSetup

Fields:
- `variantId`: selected built-in variant identifier (`fifteens`, `sevens`, `tens`, `u19`, `custom`).
- `halfLengthSeconds`: active half duration after one-minute adjustments.
- `halfCount`: number of match halves/periods for the selected variant.
- `sinBinLengthSeconds`: yellow-card sanction duration after overrides.
- `conversionLengthSeconds`: conversion timer duration after overrides.
- `homeLabel`, `awayLabel`: fixed v1 display labels, defaulting to Home and Away.

Validation:
- Half length changes in 60-second steps.
- Sin-bin and conversion lengths must be positive durations.
- Custom timings must still be stored as one MatchSetup so variants do not create separate code paths.

## VariantPreset

Fields:
- `id`, `displayName`.
- `defaultHalfLengthSeconds`.
- `defaultHalfCount`.
- `defaultSinBinLengthSeconds`.
- `defaultConversionLengthSeconds`.

Relationships:
- MatchSetup starts from one VariantPreset and then applies user overrides.

## MatchClockState

Fields:
- `halfIndex`: current half/period number.
- `state`: `notStarted`, `running`, `paused`, `halfEnded`, `matchEnded`.
- `halfStartedAtMs`: monotonic timestamp for the current half start/resume baseline.
- `activeElapsedMs`: accumulated active match time for the current half.
- `pendingConfirmAction`: optional deliberate confirmation target for end-half or end-match/save actions.
- `lastSnapshotMs`: monotonic timestamp used for the current render snapshot.

Derived values:
- `mainCountdownSeconds` = `halfLengthSeconds - activeElapsedMs` rounded for display.
- `countUpSeconds` = `activeElapsedMs` rounded for display.
- `renderSnapshotId` identifies the single state snapshot used by the view for all visible timers and alert thresholds in one refresh.

State transitions:
- `notStarted -> running` on start.
- `running -> paused` on pause; all timers freeze from the same state.
- `paused -> running` on resume; all timers resume from the same state.
- `running|paused -> halfEnded` on end-half.
- Final half end transitions to `matchEnded` after deliberate confirmation.
- `halfEnded` and `matchEnded` stop active-time progression for all derived timers.
- Pause/resume are reversible through the opposite control without changing score, sanction, or activity recording state.

## TeamState

Fields:
- `teamId`: `home` or `away`.
- `label`.
- `score`.
- `tryCount`.
- `conversionCount`.
- `penaltyGoalCount`.
- `dropGoalCount`.
- `correctionHistory`: lightweight state needed to reverse or correct explicit score/counter entries.

Scoring rules:
- Try adds 5 points and increments tryCount.
- Conversion adds 2 points and increments conversionCount.
- Penalty goal adds 3 points and increments penaltyGoalCount.
- Drop goal adds 3 points and increments dropGoalCount.
- Explicit correction actions adjust the affected score and counter without creating a separate match history database.

## DisciplineSanction

Fields:
- `id`.
- `teamId`.
- `cardType`: `yellow` or `red`.
- `startedAtActiveMs`.
- `durationSeconds`: present for yellow cards only.
- `state`: `active`, `expired`, `cleared`.
- `nearExpiryAlertFired`: true after the 60-second warning fires for yellow cards.

Rules:
- Yellow sanctions derive remaining time from MatchClockState active elapsed time and pause/resume with match time, including across half-ended states.
- Multiple yellow sanctions may be active for the same or different teams and are tracked by distinct ids.
- Red sanctions have no countdown and remain active until cleared or match end.
- Expired yellow sanctions remain in `expired` state until cleared or match end when the UI needs to show that the sanction has expired.
- Card display must include text/icon/position cues in addition to color.

## ConversionTimer

Fields:
- `active`: boolean.
- `teamId`: team associated with the latest try.
- `startedAtActiveMs`.
- `durationSeconds`.
- `nearExpiryAlertFired`: true after the 60-second warning fires.

Rules:
- Recording a try starts a conversion timer for the try's team.
- Recording a try while a conversion timer is active replaces the existing conversion timer.
- Conversion timer derives remaining time from MatchClockState active elapsed time and pauses/resumes with match time.
- Changes to conversion length affect future conversion timers only; an active timer keeps its starting duration.

## ActivityRecordingState

Fields:
- `state`: `notStarted`, `recording`, `stopped`, `saved`, `discarded`, `unsupported`.
- `sport`: target sport constant, primary `Activity.SPORT_RUGBY`.
- `subSport`: target sub-sport constant, primary `Activity.SUB_SPORT_MATCH`.
- `fallbackReason`: populated when a device cannot support exact rugby labeling.

Rules:
- Only one activity recording session owner exists in the app.
- Session lifecycle follows match lifecycle: create/start with match start, stop/save at confirmed match end, discard only through explicit error/cancel handling.
- Fallback labeling must be `Activity.SPORT_RUGBY` when supported or a documented rugby-equivalent Garmin sport/sub-sport fallback; otherwise the target remains unsupported for v1.

## ActivityMotionData

Fields:
- `distance`: total distance or mileage captured for the current recording.
- `currentSpeed`: instantaneous speed value derived during recording.
- `averageSpeed`: average speed value derived during recording.
- `routeSamples`: optional route trace samples when GPS is available and permitted.

Rules:
- Motion data is recorded only when GPS and positioning permission are available.
- If GPS is unavailable or denied, the activity still saves with match and event data but without motion data values.
