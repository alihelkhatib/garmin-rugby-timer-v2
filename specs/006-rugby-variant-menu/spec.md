# Feature Specification: Rugby Variant Menu

**Feature Branch**: `006-rugby-variant-menu`  
**Created**: 2026-04-13  
**Status**: Draft  
**Input**: User description: "We do not currently have a way to allow the user to select the other rugby variants from a menu or something. We need to implement this as well."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Select Variant Before Match (Priority: P1)

As a rugby referee, I need to choose a built-in rugby variant from the watch before the match starts so the app uses the correct match, card, and conversion timing defaults without code or settings edits.

**Why this priority**: Variant defaults already exist, but the referee cannot reach them from the app. A pre-match variant menu unlocks existing 15s, 7s, 10s, and U19 behavior.

**Independent Test**: From the pre-match idle screen, open the variant menu, choose each built-in variant, and verify the visible setup timer and later match behavior use that variant's default timing values.

**Acceptance Scenarios**:

1. **Given** the app is on the pre-match idle screen, **When** the referee opens variant selection, **Then** the app shows the available built-in rugby variants: 15s, 7s, 10s, and U19.
2. **Given** the referee is viewing the variant list, **When** they select 7s, **Then** the app applies the 7s defaults and the idle main timer reflects the 7-minute half length.
3. **Given** the referee selects 10s, U19, or 15s before starting, **When** they return to the idle screen, **Then** the displayed timer and subsequent match timers use the selected variant's defaults.
4. **Given** a variant is selected before kickoff, **When** the referee starts the match, **Then** the active match uses the selected variant's half, yellow-card, and conversion timing values.

---

### User Story 2 - Prevent Mid-Match Variant Changes (Priority: P2)

As a referee, I need variant selection to be available only when it is safe to change setup, so a live match cannot accidentally change its timing rules.

**Why this priority**: Changing variants after match timing begins could corrupt countdowns, cards, conversions, scores, or activity recording.

**Independent Test**: Start or pause a match and confirm the variant menu is unavailable or selection is ignored; then reset to pre-match and confirm the menu is available again.

**Acceptance Scenarios**:

1. **Given** a match is running or paused, **When** the referee attempts to open or use variant selection, **Then** the current match variant and timers remain unchanged.
2. **Given** the match has ended or been reset to the pre-match state, **When** the referee returns to setup, **Then** variant selection is available before the next match begins.
3. **Given** the referee opens variant selection accidentally before kickoff, **When** they cancel or go back, **Then** the previously selected variant remains unchanged.

---

### User Story 3 - Preserve Variant Choice During Pre-Match Adjustments (Priority: P3)

As a referee, I need the selected variant and any pre-match timer adjustments to behave predictably together, so I can pick a variant and still make supported setup tweaks.

**Why this priority**: The existing idle timer adjustment flow should continue to work after variant selection is added.

**Independent Test**: Select a variant, adjust the idle main timer within the existing bounds, and verify the adjusted value starts the match while the rest of the selected variant defaults remain intact.

**Acceptance Scenarios**:

1. **Given** the referee selects a built-in variant before kickoff, **When** they adjust the idle main timer, **Then** the app keeps the selected variant context and applies the adjusted half length within existing bounds.
2. **Given** the referee selects a different built-in variant after making a pre-match timer adjustment, **When** the new variant is applied, **Then** the setup resets to that variant's default timing values.

### Edge Cases

- Opening the variant menu while the match is running, paused, half-ended, or match-ended must not mutate active match state.
- Selecting a variant must clear previous pre-match custom half-length adjustments and load the selected preset defaults.
- Canceling the variant menu must leave the current selected/default variant unchanged.
- Selecting a variant must not affect current scores, event logs, cards, conversion timers, or activity recording because it is available only before a match starts.
- Variant labels must remain readable on small round watch screens.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST provide an in-app pre-match way to select a rugby variant.
- **FR-002**: The variant selection UI MUST include the built-in variants already supported by the app: 15s, 7s, 10s, and U19.
- **FR-003**: Selecting a built-in variant before kickoff MUST apply that variant's default half length, half count, yellow-card duration, and conversion duration.
- **FR-004**: The selected variant MUST be reflected on the pre-match display or setup state so the referee can tell which variant is active before starting.
- **FR-005**: The app MUST prevent variant changes from mutating a running, paused, half-ended, or completed match.
- **FR-006**: Canceling or backing out of variant selection MUST leave the previously selected variant unchanged.
- **FR-007**: Selecting a new built-in variant after an idle pre-match timer adjustment MUST reset setup timing to the selected variant defaults.
- **FR-008**: Existing pre-match Up/Menu and Down timer adjustment behavior MUST continue to work after a variant is selected.
- **FR-009**: Variant selection MUST preserve existing score, card, conversion, haptic, event-log, Back option, and activity-recording behavior outside the pre-match setup flow.
- **FR-010**: Variant selection UI MUST use watch-scale menu/resource patterns where feasible, with no network dependency or external configuration required.
- **FR-DIAG-001**: Cross-cutting diagnostics requirement (see specs/cross-cutting/diagnostics.md). The feature MUST emit the following feature-specific traces: variant_open, variant_select, variant_cancel, variant_select_blocked. Document each trace payload schema below in the Diagnostics section.

### Key Entities *(include if feature involves data)*

- **Rugby Variant**: A built-in match preset with display label, half length, half count, yellow-card duration, and conversion duration.
- **Variant Selection Flow**: A pre-match interaction that changes the current setup to a chosen built-in variant or cancels without mutation.
- **Match Setup State**: The currently selected variant and timing values used when the match starts.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In pre-match tests, a referee can select each built-in variant and see the correct default half length reflected before starting the match.
- **SC-002**: In match-start tests for 15s, 7s, 10s, and U19, 100% of selected variants start with the expected half, yellow-card, and conversion durations.
- **SC-003**: In active-match guard tests, 100% of attempts to change variants while running, paused, half-ended, or match-ended leave the active match setup unchanged.
- **SC-004**: Existing idle timer adjustment tests continue to pass after variant selection is added.
- **SC-005**: On representative small and large watch profiles, the variant menu labels are readable and selectable without truncating the available built-in variant choices.

## Assumptions

- The built-in variants for this feature are the existing app presets: 15s, 7s, 10s, and U19.
- Variant selection is pre-match only because mid-match changes would risk corrupting timers and activity data.
- Persisting the last selected variant across app restarts is out of scope unless existing preference storage is already available and safe to reuse.
- Custom variant editing beyond the existing idle timer adjustment flow is out of scope for this feature.
- The existing Up/Menu and Down idle timer adjustment controls remain available for half-length tweaks before kickoff.

## Security & Privacy Considerations

- Data classification: Variant selection is local match setup data and contains no PII.
- Telemetry opt-in: No telemetry, analytics, or network calls are added.
- Retention & deletion: No new persistent storage is required; selected setup is cleared or replaced by normal setup/reset behavior.
- External communications: None.
- Required security tests: Confirm variant selection does not transmit data, does not introduce external dependencies, and cannot mutate active match activity data mid-match.
