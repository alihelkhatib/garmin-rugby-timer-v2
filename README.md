# Garmin Rugby Timer v2

Developer guide: see docs/DEVELOPER.md

## Controls

- Before kickoff, press Up/Menu to add 1 minute to the main timer, capped at the selected variant's normal half length.
- Before kickoff, press Down to subtract 1 minute from the main timer, capped at 00:00.
- Before kickoff, press Select/Start to begin the match from the visible main timer.
- The score menu is available only while a match is running, paused, or half-ended.
- The score menu stays blocked before kickoff and after match end.
- Recording a try opens the conversion overlay and starts the conversion countdown automatically, including while the main match clock is paused.
- Press Select/Start during a running match to pause; the app vibrates immediately and reminds every 10 seconds while it remains paused.
- Issuing a yellow or red card records the card and pauses the match.
- Press Back during an active or completed match to choose End match or Reset match. End saves and shows the current match event summary; Reset discards the current activity and returns to the pre-match state.
