# UI Interaction Contract: idle-timer-controls

## Idle Screen

Preconditions:

- Match state is `notStarted`.
- The main timer is visible on the idle screen.

Contract:

- Short-press Up/Menu increments the main timer by 1 minute unless the timer is already at the selected variant's normal half length.
- Short-press Down decrements the main timer by 1 minute unless the timer is already at 00:00.
- Score dialog must not open from Up/Menu, Down, or any other physical-button path.
- The visible timer value updates on the next UI refresh after each accepted adjustment.

Boundary behavior:

- At 00:00, Down leaves the timer at 00:00.
- At the selected variant's normal half length, Up/Menu leaves the timer at that normal half length.

## Match Start

Preconditions:

- Match state is `notStarted`.
- The referee has optionally adjusted the idle main timer.

Contract:

- Starting the match uses the currently visible idle main timer value as the starting countdown.
- Starting the match moves the match into an active running state and keeps existing recorder start behavior.

## Active Match Scoring

Preconditions:

- Match state is `running`, `paused`, or `halfEnded`.

Contract:

- The existing score dialog path remains available.
- Existing score actions continue to update the selected team's score according to current scoring rules.
- The idle timer adjustment behavior must not run in these active match states.

## Match Ended

Preconditions:

- Match state is `matchEnded`.

Contract:

- Score dialog must not open from physical-button paths.
- Idle pre-match adjustment does not apply until the app returns to a not-started setup state through the existing app flow.
