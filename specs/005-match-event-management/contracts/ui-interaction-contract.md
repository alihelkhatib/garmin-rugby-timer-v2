# UI Interaction Contract: Match Event Management

## Conversion Overlay

### Start From Try

- Given the match is running or paused, recording a try for Home or Away opens the conversion overlay.
- The conversion countdown starts automatically before the overlay requires any user action.
- Select is not required to start the conversion timer.
- The conversion timer is positioned above the tool hints and must not clip or overlap them.
- This layout contract applies only to the conversion overlay, not the main match screen.

### Non-Try Score

- Penalty goal and drop goal actions record score and close score menus.
- They must not open the conversion overlay.

## Pause Haptics

- Pressing Select/Start while running transitions the match to paused and fires an immediate pause haptic when available.
- While paused, the app fires recurring pause reminder haptics approximately every 10 seconds.
- Reminder haptics stop when the match resumes, ends, or resets.
- Haptic unavailability is logged and must not block match state transitions.

## Card Issue Flow

- Issuing yellow or red card records the card event and pauses the match if it was running.
- Issuing a card while already paused records the event and leaves the match paused.
- Yellow cards remain visible as plain countdown timers without `Y#` labels.
- If the same team has multiple active yellow cards, the main match screen shows multiple countdown timers for that team.
- Red card is recorded in the event log and indicated separately from yellow timers with a compact red marker near the affected team's label or similar team-specific position.

## Event Log And Match Summary

- Score log entries are limited to tries, made conversions, penalty goals, and drop goals.
- Card log entries include yellow and red cards.
- Each entry displays team, action, and match elapsed time.
- Match-end summary shows the current match event log.
- Reset match or new match start clears the in-app summary.
- If saved-activity export is unsupported, the in-app summary remains the required review surface for the current match.

## Back Options

- Pressing Back during active or completed match states opens options: End match, Reset match, and cancel/back.
- End match requires confirmation and then ends/saves the match.
- Reset match requires confirmation and then discards the current unsaved activity/match, clears runtime state, clears event log, and returns to pre-match setup.
- Cancel or backing out leaves current match state unchanged.
