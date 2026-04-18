# UI Interaction Contract: Rugby Referee Timer

## Purpose

This contract defines referee-facing input/state behavior for implementation and tests. It is not an external network API.

## Match Setup

Inputs:
- Select built-in variant: 15s, 7s, 10s, U19, or custom.
- Adjust half length in one-minute increments.
- Adjust sin-bin and conversion timer lengths.

Required state after setup:
- MatchSetup contains selected variant defaults plus overrides.
- Main countdown duration matches adjusted half length.
- Yellow-card and conversion timer durations match adjusted values.

## Match Clock Controls

Inputs:
- Start match.
- Pause match.
- Resume match.
- End half, requiring deliberate confirmation before finalizing the half.
- End match/save, requiring deliberate confirmation before saving.

Required state behavior:
- Start transitions match clock to running and starts activity recording if supported.
- Pause freezes main countdown, count-up active match timer, yellow-card timers, and conversion timer from one state snapshot.
- Resume restarts all paused timers from the same state snapshot.
- End half advances the half indicator or ends the match if final half is complete after confirmation.
- Accidental pause/resume is recoverable by invoking the opposite control without changing other match state.
- End-half and end-match/save are protected by deliberate confirmation to reduce accidental terminal state changes.

## Scoring Controls

Inputs:
- Record try for home/away: +5 points and +1 try count.
- Record conversion for home/away: +2 points and +1 conversion count.
- Record penalty goal for home/away: +3 points and +1 penalty goal count.
- Record drop goal for home/away: +3 points and +1 drop goal count.
- Correct an entered scoring action for home/away with an explicit lightweight correction action for the affected event type.

Required state behavior:
- Try starts a conversion timer for that team.
- A try while conversion timer is active replaces the active conversion timer with a new latest-try timer.
- Score and visible counters update within one display refresh cycle.
- Correction actions update the affected score and counter within one display refresh cycle and do not create match-history persistence.

## Discipline Controls

Inputs:
- Start yellow-card sanction for home/away.
- Record red-card sanction for home/away.
- Clear active or expired sanction when appropriate.

Required state behavior:
- Issuing a yellow or red card pauses the match clock before creating the selected sanction.
- Yellow card creates a countdown derived from match active time.
- Multiple yellow cards can be active on the same or different teams and are tracked independently.
- Yellow cards pause across paused and half-ended match states and resume from the same match timebase.
- Yellow card sends a haptic alert at 60 seconds remaining when haptics are supported.
- Red card creates a persistent indicator without countdown or expiry.
- Active sanctions remain distinguishable by text/icon/position in addition to color.
- Yellow card labels use a sequence and timer format such as `Y1  9:59` under the affected team score; red cards use persistent sequence indicators such as `R1` without a countdown timer.
- Simultaneous yellow-card and conversion alerts in the same update cycle coalesce into one haptic event while preserving each timer's alert-fired state.


## Match Screen Layout

Required visual hierarchy:
- Count-up active match timer at the very top.
- Half indicator directly under the count-up timer.
- Home and Away try counts directly under the half indicator.
- Home label in blue and Away label in orange, with each team's score directly underneath its label.
- Active yellow/red card timers assigned underneath the affected team's score.
- Main countdown timer large and anchored at the bottom as the dominant on-screen element.
## Activity Recording

Required behavior:
- Primary recording target is `Activity.SPORT_RUGBY` with match sub-sport when supported.
- If exact rugby labeling is unavailable for a validated target, validation records the rugby-equivalent fallback sport/sub-sport and reason; arbitrary non-rugby fallbacks exclude the target from v1.
- Only one recording session is owned by the app.
- Confirmed match end stops and saves the recording when recording is available.
- When GPS is available and permitted, saved recordings include total distance or mileage, current speed, average speed, and route data.
- If GPS is unavailable or denied, the recording still saves match and event data without motion data.

## Scoring Dialog Flow

- UP/MENU during active match management opens `Score Team`.
- The referee selects Home or Away, then selects Try, Penalty Goal, or Drop Goal.
- Penalty Goal and Drop Goal apply +3 and return to the main match screen.
- Try applies +5, increments the scoring team's try count, starts the conversion timer for the active variant, and opens the conversion action screen.
- On the conversion action screen, UP/MENU records +2 for a made conversion and DOWN records a missed conversion with no points. Both actions close the conversion screen and return to the main match screen.
- Idle before first match start: UP/MENU increases half length by 1 minute, DOWN decreases half length by 1 minute, and SELECT starts the match. These +/- controls are disabled after the match has started.
- Started match: UP/MENU opens scoring for Home/Away and score type; DOWN opens discipline/sanction for Home/Away and yellow/red card type.
- Conversion action screen: UP/MENU records +2 for a made conversion; DOWN records a missed conversion; either action closes the conversion screen and returns to the main match screen.
