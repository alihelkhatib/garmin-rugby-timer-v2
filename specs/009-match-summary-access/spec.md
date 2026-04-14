# Feature Specification: Match Summary Access

**Feature Branch**: `009-match-summary-access`  
**Created**: 2026-04-14  
**Status**: Draft  
**Input**: User description: "as a part of this at match end, there should be an option to see the match summary somehow in the menu that ends or resets a match. or perhaps even have the ability to see the event log/event summary at any point in time by using the dialog menu with the back button, would that be a good idea?"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Review Match Summary At Match End (Priority: P1)

As a referee who has just finished a match, I need a clear option to view the match summary from the end/reset flow so I can quickly review the recorded events before leaving the match screen.

**Why this priority**: The end-of-match decision point is the safest time to review the event log because the match is already over or about to be reset.

**Independent Test**: End a match or open the match end/reset menu and verify that a match-summary option appears and opens the summary view with the recorded events.

**Acceptance Scenarios**:

1. **Given** a match is active or completed, **When** the referee opens the menu that offers end/reset actions, **Then** a match-summary option is available.
2. **Given** the end/reset menu is open, **When** the referee selects match summary, **Then** the app shows the recorded match summary or event log.
3. **Given** the summary view is open, **When** the referee exits it, **Then** they return to the end/reset menu or the prior match context without losing the recorded events.

---

### User Story 2 - Preserve Existing End And Reset Actions (Priority: P2)

As a referee, I need the new summary option to stay out of the way of end-match and reset actions so I can still finish the match without confusion.

**Why this priority**: The new summary option should add visibility, not make terminal match controls harder to use.

**Independent Test**: Open the end/reset menu and verify the existing end-match and reset choices still work as before, alongside the new summary choice.

**Acceptance Scenarios**:

1. **Given** the end/reset menu is open, **When** the referee chooses end match, **Then** the current end-match confirmation and save flow still work.
2. **Given** the end/reset menu is open, **When** the referee chooses reset match, **Then** the current reset confirmation and discard flow still work.
3. **Given** the summary option is not chosen, **When** the referee uses the menu, **Then** the existing end/reset actions remain the fastest path to finish the match.

### Edge Cases

- The summary option must not prevent the referee from completing the end-match save flow.
- The summary option must not destroy or clear the recorded event log.
- If the match is reset after viewing the summary, the app should still honor the existing reset confirmation behavior.
- If there are no events recorded, the summary view should still be accessible and clearly indicate an empty summary.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST provide a match-summary option from the end/reset menu or equivalent match-ending menu path.
- **FR-002**: Selecting match summary MUST show the recorded event log or summary for the current match.
- **FR-003**: The summary view MUST preserve the recorded match events when the referee exits it.
- **FR-004**: The end-match and reset actions MUST remain available and continue to behave as they do today.
- **FR-005**: The summary option MUST not require the referee to lose or discard the current match before viewing it.
- **FR-006**: The summary view MUST clearly handle the case where no match events are available.
- **FR-007**: If the design also supports accessing summary from the Back-button dialog during an active or paused match, that access path MUST not interfere with the existing end/reset confirmation flow or primary match controls.

### Key Entities *(include if feature involves data)*

- **Match Summary**: A readable list or view of recorded match events for the current match.
- **End/Reset Menu**: The menu used to finish or discard the current match.
- **Summary Access Path**: The menu or dialog entry point that opens the match summary.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In end-of-match tests, the referee can reach the match summary from the end/reset menu in one menu choice.
- **SC-002**: In summary-access tests, 100% of recorded match events remain visible after the referee opens and exits the summary view.
- **SC-003**: In regression tests, the end-match and reset flows still complete with the same outcomes as before the summary option was added.
- **SC-004**: If the optional Back-button summary access is implemented, testers can reach the summary without breaking the existing active-match back menu behavior.

## Assumptions

- The safest first version is to expose match summary from the end/reset menu rather than making it a mandatory active-match shortcut.
- The current match summary view can be reused instead of inventing a second summary screen.
- If an always-available summary access path is later added, it should be treated as a follow-on refinement rather than required for the initial release.
- No new persistent storage is required.

## Security & Privacy Considerations

- Data classification: Match summary data is local match event information and contains no PII by default.
- Telemetry opt-in: No telemetry or analytics are added.
- Retention & deletion: The summary reflects current match data only and follows the existing discard/save behavior.
- External communications: None.
- Required security tests: Confirm the summary access path does not expose data beyond the current match and does not add external dependencies.
