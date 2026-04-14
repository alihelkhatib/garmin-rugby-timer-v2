# Feature Specification: Center Prompts for Round Screens

**Feature Branch**: `008-centered-prompts`  
**Created**: 2026-04-14  
**Status**: Draft  
**Input**: User description: "we need to move any of the prompts or dialog that appears at the bottom of the screen to maybe also the center portion. if you think that is the best move. Right now they seem slightly cut off on the circle screen of the watch even if the square."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Keep Prompts Fully Visible On Round Screens (Priority: P1)

As a referee using a circular watch screen, I need prompts and dialogs that were previously placed at the bottom of the screen to appear in a centered, readable area so that no important text is clipped.

**Why this priority**: The current bottom placement can cut off text on circular displays, which makes dialogs harder to read and can block match actions.

**Independent Test**: Open each prompt or dialog used during match control on a round watch profile and verify the full text and controls are visible without clipping.

**Acceptance Scenarios**:

1. **Given** a circular watch profile, **When** the referee opens a prompt or dialog that previously appeared near the bottom edge, **Then** the full content is visible within the screen bounds.
2. **Given** a circular watch profile, **When** the referee views the same prompt or dialog, **Then** the content is placed in a centered area if bottom placement would clip text or controls.
3. **Given** a square watch profile, **When** the referee opens the same prompt or dialog, **Then** the content remains readable and does not become less usable than before.

---

### User Story 2 - Preserve Existing Dialog Flow (Priority: P2)

As a referee, I need the existing prompts and dialogs to keep their current meaning and sequence while only improving their placement.

**Why this priority**: This change should fix readability without changing match actions or adding new steps.

**Independent Test**: Exercise each affected prompt or dialog and verify the same choices, ordering, and match-state behavior remain available after the placement adjustment.

**Acceptance Scenarios**:

1. **Given** an affected prompt or dialog is opened, **When** the referee makes a selection, **Then** the same action occurs as before the placement change.
2. **Given** the referee backs out of a prompt or dialog, **When** they return to the previous screen, **Then** the same prior state is preserved.

### Edge Cases

- Dialogs that are already fully visible at the bottom should not be moved unnecessarily.
- Center placement must still leave enough room for longer labels and action text.
- If a prompt is opened during active match control, it must remain readable without obscuring the core timer information more than necessary.
- Round-screen placement should not create clipping on small watch faces.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST keep prompts and dialogs fully visible within the screen bounds on circular watch profiles.
- **FR-002**: The app MUST move a prompt or dialog to a more central visible area when bottom placement would clip text or controls.
- **FR-003**: The app MUST preserve the existing prompt sequence, choices, and resulting match behavior when placement changes.
- **FR-004**: The app MUST keep prompts and dialogs readable on square watch profiles.
- **FR-005**: The app MUST avoid obscuring the primary match timer and score information more than necessary when a prompt or dialog is shown.
- **FR-006**: The app MUST apply the visibility fix consistently to every affected bottom-screen prompt or dialog used during match control.

### Key Entities *(include if feature involves data)*

- **Prompt/Dialog Placement**: The on-screen location used to present a match-control prompt or dialog.
- **Watch Screen Shape**: The display shape that affects whether bottom placement clips content.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On representative circular watch profiles, 100% of affected prompts and dialogs appear fully within view with no clipped text or controls.
- **SC-002**: On representative square watch profiles, affected prompts and dialogs remain fully readable and retain the same actions as before.
- **SC-003**: In repeated prompt/dialog tests, users can complete the same choice flow without any additional navigation steps introduced by the placement change.
- **SC-004**: Reviewers can verify the fix on both round and square profiles without finding clipped prompt text in the affected match-control paths.

## Assumptions

- The issue is caused by bottom-placed prompts and dialogs not fitting cleanly on circular watch screens.
- The safest fix is to shift only the affected prompts/dialogs toward the center rather than redesigning every screen.
- The app already has the existing prompt and dialog flows; this feature is limited to placement and readability.
- No new persistent settings are required.

## Security & Privacy Considerations

- Data classification: This feature only changes local UI placement and does not collect new data.
- Telemetry opt-in: No telemetry or analytics are added.
- Retention & deletion: No new storage is introduced.
- External communications: None.
- Required security tests: Confirm the change does not add external dependencies or transmit any user data.
