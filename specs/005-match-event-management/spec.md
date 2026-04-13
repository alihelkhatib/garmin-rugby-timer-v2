# Feature Specification: Match Event Management

**Feature Branch**: `005-match-event-management`  
**Created**: 2026-04-13  
**Status**: Draft  
**Input**: User description: "Base features are working. Fix the bug where a try scored while the match is paused opens the conversion overlay but the conversion timer does not start, even when pressing Select. The conversion overlay should begin automatically after only a try is scored and the timer should start automatically. Move the conversion timer up further to avoid clipping tool-hints, only on the conversion overlay. When the match is paused, vibrate to indicate pause, then vibrate every 10 seconds or a reasonable amount to warn the user it is still paused. Issuing a card should pause the match. Add an event log for major events such as scoring and cards, including team, action, and match time; save with the activity file if possible and make it viewable at match end. Red cards do not need prominent display because they have no timer in current lower-level law. Back should show options for End match and Reset match."

## Clarifications

### Session 2026-04-13

- Q: Which scoring and card events should be captured in the match event log? → A: Log only point-scoring actions and issued cards: try, made conversion, penalty goal, drop goal, yellow card, red card.
- Q: What should Reset match do with the current match activity and event log? → A: Reset clears runtime match state and event log, discards/does not save the current activity, and returns to the pre-match setup.
- Q: How long should the in-app match-end event log remain viewable? → A: Event log is viewable in the match-end summary for the current match, then cleared on Reset or new match start.
- Q: What should be displayed when teams have multiple cards? → A: Show yellow-card timers as plain countdowns without a `Y#` prefix, show multiple active yellow timers for the same team at the same time, and show red cards as a separate small red card marker near the team label instead of in the timer text.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automatic Conversion After Try (Priority: P1)

As a referee, I need a conversion countdown to begin automatically after a try is recorded, even if the match clock is paused when the try is entered.

**Why this priority**: Try and conversion handling is a core scoring flow; a conversion overlay without an active timer is misleading and can cause missed conversion timing.

**Independent Test**: Pause the match, record a try for either team, and verify the conversion overlay opens with a running conversion timer without pressing Select or any other start action.

**Acceptance Scenarios**:

1. **Given** the match is paused, **When** the referee records a try for Home, **Then** the conversion overlay opens and its countdown begins automatically.
2. **Given** the match is paused, **When** the referee records a try for Away, **Then** the conversion overlay opens and its countdown begins automatically.
3. **Given** a score is recorded that is not a try, **When** the score is saved, **Then** no conversion overlay is opened and no conversion countdown begins.
4. **Given** the conversion overlay is open, **When** the referee views its timer and hints, **Then** the conversion timer is positioned high enough that it does not clip or overlap the tool hints.

---

### User Story 2 - Pause Awareness And Card Pause Behavior (Priority: P1)

As a referee, I need clear tactile feedback when the match is paused, including periodic reminders, and I need the match to pause automatically when a card is issued.

**Why this priority**: A referee can accidentally restart play without restarting the app timer; pause reminders and card-triggered pause behavior reduce match-time errors.

**Independent Test**: Pause a running match and verify immediate and periodic pause vibrations; issue a card during a running match and verify the match pauses.

**Acceptance Scenarios**:

1. **Given** the match is running, **When** the referee presses Select/Start to pause, **Then** the app pauses the match and provides a pause vibration.
2. **Given** the match remains paused, **When** approximately 10 seconds pass, **Then** the app provides a reminder vibration and continues reminding at the same interval until the match resumes or ends.
3. **Given** the match is running, **When** the referee issues a yellow card, **Then** the match is paused and the card is recorded.
4. **Given** the match is running, **When** the referee issues a red card, **Then** the match is paused and the card is recorded without requiring a red-card timer display.
5. **Given** haptics are unavailable, **When** pause or reminder feedback is due, **Then** match behavior remains correct and diagnostics indicate that vibration was unavailable.
6. **Given** a team already has a red card, **When** that same team receives an active yellow card, **Then** the team card display shows the yellow-card timer as plain countdown text and keeps a separate red-card marker near the team label.
7. **Given** a team already has an active yellow card, **When** that same team receives another active yellow card, **Then** both yellow-card timers are visible for that team at the same time.

---

### User Story 3 - Match Event Log (Priority: P2)

As a referee, I need a match event log that records major score and card events with the team, action, and match time so I can review what happened.

**Why this priority**: A post-match event record supports referee review and provides useful context for the saved activity where supported.

**Independent Test**: Record scores and cards for both teams, end the match, and verify the event log lists each event with team, action, and match time in match order.

**Acceptance Scenarios**:

1. **Given** a match is running or paused, **When** the referee records a score, **Then** the event log records the team, score action, and current match time.
2. **Given** a match is running or paused, **When** the referee issues a card, **Then** the event log records the team, card action, and current match time.
3. **Given** the match ends, **When** the referee reviews the match summary, **Then** the event log is viewable for the current match until Reset match or a new match start clears it.
4. **Given** activity-file event export is supported, **When** the match is saved, **Then** the event log is included with the saved activity data.
5. **Given** activity-file event export is not supported, **When** the match is saved, **Then** the match still saves and the event log remains viewable in the app's match-end summary for the current match.

---

### User Story 4 - End Or Reset From Back (Priority: P2)

As a referee, I need Back to present clear match-exit choices so I can either end and save the match or reset everything to the pre-match state.

**Why this priority**: Back currently acts too bluntly for match lifecycle control; referees need explicit choices for saving or discarding the current match state.

**Independent Test**: Press Back during a match, choose each option in separate runs, and verify End match saves while Reset match returns to the original pre-match state.

**Acceptance Scenarios**:

1. **Given** a match is active, **When** the referee presses Back, **Then** the app offers End match and Reset match choices.
2. **Given** the referee chooses End match, **When** the choice is confirmed, **Then** the match ends and the activity/match is saved.
3. **Given** the referee chooses Reset match, **When** the choice is confirmed, **Then** scores, timers, cards, conversion state, pending actions, event log, and the unsaved current activity are discarded and the app returns to the pre-match state.
4. **Given** the referee opens the Back options accidentally, **When** they cancel or go back, **Then** the current match remains unchanged.

### Edge Cases

- A try can be recorded while the match is paused; the conversion timer must still run automatically.
- A card can be issued while already paused; the card should be recorded without changing the paused state unexpectedly.
- If a team has both a red card and one or more active yellow cards, yellow timers should remain visible as countdowns while the red card remains indicated separately.
- If a team has multiple active yellow cards, each active yellow timer should be visible without `Y#` labels.
- Pause reminder vibrations must stop once the match resumes, ends, or resets.
- Reset match must clear conversion overlays, card timers, event log entries, pending confirmations, and the unsaved current activity.
- Starting a new match after a completed match must clear the prior in-app match-end event log.
- Event log match time must use match elapsed time, not wall-clock time.
- Activity-file event export may be unavailable; the match must still save successfully without losing in-app match-end review.
- The conversion overlay layout adjustment must not affect the main match screen layout.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST automatically start the conversion countdown when a try is recorded for either team.
- **FR-002**: The system MUST start the conversion countdown automatically even when the match clock is paused at the moment the try is recorded.
- **FR-003**: The system MUST NOT open or start a conversion countdown for penalty goals, drop goals, conversions, or card actions.
- **FR-004**: The conversion overlay MUST position the conversion countdown so that it does not clip or overlap the tool hints, and this layout change MUST apply only to the conversion overlay.
- **FR-005**: The system MUST provide tactile feedback when the match transitions from running to paused, when haptics are available.
- **FR-006**: The system MUST provide recurring tactile reminders while the match remains paused, using an interval of approximately 10 seconds unless device constraints require a nearby practical interval.
- **FR-007**: The system MUST stop pause reminder feedback when the match resumes, ends, or resets.
- **FR-008**: The system MUST pause the match when a yellow or red card is issued during a running match.
- **FR-009**: The system MUST record point-scoring events in an event log with team, action, and match elapsed time, limited to tries, made conversions, penalty goals, and drop goals.
- **FR-010**: The system MUST record card events in an event log with team, action, and match elapsed time.
- **FR-011**: The system MUST show the event log at match end for the current match and clear that in-app summary when the user resets or starts a new match.
- **FR-012**: The system MUST attempt to include event log entries in the saved activity file when the platform supports attaching such event data.
- **FR-013**: If activity-file event export is unavailable, the system MUST still save the activity/match and keep the event log viewable in the app's match-end summary for the current match until Reset match or a new match start clears it.
- **FR-014**: Red cards MUST be recorded in the event log, but the system does not need to display a persistent red-card timer while no lower-level red-card timer rule is supported.
- **FR-014a**: Yellow-card timers on the main match display MUST be shown as plain countdowns without `Y#` labels.
- **FR-014b**: When a team has multiple active yellow cards, the main match display MUST show multiple yellow-card countdowns for that team at the same time.
- **FR-014c**: Red cards MUST be indicated separately from the yellow-card timer text using a small red visual marker near the affected team's label or similarly compact team-specific position.
- **FR-015**: Pressing Back during a match MUST present End match and Reset match choices rather than immediately mutating the match.
- **FR-016**: End match MUST end the match and save the activity/match after confirmation.
- **FR-017**: Reset match MUST clear all match runtime state, discard the current unsaved activity/match, clear the event log, and return the app to the original pre-match state after confirmation.
- **FR-018**: Canceling the Back options MUST leave the current match unchanged.
- **FR-019**: The system MUST emit diagnostics for conversion timer start, pause reminder scheduling, card-triggered pause, event-log recording, activity export capability, end match, and reset match.

### Key Entities

- **Conversion Attempt**: A try-related countdown for the scoring team, with automatic start behavior and visible overlay state.
- **Paused Match Reminder**: A recurring tactile cue while the match remains paused, with start and stop conditions.
- **Match Event Log Entry**: A record of a scoring or card event containing team, action, and match elapsed time.
- **Match Summary**: The end-of-match view that includes event log entries for referee review.
- **Back Match Option**: A referee choice to end/save or reset the match, including cancellation behavior.
- **Activity Event Export**: Best-effort inclusion of match event entries with the saved activity file when supported.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In paused-match try tests for Home and Away, 100% of try entries open the conversion overlay with a running countdown without an additional start press.
- **SC-002**: In conversion overlay visual checks on representative watch profiles, the conversion countdown does not clip or overlap the tool hints.
- **SC-003**: In 10 pause tests on haptic-capable devices, 100% of pause transitions provide immediate tactile feedback.
- **SC-004**: During a 30-second paused-match observation, at least two pause reminder vibrations occur and then stop after the match resumes.
- **SC-005**: In card issue tests from a running match, 100% of yellow and red card entries pause the match and create event log entries.
- **SC-005a**: In mixed-card display tests, 100% of same-team red-plus-active-yellow states show yellow-card timers as plain countdowns and expose a separate red-card marker.
- **SC-005b**: In multiple-yellow tests, 100% of same-team multiple-active-yellow states show each active yellow-card countdown for that team.
- **SC-006**: In a match containing at least five score/card events, 100% of event log entries show team, action, and match elapsed time in match order.
- **SC-007**: In Back option tests, End match saves the match and Reset match discards the current activity/match and returns to the pre-match state without leaving stale scores, timers, cards, conversion state, pending actions, or event log entries.

## Assumptions

- The practical pause reminder interval is 10 seconds unless the device runtime requires a nearby interval for reliability.
- Conversion countdown timing is independent from whether the main match clock is paused.
- Current lower-level rugby use does not require a persistent red-card countdown; red card events still matter in the event log.
- Activity-file event export may be limited by platform support; local end-of-match review is the required fallback.
- Reset match returns to the selected/default variant setup that existed before the current match began.
- Event log entries use generic team side labels and rugby actions, not personal player identities.

## Security & Privacy Considerations

- Data classification: Event log entries contain match events, team side labels, action names, and match elapsed time; they do not contain player PII.
- Telemetry opt-in: No network telemetry or remote analytics are added.
- Retention & deletion: Event log entries are retained for the current match and cleared by Reset match; saved activity inclusion is best effort when platform support exists.
- External communications: No new network calls are required. Saved activity behavior uses the existing activity-save flow where available.
- Required security tests: Confirm event logs do not include personal data, do not transmit data outside existing activity-save behavior, and are cleared on Reset match.
