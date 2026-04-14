# Feature Specification: Auto Period Transition

**Feature Branch**: `007-auto-period-transition`  
**Created**: 2026-04-13  
**Status**: Draft  
**Input**: User description: "Currently, when the countdown timer runs out it does not automatically end the half or end the match depending on if it is the final period. Make this the behavior. Additionally, if there are card timers that have not expired by the time we reach the end of a period, they are to pause and that timer will be present for the next period. Ask me about any ambiguities"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Auto-End Non-Final Period (Priority: P1)

As a referee, I need the app to automatically end the current non-final period when the main countdown reaches zero so I do not have to take a separate action at the exact end of time.

**Why this priority**: The requested behavior corrects the core match timing lifecycle. If a half expires but remains running, the referee can lose trust in all visible match state.

**Independent Test**: Start a match in a variant with another period remaining, let the main countdown reach 00:00, and confirm the app leaves active play timing and enters the between-period state without a manual end-period action.

**Acceptance Scenarios**:

1. **Given** a match is in a non-final period and the main countdown is running, **When** the countdown reaches 00:00, **Then** the app automatically ends the current period.
2. **Given** the current period automatically ends, **When** the referee views the app, **Then** the app shows the normal between-period flow for starting the next period.
3. **Given** the current period automatically ends, **When** the referee starts the next period through the existing start-next-period flow, **Then** the next period begins with the correct period number and match timing state.

---

### User Story 2 - Auto-End Final Period And Match (Priority: P1)

As a referee, I need the app to automatically end the match when the final period countdown reaches zero so the match cannot keep running after full time has expired.

**Why this priority**: Final-period expiry is the critical match completion boundary and must transition to the same match-ended experience as a deliberate end-match action.

**Independent Test**: Start the final configured period, let the main countdown reach 00:00, and confirm the app enters the match-ended summary/save flow without a manual end-match action.

**Acceptance Scenarios**:

1. **Given** a match is in its final configured period and the main countdown is running, **When** the countdown reaches 00:00, **Then** the app automatically ends the match.
2. **Given** the match automatically ends from the final period, **When** the referee views the app, **Then** the normal match-ended summary and save behavior is available.
3. **Given** the match automatically ends from the final period, **When** the referee reviews scores, events, cards, or activity-save state, **Then** they match the state at the moment the countdown reached 00:00.

---

### User Story 3 - Carry Active Card Timers Into Next Period (Priority: P1)

As a referee, I need unexpired yellow card timers to pause at the end of a period and remain available in the next period so sanctions continue with the correct remaining time.

**Why this priority**: Card timer continuity affects live sanction management and is directly tied to period expiry behavior.

**Independent Test**: Create one or more yellow card timers near the end of a non-final period, let the main countdown reach 00:00, verify the card timers pause and remain visible or tracked during the period break, then start the next period and verify they resume from the preserved remaining time.

**Acceptance Scenarios**:

1. **Given** one or more yellow card timers are active when a non-final period countdown reaches 00:00, **When** the app automatically ends the period, **Then** each unexpired yellow card timer pauses with its remaining time preserved.
2. **Given** an unexpired yellow card timer was paused at period end, **When** the referee starts the next period, **Then** the timer is present for that period and resumes from the preserved remaining time.
3. **Given** multiple yellow card timers are active for either team at period end, **When** the next period starts, **Then** each timer keeps its assigned team and remaining time.
4. **Given** a yellow card timer reaches 00:00 before the period ends, **When** the period later ends, **Then** the already expired timer is not revived for the next period.

### Edge Cases

- A countdown reaches 00:00 while match time is running: the app must transition once and must not require a manual end-period or end-match action.
- A countdown is already paused at or near 00:00: automatic transition is tied to time advancing to 00:00, and paused time must not unexpectedly end the period until match timing resumes or an explicit end action is used.
- The final configured period reaches 00:00: the match ends rather than entering another between-period state.
- Multiple period lengths or variant defaults are used: the app must use the selected match setup to determine whether the expired period is final.
- One or more yellow card timers have remaining time at a non-final period boundary: they pause, keep their team assignment and remaining duration, and resume in the next period.
- A yellow card timer expires on the same update as the main countdown reaches 00:00: the app must apply the expiry once and must not carry the expired timer into the next period.
- A red card is active at period end: it remains recorded according to existing red-card behavior, but no countdown pause/resume is required.
- A conversion timer is active when the main countdown reaches 00:00: existing conversion-timer behavior must be preserved unless a separate specification changes it.
- Activity recording or match-end summary is unavailable on a target device: automatic final-period expiry must still produce the existing in-app match-ended fallback behavior.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When the main match countdown reaches 00:00 during a running non-final period, the app MUST automatically end the current period.
- **FR-002**: Automatic period-end behavior MUST use the selected match setup to decide whether another period remains.
- **FR-003**: When the main match countdown reaches 00:00 during the final configured period, the app MUST automatically end the match.
- **FR-004**: Automatic match-end behavior MUST enter the same user-facing match-ended summary/save flow used by the existing deliberate end-match path.
- **FR-005**: Automatic non-final period-end behavior MUST enter the same user-facing between-period flow used by the existing deliberate end-period path.
- **FR-006**: Automatic period or match transition MUST occur at most once for a given countdown expiry event.
- **FR-007**: Automatic period or match transition MUST NOT occur merely because the countdown is paused at 00:00 or below; it MUST occur when active match timing advances the countdown to 00:00, or when the referee explicitly uses the existing end action.
- **FR-008**: Any unexpired yellow card timer at a non-final period end MUST pause with its remaining time preserved.
- **FR-009**: Any yellow card timer paused at a non-final period end MUST be present in the next period with the same team assignment and remaining time.
- **FR-010**: Yellow card timers carried into the next period MUST resume when the next period's match time starts.
- **FR-011**: Yellow card timers that expired before or at the same time as the period-end transition MUST NOT be carried into the next period as active timers.
- **FR-012**: Red card indicators and records MUST preserve existing period-end and match-end behavior; this feature MUST NOT add a red-card countdown.
- **FR-013**: Existing scoring, card entry, conversion timer, pause/resume, haptic alert, event log, variant selection, and activity-recording behavior MUST be preserved except where directly affected by automatic countdown expiry.
- **FR-014**: Period-end and match-end displays MUST remain readable on supported watch screen sizes after automatic transitions, including when one or more card timers are carried forward.
- **FR-015**: Automatic final-period match end MUST preserve the current score, period state, card state, event log, and activity-save state as of the countdown expiry.

### Key Entities

- **Match Period State**: Represents the current period number, whether the period is final for the selected match setup, and whether play timing is running, paused, between periods, or match-ended.
- **Main Countdown**: The referee-facing period timer whose expiry determines automatic period or match transition.
- **Yellow Card Timer**: A team-assigned sanction countdown with active, paused, expired, cleared, and carried-forward states.
- **Between-Period Flow**: The user-facing state shown after a non-final period ends and before the next period starts.
- **Match-End Summary**: The user-facing state shown after the final period ends, including score and existing save/review behavior.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In 10 non-final period expiry tests, 100% of runs automatically leave active play timing and enter the between-period flow within one visible update after the main countdown reaches 00:00.
- **SC-002**: In 10 final-period expiry tests, 100% of runs automatically enter the match-ended summary/save flow within one visible update after the main countdown reaches 00:00.
- **SC-003**: In 10 tests with an unexpired yellow card timer at a non-final period boundary, 100% of timers preserve the same team assignment and remaining time through the break and resume when the next period starts.
- **SC-004**: In tests with multiple simultaneous yellow card timers across both teams, 100% of unexpired timers are carried into the next period and 100% of expired timers are not revived.
- **SC-005**: In paused-at-00:00 tests, 100% of runs avoid unexpected automatic period or match transition until timing resumes to the expiry boundary or the referee explicitly ends the period or match.
- **SC-006**: Regression validation confirms existing scoring, card entry, conversion timer, pause/resume, haptic alert, event log, variant selection, display, and activity-recording behaviors still pass after the automatic transition change.
- **SC-007**: On representative supported watch screen sizes, automatic transition states remain readable with no overlap between period status, score, and carried yellow card timers.

## Assumptions

- "Final period" means the last period defined by the selected match setup or variant.
- "Card timers" refers to yellow card countdown timers; red cards remain non-countdown sanctions under existing behavior.
- Unexpired yellow card timers carry forward only across non-final period boundaries. At final match end there is no next period, so active timers stop as part of the match-ended state.
- The existing between-period and match-ended flows remain the user-facing destination for automatic transitions.
- Conversion timer behavior at period end remains governed by existing behavior and is not changed by this feature.
- No new match-history persistence, network communication, analytics, or account behavior is added by this feature.

## Security & Privacy Considerations

- Data classification: This feature changes local match timing state only. It does not introduce personal data.
- Telemetry opt-in: No telemetry or analytics collection is added.
- Retention & deletion: Carried yellow card timer state is retained only as part of the current match and follows existing reset, match-end, and new-match cleanup behavior.
- External communications: No network communication is required.
- Required security tests: Release validation should confirm the change does not add external data exchange, new persisted personal data, or new dependencies.
