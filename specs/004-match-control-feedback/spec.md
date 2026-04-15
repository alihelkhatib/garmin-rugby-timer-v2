# Feature Specification: Match Control Feedback

**Feature Branch**: `004-match-control-feedback`  
**Created**: 2026-04-13  
**Status**: Draft  
**Input**: User description: "Increment and decrement now work, but Select/Start does not vibrate when starting the match; timers only appear to update after pressing Select again to pause; yellow card display shows only `Y ` instead of `Y#`; after choosing Home/Away from the score menu the next menu opens an Away Card dialog instead of the score-type dialog; add extensive diagnostics so the issue location is clear."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start Match With Feedback And Live Timers (Priority: P1)

As a rugby referee, I need Select/Start to clearly begin the match, give immediate tactile confirmation, and keep the visible timers moving without requiring another button press.

**Why this priority**: Match start and timer continuity are core to refereeing the match; if the start is ambiguous or timers do not visibly advance, the app cannot be trusted during play.

**Independent Test**: Start a match from the idle screen and verify tactile start feedback plus visible timer movement within the first few seconds, without pressing pause.

**Acceptance Scenarios**:

1. **Given** the app is idle before kickoff, **When** the referee presses Select/Start, **Then** the app starts the match, gives a start confirmation vibration when haptics are available, and marks the match as running.
2. **Given** a match has just started, **When** the referee watches the timer for several seconds without pressing another button, **Then** the visible elapsed and countdown timers continue updating.
3. **Given** haptics are not available on a device or profile, **When** the referee starts the match, **Then** the match still starts and the app records diagnostic context explaining why tactile feedback was not delivered.

---

### User Story 2 - Show Yellow Card Identity Clearly (Priority: P2)

As a referee, I need each active yellow card display to include the yellow-card identifier so I can distinguish the sanction being tracked.

**Why this priority**: Showing only `Y ` is ambiguous and makes it hard to connect a visible sanction timer to the card event that created it.

**Independent Test**: Issue a yellow card to either team and verify the card area displays a yellow-card label with its identifier and remaining timer information.

**Acceptance Scenarios**:

1. **Given** a match is running, **When** the referee issues a yellow card to a team, **Then** that team's card area shows a yellow-card label with the card identifier and readable timer information.
2. **Given** multiple yellow cards are issued over time, **When** the referee views active sanctions, **Then** each visible yellow-card label can be distinguished by identifier.

---

### User Story 3 - Route Score Menus Correctly (Priority: P2)

As a referee recording points, I need the score menu to continue into score-type choices after selecting Home or Away, not jump into a card dialog.

**Why this priority**: Score entry is a high-frequency match action, and incorrect dialog routing can lead to missed or delayed scoring.

**Independent Test**: Open the score menu during an active match, select Home and Away in separate runs, and verify each path opens score-type choices for the chosen team.

**Acceptance Scenarios**:

1. **Given** the match is running, **When** the referee opens the score menu and selects Home, **Then** the next menu offers score types for Home.
2. **Given** the match is running, **When** the referee opens the score menu and selects Away, **Then** the next menu offers score types for Away.
3. **Given** the match is running, **When** the referee opens card controls, **Then** card routing remains separate and still leads to card-team and card-type choices.

---

### User Story 4 - Trace Match Control Decisions (Priority: P3)

As a tester or maintainer, I need the app to emit clear diagnostic traces for match control flows so device-only regressions can be localized quickly.

**Why this priority**: Several failures only appeared on-device; diagnostic traces reduce the time needed to distinguish input routing, state transitions, rendering, haptics, and menu selection issues.

**Independent Test**: Exercise match start, pause, score menu routing, card menu routing, and yellow-card display while reviewing diagnostics for the expected decision points and outcomes.

**Acceptance Scenarios**:

1. **Given** a referee starts or pauses the match, **When** diagnostics are reviewed, **Then** they identify the input action, prior state, resulting state, recorder/haptic outcome, and update scheduling outcome.
2. **Given** a referee navigates score or card menus, **When** diagnostics are reviewed, **Then** they identify the originating menu action, selected team, selected action family, and destination menu.
3. **Given** a yellow card is issued and rendered, **When** diagnostics are reviewed, **Then** they identify the card event, team, identifier, remaining time, and displayed label.

### Edge Cases

- Starting a match with haptics unavailable must not block match start.
- Running timer updates must continue when no new button input occurs.
- Pausing after match start must preserve elapsed time and still stop visible timer movement while paused.
- Yellow-card labels must remain readable when the remaining timer reaches single-digit minutes or seconds.
- Score and card menus must remain separate for Home and Away selections.
- Diagnostics must be useful without exposing personally identifiable information or requiring external services.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST start the match from the idle screen when the referee presses Select/Start.
- **FR-002**: The system MUST provide immediate tactile confirmation for match start when the device supports tactile alerts.
- **FR-003**: The system MUST continue visible elapsed and countdown timer updates during a running match without requiring further button input.
- **FR-004**: The system MUST preserve pause behavior so pressing Select/Start during a running match pauses visible timer progression at the correct elapsed value.
- **FR-005**: The system MUST display each active yellow card with a yellow-card identifier and readable timer information rather than an empty or partial label.
- **FR-006**: The system MUST route score-team selections to score-type choices for the selected team.
- **FR-007**: The system MUST route card-team selections to card-type choices for the selected team, without interfering with score routing.
- **FR-008**: The system MUST keep score controls available only in active match states and unavailable before kickoff or after match end.
- **FR-DIAG-001**: Cross-cutting diagnostics requirement (see specs/cross-cutting/diagnostics.md). The feature MUST emit the following feature-specific traces (examples): match_start, match_pause, timer_update, score_menu_routing, card_menu_routing, yellow_card_created, yellow_card_displayed. Feature-specific trace names and payload schemas MUST be documented in this spec's "Diagnostics" section.
- **FR-010**: Diagnostic traces MUST include enough context to distinguish input handling, state transition, haptic feedback, timer refresh, menu routing, and rendering outcomes.
- **FR-011**: Diagnostic traces MUST avoid collecting or transmitting personally identifiable information.

### Key Entities

- **Match Control Action**: A referee input such as start, pause, score menu, card menu, or team selection, with its prior and resulting match state.
- **Visible Timer State**: The displayed elapsed and countdown values, including whether they are actively refreshing while the match is running.
- **Yellow Card Display**: The visible sanction label and timer details for a team-specific yellow-card event.
- **Menu Routing Decision**: The selected team, action family, and next menu shown to the referee.
- **Diagnostic Trace Event**: A local diagnostic record describing the action, decision point, result, and relevant non-PII context.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In 10 consecutive idle-to-running starts, the match starts on the first Select/Start press and provides tactile confirmation on haptic-capable devices.
- **SC-002**: During a 30-second running-match observation, the visible elapsed and countdown timers update without additional button presses.
- **SC-003**: In Home and Away score-entry tests, 100% of score-team selections open score-type choices for the selected team.
- **SC-004**: In Home and Away card-entry tests, 100% of card-team selections open card-type choices for the selected team.
- **SC-005**: In yellow-card tests for both teams, 100% of active yellow-card displays include a visible identifier and timer information.
- **SC-006**: For each primary flow in this feature, diagnostics identify the action path and outcome in a way that lets a tester classify the failure stage within one reproduction attempt.

## Assumptions

- The app continues to target the existing supported Garmin watch profiles and uses local device behavior only.
- Start vibration means a short confirmation alert distinct enough for a referee to notice at kickoff.
- If a profile cannot vibrate, diagnostics are sufficient and the match should still start normally.
- Yellow-card identifier refers to the existing sanction/card identifier assigned by the match state.
- Score and card menus already exist; this feature corrects routing between those existing flows rather than introducing new scoring types or card types.
- No network telemetry or remote analytics are added for diagnostics.

## Security & Privacy Considerations

- Data classification: Diagnostics contain local app control-flow details such as action names, match state names, team side labels, timer values, and sanction identifiers; they do not contain PII.
- Telemetry opt-in: No telemetry or analytics collection is added; diagnostics remain local to the app/device debugging flow.
- Retention & deletion: Diagnostics follow the app's existing local runtime log behavior and are not persisted by this feature.
- External communications: No network calls or external services are required.
- Required security tests: Confirm diagnostics do not include personal names beyond existing generic side labels and do not introduce external data transmission.
