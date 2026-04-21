# Garmin Rugby Timer v2

Developer guide: see docs/DEVELOPER.md

## Controls

- Before kickoff, press Up/Menu to add 1 minute to the main timer, capped at the selected variant's normal half length.
- Before kickoff, press Down to subtract 1 minute from the main timer, capped at 00:00.
- Before kickoff, press Menu to choose a built-in rugby variant: 15s, 7s, 10s, or U19.
- Before kickoff, press Select/Start to begin the match from the visible main timer.
- The score menu is available only while a match is running, paused, half-ended, or in time-up overtime.
- The score menu stays blocked before kickoff and after match end.
- Recording a try opens the conversion overlay and starts the conversion countdown automatically, including while the main match clock is paused.
- Press Select/Start during a running match to pause; the app vibrates immediately and reminds every 10 seconds while it remains paused.
- Issuing a yellow or red card records the card and pauses the match.
- When the main countdown reaches 00:00, the watch alerts, shows TIME, and the main timer changes to a red negative overtime count-up; the referee ends the half or match from the Back-button match menu when play is dead.
- Between halves, the elapsed timer shows a half-time count-up from 00:00 until the next half starts.
- Unexpired yellow-card timers pause at half end and resume in the next half with their remaining time preserved.
- Press Back during an active, paused, half-ended, time-up, or completed match to open match options.
- From match options, choose Undo last event to confirm removal of the latest score or card event.
- From match options, choose Match summary to review the current event log. The newest events appear first and Up/Down scroll through longer lists.
- From match options, choose End match or Reset match. End saves and shows the current match event summary; Reset discards the current activity and returns to the pre-match state.
