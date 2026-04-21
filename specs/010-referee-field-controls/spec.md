# Feature Specification: Referee Field Controls

**Feature Branch**: `010-referee-field-controls`  
**Created**: 2026-04-21  
**Status**: Draft  
**Input**: User description: "Implement the highest-value referee usability improvements: Undo last event from the Back-button match menu, referee-confirmed half-time/full-time expiry with TIME and overtime instead of automatic ending, and a scrollable recent-first match summary."

## Clarifications

### Session 2026-04-21

- Q: How should a referee confirm period or match end after regulation time has expired? -> A: Use the Back-button match menu; Select/Start remains dedicated to pause/resume.
- Q: What is the undo scope for this feature? -> A: Undo only the latest score/card event.
- Q: Where should the referee access the match summary? -> A: From the Back-button match menu in all match states except pre-match/reset.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Undo Last Event (Priority: P1)

As a rugby referee using physical watch buttons during live play, I need to undo the most recent score or card event from the match menu so that an accidental button press can be corrected quickly without resetting the match or manually counter-editing state.

**Why this priority**: Mistaps are likely under match pressure, and a wrong score or card can materially affect match management. Undo is the highest-value recovery path because it preserves the rest of the match state.

**Independent Test**: Record a try, penalty goal, drop goal, conversion, yellow card, or red card; open the match menu; choose undo last event; verify the most recent event is removed and the visible match state returns to the previous value.

**Acceptance Scenarios**:

1. **Given** an active, paused, half-ended, or completed match with at least one recorded score or card event, **When** the referee opens the Back-button match menu, **Then** an undo-last-event option is available for the latest score or card event only.
2. **Given** the latest event is a score, **When** the referee confirms undo, **Then** the event is removed from the summary and the relevant team's score and event count are reduced by the correct amount.
3. **Given** the latest event is a yellow or red card, **When** the referee confirms undo, **Then** that sanction is removed from the visible card state and the event is removed from the summary.
4. **Given** the match has no recorded events, **When** the referee opens the match menu, **Then** undo is unavailable or clearly disabled without affecting existing end, reset, or summary actions.
5. **Given** the referee starts an undo action accidentally, **When** they press Back before confirming, **Then** no event or match state is changed.

---

### User Story 2 - Referee-Confirmed Time Expiry (Priority: P2)

As a rugby referee, I need the watch to alert me when regulation time reaches zero but let play continue until I decide the ball is dead, so that the app supports real match timing rather than ending a half or match automatically.

**Why this priority**: Rugby halves do not always end at the exact moment the countdown reaches zero. The referee needs a clear time-up alert while retaining final control over when the period actually ends.

**Independent Test**: Run a half to zero, verify the watch shows a time-up state and continues counting overtime, then confirm period end and verify the app moves to half-time or match-ended state according to the current period.

**Acceptance Scenarios**:

1. **Given** a running half reaches 00:00, **When** regulation time expires, **Then** the app alerts the referee, shows a clear time-up state, and continues tracking overtime instead of immediately ending the period.
2. **Given** the app is in time-up overtime for a non-final half, **When** the referee opens the Back-button match menu and confirms period end, **Then** the app moves to half-time with existing score, card, conversion, and event state preserved.
3. **Given** the app is in time-up overtime for the final half, **When** the referee opens the Back-button match menu and confirms match end, **Then** the app follows the existing match-end save and summary flow.
4. **Given** time-up overtime is active, **When** the referee records a score or card before ending the period, **Then** the event is accepted and timestamped consistently with the ongoing match.
5. **Given** a yellow-card timer or conversion timer is active when regulation time expires, **When** overtime continues, **Then** the timer behavior remains visible and predictable without ending the match clock prematurely.

---

### User Story 3 - Scrollable Recent-First Match Summary (Priority: P3)

As a referee, I need a readable match summary that can show all recorded events with the newest events easiest to reach, so that I can resolve disputes or review recent actions without losing match context.

**Why this priority**: The existing summary concept is useful, but a real match can exceed the visible rows on a watch. Recent-first ordering makes the most likely review target fastest to reach.

**Independent Test**: Record more events than fit on one watch screen, open the match summary, verify the newest events appear first, and scroll through the full list without losing events.

**Acceptance Scenarios**:

1. **Given** a match has more events than fit on one screen, **When** the referee opens the summary, **Then** the newest recorded events are shown first and older events remain reachable by scrolling.
2. **Given** the summary is open during an active, paused, half-ended, time-up, or match-ended state, **When** the referee exits it, **Then** they return to the prior match context without changing timer, score, card, or event state.
3. **Given** the match has no recorded events, **When** the referee opens the summary, **Then** a clear empty state is shown.
4. **Given** the referee undoes an event, **When** they open the summary, **Then** the undone event is absent and the ordering of remaining events is still newest first.

### Edge Cases

- Undoing a try that created an active conversion opportunity must remove or resolve the related conversion state in a way that does not leave a stale conversion prompt or timer visible.
- Undoing a made conversion must remove only the conversion score and event, not the preceding try.
- Undoing a card during an active, paused, half-ended, or time-up state must remove the sanction without changing unrelated timers.
- Undo during match-ended review must update the visible summary and final score but must not restart the match.
- Time-up overtime must not repeatedly alert every screen refresh after the first time-up notification.
- Time-up overtime must remain legible on small round watch screens and must not hide score, card, or conversion information needed for field decisions.
- Summary scrolling must handle zero events, one event, exactly one screen of events, and more than one screen of events.
- Existing end-match and reset confirmations must remain available and must not be displaced by undo or summary access.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The match menu MUST provide an undo-last-event action whenever the current match has at least one recorded event and the match has not been reset.
- **FR-002**: The undo-last-event action MUST require an explicit confirmation before changing event, score, card, or timer state.
- **FR-002a**: The undo-last-event action MUST apply only to the latest recorded score or card event and MUST NOT support selecting arbitrary older events.
- **FR-003**: Undoing a score event MUST remove the latest score event from the match summary and reverse only the score and count changes caused by that event.
- **FR-004**: Undoing a yellow or red card event MUST remove the latest card event from the match summary and remove only the sanction caused by that event.
- **FR-005**: Undoing an event MUST preserve unrelated match state, including the current period, timer state, other team score, unrelated card timers, and existing activity recording state.
- **FR-006**: If no event can be undone, the app MUST prevent the undo action and leave the match state unchanged.
- **FR-007**: When regulation time reaches zero, the app MUST enter a time-up overtime state instead of automatically ending the half or match.
- **FR-008**: The time-up overtime state MUST provide a clear visual indication that regulation time has expired while continuing to show the match context needed by the referee.
- **FR-009**: The time-up overtime state MUST continue tracking elapsed overtime until the referee explicitly confirms the period or match end from the Back-button match menu.
- **FR-010**: Confirming period end from the Back-button match menu during time-up overtime MUST move to half-time for non-final periods and to the existing match-end flow for the final period.
- **FR-010a**: Select/Start MUST remain dedicated to the existing pause/resume behavior during time-up overtime and MUST NOT confirm period or match end.
- **FR-011**: Score, card, conversion, pause/resume, end-match, reset, and summary access behavior MUST remain available according to existing match-state rules unless explicitly blocked for safety by this specification.
- **FR-012**: The match summary MUST present recorded events in newest-first order by default.
- **FR-013**: The match summary MUST allow the referee to navigate through all recorded events when the event list is longer than one screen.
- **FR-014**: Exiting the match summary MUST return the referee to the previous match context without modifying match state.
- **FR-015**: The match summary MUST clearly show an empty state when no events have been recorded.
- **FR-015a**: The Back-button match menu MUST provide match-summary access during active, paused, half-ended, time-up, and match-ended states, and MUST NOT provide match-summary access before match start or after reset.
- **FR-016**: The affected areas for regression testing MUST include timer expiry behavior, score recording and correction, card recording and correction, conversion flow after tries, match menu actions, summary viewing, activity save/discard flows, haptic alerts, and small-screen readability.
- **FR-017**: Any visual changes MUST remain readable on supported watch profiles using physical-button navigation and must avoid requiring touch interaction.

### Key Entities *(include if feature involves data)*

- **Undoable Event**: The latest score or sanction event that can be reversed. It includes event type, team, match time, and the state changes that must be reversed. Older events are not directly selectable for undo in this feature.
- **Time-Up Overtime State**: A period state that begins when regulation time reaches zero and ends only when the referee confirms period or match end.
- **Match Summary Event**: A recorded match action shown in the summary, ordered newest first for review while preserving the underlying chronological event data.
- **Match Menu Action**: A referee-accessible action from the Back-button match menu, including end match, reset match, match summary, and undo last event.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In live-match usability tests, a referee can undo the most recent score or card event from the match screen path in no more than three button actions after opening the match menu.
- **SC-002**: Across score and card event types, 100% of undo tests restore the visible score, card state, and summary list to the expected previous state.
- **SC-003**: In timing tests, regulation expiry never ends a half or match without referee confirmation.
- **SC-004**: In time-up tests, overtime remains visible and continues counting for at least five minutes after regulation expiry without timer drift visible to the referee.
- **SC-005**: In summary tests with at least 20 events, 100% of events are reachable through physical-button navigation and the newest event is visible on initial summary display.
- **SC-006**: Existing end-match, reset, score, card, conversion, pause/resume, and activity-save flows pass regression tests after these changes.
- **SC-007**: On representative small and large watch screens, the time-up state and summary list remain readable without overlapping critical timer, score, or sanction text.

## Assumptions

- The feature is limited to current-match state and does not add a match-history database.
- Undo applies only to the latest recorded score or card event, not arbitrary older events or non-event match controls.
- Undo is intended for score and card events; match start, pause/resume, period transition, and reset actions are not user-facing undo targets.
- Referee-confirmed time expiry replaces automatic period ending as the desired match behavior.
- Existing activity recording behavior remains responsible for saving or discarding the final activity.
- Physical buttons remain the primary interaction method; touch-only interaction is out of scope.
- Existing rugby variant defaults remain unchanged unless a later feature changes them.

## Security & Privacy Considerations

- Data classification: This feature uses local current-match timing and event data only. It does not add personal data collection.
- Telemetry opt-in: No analytics or external telemetry are added.
- Retention & deletion: Events remain tied to the current match and follow existing save, summary, and reset behavior.
- External communications: No network calls are required.
- Required security tests: Verify undo, summary, and time-up behavior do not expose data from prior matches and do not introduce persistent data beyond existing match handling.
