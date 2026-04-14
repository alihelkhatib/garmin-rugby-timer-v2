# Period Transition Contract: Auto Period Transition

## Non-Final Period Expiry

- Given the match is running in a non-final period, when the main countdown reaches 00:00, the app enters the existing between-period flow without requiring a manual end-period action.
- The transition occurs once for that expiry event.
- A half-time timer is visible in the between-period flow, starts at 00:00, and counts elapsed break time upward.
- The half-time timer is separate from match play time; the main countdown remains stopped while it runs.
- The next-period start action remains referee-controlled through the existing flow.
- Period status, score, and any carried yellow-card timers remain readable on the match/between-period display.

## Deliberate Non-Final Period End

- Given the referee deliberately ends a non-final period, the app enters the existing between-period flow.
- A half-time timer is visible in the between-period flow, starts at 00:00, and counts elapsed break time upward.
- The same next-period start flow stops or hides the half-time timer and starts the next period.

## Final Period Expiry

- Given the match is running in the final configured period, when the main countdown reaches 00:00, the app enters the existing match-ended summary/save flow without requiring a manual end-match action.
- Score, card state, event log, and activity-save state reflect the match state at countdown expiry.
- No additional period-start option is shown after the final period.
- No half-time timer is shown after final-period match end.

## Yellow-Card Carry-Forward

- Given an active yellow-card timer has time remaining when a non-final period ends, that timer pauses at the boundary.
- During the break, the carried timer does not decrement while the half-time timer counts elapsed break time.
- When the next period starts, the carried timer is present for the same team and resumes from the preserved remaining time.
- If multiple yellow-card timers are active across either team, each unexpired timer is carried independently.
- If a yellow-card timer is expired or cleared before the boundary, it is not revived for the next period.

## Paused Boundary Behavior

- Given the match is paused at 00:00 or below, the app does not unexpectedly auto-end the period or match merely because the screen refreshes.
- The referee may still use existing explicit end-period/end-match controls while paused.
- If active timing resumes into the expiry boundary, automatic transition behavior applies.

## Out-of-Scope Timer Behavior

- Red cards remain non-countdown sanctions and do not gain a pause/resume timer.
- Conversion timer period-boundary behavior remains unchanged by this feature.
- Existing haptic alert behavior remains unchanged except for any alerts naturally affected by yellow-card expiry state.
