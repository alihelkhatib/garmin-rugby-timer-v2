# Feature Specification: idle-timer-controls

**Feature Branch**: `003-idle-timer-controls`  
**Created**: 2026-04-13  
**Status**: Draft  
**Input**: User description: "This application still lacks the ability to increment the main timer on the idle screen by using the Up/Menu and Down physical buttons. Currently, the Up/Menu button still goes to the score dialog menu even though a match has not started. This application shall only have the score menu dialog if a match is active. The application shall have the ability to increment or decrement the main timer on the idle screen before a match has begun."

## Clarifications

### Session 2026-04-13

- Q: What upper bound should idle main-timer increases use? -> A: Clamp between 00:00 and the selected variant's normal half length.
- Q: Which match states count as active for score-dialog availability? -> A: Running, paused, and half-ended states count as active.
- Q: What security validation posture should this feature use? -> A: Lightweight security checklist and owner sign-off.
- Q: What performance budget posture should this feature use? -> A: No regression against existing budgets.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Adjust Main Timer Before Kickoff (Priority: P1)

A referee is preparing for a match and wants to change the visible main timer directly from the idle screen before the match has started. While the app is idle, the referee can press Up/Menu to increase the main timer and Down to decrease it without entering a separate dialog.

**Why this priority**: This is the primary requested behavior and makes pre-match setup possible from the physical controls available during a match-day workflow.

**Independent Test**: Start from the idle screen with no active match, press Up/Menu and Down, and confirm the main timer changes by the expected step while the match remains unstarted.

**Acceptance Scenarios**:

1. **Given** the app is on the idle screen with no active match and the main timer is below the selected variant's normal half length, **When** the referee presses Up/Menu once, **Then** the main timer increases by 1 minute and the updated value is visible.
2. **Given** the app is on the idle screen with no active match and the main timer is above 00:00, **When** the referee presses Down once, **Then** the main timer decreases by 1 minute and the updated value is visible.
3. **Given** the app is on the idle screen with no active match and the main timer is 00:00, **When** the referee presses Down, **Then** the main timer remains at 00:00.
4. **Given** the app is on the idle screen with no active match and the main timer is at the selected variant's normal half length, **When** the referee presses Up/Menu, **Then** the main timer remains at the selected variant's normal half length.
5. **Given** the referee has adjusted the idle main timer, **When** the referee starts the match, **Then** the match begins from the adjusted timer value.

---

### User Story 2 - Block Score Menu While Idle (Priority: P1)

A referee is preparing for a match and presses Up/Menu while no match is active. The app must not open the score dialog because there is no active match to score.

**Why this priority**: This prevents the current incorrect behavior where the score dialog appears before a match has started.

**Independent Test**: Start from the idle screen with no active match, press the physical controls that could previously reach the score dialog, and confirm no score dialog appears.

**Acceptance Scenarios**:

1. **Given** the app is on the idle screen with no active match, **When** the referee presses Up/Menu, **Then** the score dialog does not open and the main timer increases instead.
2. **Given** the app is on the idle screen with no active match, **When** the referee uses any physical-button path that would normally open the score dialog during a match, **Then** the score dialog remains unavailable.

---

### User Story 3 - Preserve In-Match Score Controls (Priority: P2)

A referee starts a match and uses the normal in-match controls. Once the match is active (running, paused, or half-ended), the score dialog is available only in that active match state and existing in-match scoring workflows continue to work.

**Why this priority**: The idle-screen fix must not regress the match-day scoring flow once a match is underway.

**Independent Test**: Start a match, open the score dialog through the expected physical control path, and confirm scoring can still be performed during active match play.

**Acceptance Scenarios**:

1. **Given** a match is running, paused, or half-ended, **When** the referee presses the expected score-menu control, **Then** the score dialog opens.
2. **Given** a match is running, paused, or half-ended and the score dialog is open, **When** the referee performs an existing scoring action, **Then** the score changes according to the existing scoring rules.
3. **Given** a match has ended or returned to idle, **When** the referee presses Up/Menu, **Then** the app follows the idle timer-adjustment behavior and does not open the score dialog.

### Edge Cases

- Rapid repeated Up/Menu presses on the idle screen should increase the main timer predictably without skipped or duplicated increments.
- Rapid repeated Down presses on the idle screen should decrease the main timer predictably without crossing below 00:00.
- Idle main-timer increases must stop at the selected variant's normal half length.
- Long-press or held-button behavior must not open the score dialog while no match is active.
- If the referee changes match variant or default match length before starting, the idle timer must still clearly reflect the timer value that will be used when the match starts.
- If the app is paused, backgrounded, or reopened before the match starts, the timer value used at match start must match the app's documented idle-timer persistence behavior.
- Display updates must remain readable on supported watch screen sizes after each timer adjustment.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: While no match is active, the app MUST treat the Up/Menu physical button as an idle main-timer increment control.
- **FR-002**: While no match is active, each Up/Menu press MUST increase the main displayed timer by exactly 1 minute unless the timer is already at the selected variant's normal half length.
- **FR-003**: While no match is active, the app MUST treat the Down physical button as an idle main-timer decrement control.
- **FR-004**: While no match is active, each Down press MUST decrease the main displayed timer by exactly 1 minute unless the timer is already at 00:00.
- **FR-005**: The idle main timer MUST NOT be allowed to display or start a match from a negative time value.
- **FR-006**: The idle main timer MUST NOT be allowed to display or start a match from a value above the selected variant's normal half length.
- **FR-007**: While no match is active, the score dialog MUST NOT be accessible through Up/Menu, Down, or any other physical-button path.
- **FR-008**: When a match is running, paused, or half-ended, the score dialog MUST be available through the existing in-match scoring workflow.
- **FR-009**: Starting a match after idle-screen timer adjustments MUST use the adjusted main timer value as the match's starting timer value.
- **FR-010**: Returning from an active match state to an idle state MUST restore the idle button behavior: Up/Menu adjusts the timer and the score dialog is unavailable.
- **FR-011**: Visible timer updates after idle adjustments MUST be quick enough that the referee can confirm each button press without waiting or navigating away.
- **FR-012**: The idle timer value, static text, and button-driven state changes MUST remain visually stable and readable on supported watch screen sizes.
- **FR-013**: This feature MUST preserve existing scoring, variant selection, match-start, match-stop, haptic alert, and activity-recording behavior except where those behaviors depend directly on the corrected idle-versus-active match state.

### Key Entities

- **Match State**: Represents whether the app is idle, running, paused, half-ended, or match-ended. Running, paused, and half-ended are active match states for score-dialog availability.
- **Main Timer Value**: The visible timer value prepared before a match and used as the starting timer when the match begins.
- **Score Dialog Availability**: Represents whether scoring controls may be opened. Availability is limited to running, paused, and half-ended match states.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In 10 consecutive idle-screen trials below the selected variant's normal half length, pressing Up/Menu increases the visible main timer by exactly 1 minute every time and never opens the score dialog.
- **SC-002**: In 10 consecutive idle-screen trials, pressing Down decreases the visible main timer by exactly 1 minute when above 00:00 and never decreases the timer below 00:00.
- **SC-003**: In 10 consecutive idle-screen trials at the selected variant's normal half length, pressing Up/Menu leaves the visible main timer unchanged and never opens the score dialog.
- **SC-004**: Across representative supported watch screen sizes, the updated idle timer value is visible and readable after each adjustment in all tested cases.
- **SC-005**: In 10 consecutive match-start trials after idle timer adjustment, the match starts from the adjusted main timer value every time.
- **SC-006**: In active-match regression testing, the score dialog remains available in 100% of tested running, paused, and half-ended scoring flows.
- **SC-007**: No existing timer, scoring, variant, alert, or activity-recording acceptance test fails due to the idle-screen button routing change.
- **SC-008**: Device and simulator smoke validation records no regression against existing binary size, memory, CPU, or battery budgets for supported watch profiles.

## Assumptions

- The adjustment step is 1 minute per button press.
- Idle timer adjustments apply to the next match start and do not change saved variant defaults unless a separate settings workflow explicitly does so.
- The score dialog is meaningful only while a match is running, paused, or half-ended and should be unavailable before kickoff or after returning to idle.
- The existing idle screen layout remains the primary location for the adjusted timer value; no separate setup dialog is required for this feature.
- If idle timer persistence across app restarts is already defined elsewhere, this feature follows that existing behavior. If it is not defined, persistence across app restarts is out of scope for this feature.
- Supported physical button mappings may vary by device, but the user-facing rule is consistent: idle controls adjust the main timer, and active-match controls allow scoring.

## Security & Privacy Considerations

- Data classification: This feature changes local match-preparation state only. It does not introduce personally identifiable information.
- Telemetry opt-in: This feature does not require telemetry or analytics collection.
- Retention & deletion: Idle timer adjustments are local match-preparation values and follow the app's existing retention behavior for timer state and match settings.
- External communications: This feature does not require network communication.
- Required security tests: No new security-sensitive surface is introduced; release validation should confirm the change does not add external data exchange or new persisted personal data.
- Security checklist: Before implementation is accepted, the feature owner must record static analysis/build check results, dependency/CVE review status with "no new dependencies" if unchanged, a threat-model note confirming local-only/no PII/no network behavior, and owner sign-off.
