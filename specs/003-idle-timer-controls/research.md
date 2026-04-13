# Research: idle-timer-controls

## R-001: Locate button handling
Search for input handling in `source/RugbyTimerDelegate.mc` and `source/RugbyTimerView.mc`. Most button-event routing for the app is centralized in `RugbyTimerDelegate.mc` which maps physical button events to actions.

## R-002: Long-press vs short-press behavior
Confirm if the project already distinguishes long-press and short-press (e.g., WatchUi::onKeyDown vs onKeyLongPress), and whether long-press currently opens score dialog. If long-press is used for additional actions, ensure short-press retains intended mapping.

Decision: Use short-press events for increment/decrement on idle; preserve long-press behavior unchanged.
