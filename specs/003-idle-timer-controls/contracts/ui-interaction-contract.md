# UI Interaction Contract: idle-timer-controls

## Idle Screen

Preconditions:

- Match state is `notStarted`.
- The main timer is visible on the idle screen.

Contract:

- Short-press Up/Menu increments the main timer by 1 minute unless the timer is already at the selected variant's normal half length.
- Short-press Down decrements the main timer by 1 minute unless the timer is already at 00:00.
- Short-press Select/Start begins the match from the currently visible idle main timer value.
- Score dialog must not open from Up/Menu, Down, or any other physical-button path.
- The visible timer value updates on the next UI refresh after each accepted adjustment.
- Idle button actions remain responsive; Up/Menu, Down, and Select/Start must not be ignored while the app is on the idle screen.
- The idle screen must not show raw internal state text such as `notStarted`; any visible status is referee-facing or omitted.
- The main timer remains visually centered in the primary timer area while preserving the existing scoreboard-style layout.

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
- Select/Start remains the idle-screen physical-button path for starting the match.

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
