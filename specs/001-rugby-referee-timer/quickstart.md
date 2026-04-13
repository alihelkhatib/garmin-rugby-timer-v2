# Quickstart: Rugby Referee Timer

## Prerequisites

- Garmin Connect IQ SDK installed.
- A Connect IQ simulator profile for at least one fenix 6 generation watch and one newer compatible watch.
- Device/API validation for Connect IQ API 4.1.6 before relying on exact rugby activity recording.

## Build and Run

1. Create the Connect IQ app structure from this plan: `manifest.xml`, `monkey.jungle`, `source/`, `resources/`, and `tests/`.
2. Add Fit permission for activity recording in the manifest.
3. Build with the Garmin Connect IQ toolchain.
4. Run in the Garmin simulator on representative small and large round watch profiles.

## Manual Validation Scenarios

1. Start a 15s match and confirm the main countdown is dominant, the secondary timer and half indicator are visible, and activity recording starts as rugby where supported.
2. Pause and resume match time; confirm countdown, count-up active match timer, yellow-card timers, conversion timer, and haptic thresholds all pause/resume together.
3. Record try, conversion, penalty goal, and drop goal for each team; confirm score and scoring counters update within one display refresh cycle.
4. Record a try while conversion timer is active; confirm the latest try replaces the existing conversion timer.
5. Start a yellow-card timer; confirm it uses the selected sin-bin length and fires a haptic alert at 60 seconds remaining when haptics are supported.
6. Record a red card; confirm a persistent red-card indicator appears without an expiry countdown and without relying on color alone.
7. Validate 7s, 10s, U19, and custom timing setup; confirm half, sin-bin, and conversion overrides affect later timers.
8. Start multiple yellow-card timers for the same and different teams; confirm independent countdowns, constrained-layout summary behavior, and clear/expired behavior.
9. Trigger yellow-card and conversion 60-second alerts in the same update cycle; confirm one coalesced haptic alert occurs and each alert is marked fired.
10. Pause near half end, resume, and end the half; confirm yellow-card and conversion timers pause across half-ended state and resume from the same active-time source.
11. Attempt end-half and end-match/save actions; confirm deliberate confirmation protects against accidental terminal state changes.
12. Correct an entered score/counter action; confirm score and counter correction updates within one display refresh and no match-history database is created.
13. End the match and save the recording; confirm Garmin activity history shows rugby or the documented fallback for that target.

## Fallback Policy

If a target device cannot support exact `Activity.SPORT_RUGBY` recording, do not silently ship it as equivalent. Either exclude that target from the manifest for v1 or document a tested rugby-equivalent Garmin fallback such as a team-sport match sport/sub-sport in the validation notes before enabling the target. Arbitrary non-rugby labels are not acceptable v1 fallbacks.
