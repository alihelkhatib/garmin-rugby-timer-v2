# Data Model: idle-timer-controls

## Match State

Represents the app's match lifecycle for button routing.

Fields:

- `clockState`: one of `notStarted`, `running`, `paused`, `halfEnded`, or `matchEnded`.
- `activeForScoring`: true when `clockState` is `running`, `paused`, or `halfEnded`.
- `idleForTimerAdjustment`: true when `clockState` is `notStarted`.

Validation rules:

- Score dialog availability is true only when `activeForScoring` is true.
- Idle timer adjustment is true only when `idleForTimerAdjustment` is true.
- `matchEnded` must not allow score dialog access or idle pre-match adjustment.

State transitions:

- `notStarted` -> `running` when a match starts.
- `running` -> `paused` when a match is paused.
- `paused` -> `running` when a match resumes.
- `running` or `paused` -> `halfEnded` when a half is ended and another half remains.
- `running`, `paused`, or `halfEnded` -> `matchEnded` when the match is ended.

## Main Timer Value

Represents the visible main timer on the idle screen and the starting countdown value when the match begins.

Fields:

- `mainCountdownSeconds`: the visible countdown value in seconds.
- `adjustmentStepSeconds`: 60 seconds.
- `minSeconds`: 0.
- `maxSeconds`: selected variant normal half length in seconds.

Validation rules:

- Up/Menu on idle increases `mainCountdownSeconds` by 60 seconds unless already at `maxSeconds`.
- Down on idle decreases `mainCountdownSeconds` by 60 seconds unless already at `minSeconds`.
- Starting a match uses the current `mainCountdownSeconds` value.
- The value must never be below `minSeconds` or above `maxSeconds`.

## Variant Timer Bounds

Represents the selected rugby variant's normal timing bounds used to constrain idle adjustment.

Fields:

- `variantId`: selected variant identifier.
- `normalHalfLengthSeconds`: preset normal half length for the selected variant.
- `currentHalfLengthSeconds`: current setup value used for the next match start.

Validation rules:

- `normalHalfLengthSeconds` is the upper bound for idle timer increments.
- If a custom current half length exists from prior setup behavior, idle increment behavior still respects the selected variant's normal half length as the maximum.

## Score Dialog Availability

Represents whether score controls can be opened from physical buttons.

Fields:

- `scoreDialogAllowed`: true only for running, paused, and half-ended match states.
- `scoreDialogBlockedReason`: idle before kickoff or match ended.

Validation rules:

- Up/Menu, Down, and any physical-button path must not open the score dialog while `clockState` is `notStarted` or `matchEnded`.
- Existing score actions remain available while `clockState` is `running`, `paused`, or `halfEnded`.
