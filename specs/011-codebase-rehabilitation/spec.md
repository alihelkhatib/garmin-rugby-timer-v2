# Feature Specification: Codebase Rehabilitation

**Feature Branch**: `011-codebase-rehabilitation`  
**Created**: 2026-09-19  
**Status**: Draft  
**Input**: User description: "Audit and repair the Garmin Rugby Timer V2 repository comprehensively, preserving intentional functionality while leaving a maintainable, deterministic, production-quality application with tests and accurate documentation."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Referee Runs a Reliable Match (Priority: P1)

A referee can configure, start, pause, resume, advance, complete, and reset a rugby match while every visible timer and match state remains correct even when updates are delayed or the application is interrupted.

**Why this priority**: Accurate match timing and explicit state transitions are the application's safety-critical core.

**Independent Test**: Exercise a complete match with controlled timestamps, including delayed updates, and verify every transition and displayed duration against the authoritative elapsed time.

**Acceptance Scenarios**:

1. **Given** a new match with a selected variant, **When** the referee starts, pauses, resumes, and reaches the period boundary, **Then** elapsed and remaining time are derived from timestamps and the match enters the correct next state exactly once.
2. **Given** an update callback is delayed or the application temporarily stops refreshing, **When** the next state evaluation occurs, **Then** the timer catches up without drift or duplicate transitions.
3. **Given** a match is paused, between periods, or complete, **When** an invalid transition is requested, **Then** the request is rejected without corrupting scores, timers, sanctions, or recording state.

---

### User Story 2 - Referee Records Match Events Safely (Priority: P1)

A referee can record and correct scores, conversions, yellow cards, and red cards without accidental duplicate actions, conflicting timers, or loss of the match summary.

**Why this priority**: Event accuracy directly affects the match result and post-match record.

**Independent Test**: Record each supported event in every allowed match state, repeat rapid inputs, cross a period boundary with active timers, and verify scores, sanctions, alerts, and summary entries.

**Acceptance Scenarios**:

1. **Given** a running or paused match, **When** a valid event is recorded, **Then** the score or sanction changes once and the event appears once in the match summary.
2. **Given** an active conversion or yellow-card timer, **When** match-clock state changes or callbacks are delayed, **Then** the auxiliary timer follows its documented clock basis and expires once.
3. **Given** rapid repeated or conflicting input, **When** the application processes the actions, **Then** destructive operations require deliberate confirmation and duplicate navigation or timer creation does not occur.
4. **Given** a match activity is recording, **When** the referee moves on the field, **Then** Garmin GPS samples, route, and elapsed distance are captured in the FIT activity for Garmin Connect without adding mileage text to the match UI.
5. **Given** GPS is acquiring or unavailable, **When** the match starts or continues, **Then** match timing, scoring, and navigation remain usable.

---

### User Story 3 - Referee Uses a Clear Watch Interface (Priority: P2)

A referee can read the clock, score, period, status, and active sanctions at a glance and can predict what each hardware or touch action will do across supported watch shapes and sizes.

**Why this priority**: Match operation happens under time pressure on small displays and must minimize errors.

**Independent Test**: Run the primary flows on representative compact round, large round, and rectangular profiles and verify layout, navigation, prompts, and visual hierarchy.

**Acceptance Scenarios**:

1. **Given** any supported match state, **When** the main screen is shown, **Then** the primary match clock has the strongest hierarchy and all essential state is readable without clipping.
2. **Given** a supported device input, **When** the referee activates it once, **Then** exactly one documented action occurs and navigation remains reversible.
3. **Given** match completion or an empty event log, **When** the summary opens, **Then** it renders a valid, readable result without crashing.
4. **Given** the main screen, **When** the referee presses Back before kickoff or after completion, **Then** Garmin's normal app exit remains available; during an active match, an explicit Exit action checkpoints the match before closing.
5. **Given** an incorrectly recorded match event or a period that must end early, **When** the referee opens match options, **Then** Undo last event and End period are reachable and require no hidden input gesture.
6. **Given** an active match, **When** the referee chooses Stop & exit and confirms it, **Then** the match ends, the FIT activity is saved, active recovery is cleared, and the application closes.

---

### User Story 4 - Developer Maintains and Validates the App (Priority: P2)

A developer can understand the architecture, build supported targets, run meaningful automated tests, and distinguish verified limitations from obsolete notes or experiments.

**Why this priority**: Reliable maintenance prevents recurrence of the repository's current build and architecture failures.

**Independent Test**: Follow the repository documentation from a clean checkout to build representative targets, run the automated suite, and trace each major responsibility to one authoritative component.

**Acceptance Scenarios**:

1. **Given** a configured supported development environment, **When** documented build and test commands run, **Then** they complete cleanly for representative device classes.
2. **Given** a developer investigates timing, state, recording, input, or rendering, **When** they follow the architecture documentation, **Then** each concern has a clear owner with no competing implementation.
3. **Given** the final repository, **When** obsolete files, temporary artifacts, debug hacks, and incomplete tests are searched for, **Then** none remain without an explicit documented reason.

### Edge Cases

- A callback arrives several seconds late, after a period boundary, or after the app returns to the foreground.
- The monotonic timer wraps, moves backward in a synthetic test, or produces an interval outside the expected range.
- Pause, resume, card, scoring, Back, and confirmation inputs arrive in rapid succession.
- A period reaches zero while paused, while a conversion is active, or while multiple yellow cards have different remaining times.
- A yellow card expires exactly at a period boundary; unexpired cards carry into the next period without counting half-time.
- A conversion expires while the match clock is paused or another view is open.
- Activity recording is unavailable, fails to start, fails to save, or receives a repeated stop/save request.
- The event log is empty, exceeds the visible summary capacity, or contains an event at a boundary timestamp.
- The application is stopped during an active match or after match completion.
- Required drawables, optional device capabilities, or haptics are unavailable.
- Compact round, large round, and rectangular screens have different usable dimensions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST have one authoritative match state and one authoritative calculation for each match and auxiliary timer.
- **FR-002**: The system MUST derive elapsed durations from authoritative timestamps and MUST NOT assume periodic callbacks are precise.
- **FR-003**: The system MUST define and enforce valid transitions among pre-match, running, paused, between-period, and completed states.
- **FR-004**: Starting, pausing, resuming, completing a period, completing a match, and resetting MUST be deterministic and idempotent where repeated delivery is possible.
- **FR-005**: Automatic period and match completion MUST occur once when the authoritative clock crosses the configured boundary, including after a delayed update.
- **FR-006**: Rugby variant defaults and user clock adjustments MUST have explicit bounds and MUST remain internally consistent.
- **FR-007**: Score, conversion, and sanction actions MUST validate team, event type, and match state before changing match data.
- **FR-008**: Yellow-card and conversion timers MUST document whether they follow active match time or wall time and MUST preserve that behavior across pause, half-time, and delayed updates.
- **FR-009**: Corrections MUST keep scores, counters, and the match event history mutually consistent.
- **FR-010**: Input handling MUST map each supported physical or touch action to one predictable operation and MUST guard destructive actions against accidental activation.
- **FR-011**: View refresh mechanisms MUST start and stop with view visibility and relevant state, without repeated timer creation or callbacks to hidden views.
- **FR-012**: UI code MUST render a coherent state snapshot and MUST NOT own authoritative match transitions or timing calculations.
- **FR-013**: Main, conversion, prompt, menu, and summary screens MUST be readable and internally consistent on representative compact round, large round, and rectangular devices.
- **FR-014**: Activity recording MUST have explicit start, save, discard, failure, and repeated-call behavior and MUST degrade safely when unavailable.
- **FR-015**: Match events MUST remain available for in-app review through match completion; saved-activity export MAY be best effort where device support permits.
- **FR-016**: The application MUST make an explicit, documented choice about active-match recovery after lifecycle interruption and MUST behave consistently with that choice.
- **FR-017**: Resource definitions, manifest declarations, permissions, product support, and localization references MUST be valid and mutually consistent.
- **FR-018**: Automated tests MUST independently cover core state transitions, elapsed-time calculations, delayed updates, boundary conditions, invalid transitions, resets, adjustments, auxiliary timers, event consistency, and restoration behavior if recovery is supported.
- **FR-019**: The repository MUST exclude generated outputs and MUST remove obsolete experiments, duplicate implementations, stale temporary files, incomplete test stubs, and unnecessary production debug logging.
- **FR-020**: Documentation MUST describe actual behavior, architecture, supported assumptions, build and test commands, and remaining verified limitations.
- **FR-021**: Existing intentional scoring, variant, sanction, conversion, activity-recording, match-summary, and automatic-transition behavior MUST remain available unless repository evidence shows it is obsolete or incorrect.
- **FR-022**: The application MUST provide an obvious exit path in pre-match, active-match, and completed states without discarding an active-match recovery checkpoint.
- **FR-023**: Manual period completion and correction of the most recent score or sanction MUST be reachable from the watch UI and reflected consistently in the event summary.
- **FR-024**: The activity recorder MUST enable continuous positioning, include Garmin-derived route and distance data in the FIT activity for Garmin Connect, avoid adding mileage to the match UI, and degrade safely while GPS is acquiring or unavailable.
- **FR-025**: Exiting during an active match MUST save the current FIT segment and recovery checkpoint; a restored match MUST begin a new recording segment when resumed.
- **FR-026**: The active-match options MUST distinguish recoverable `Exit & save` from confirmed terminal `Stop & exit`; the terminal action MUST end the match, save the FIT activity, clear recovery, and close the application exactly once.

### Key Entities

- **Match**: Current variant, state, period, authoritative timing anchors, accumulated active time, teams, events, and completion status.
- **Team**: Stable identifier, display label, score, and per-event counters.
- **Match Event**: Ordered, uniquely identified scoring or discipline action with team, match time, period, and correction status.
- **Sanction**: Yellow or red card, owning team, state, duration where applicable, and timing anchor.
- **Conversion Attempt**: Owning team, duration, state, and authoritative wall-time anchor.
- **Activity Recording**: Lifecycle and result of the best-effort saved activity associated with a match.
- **Activity Metrics**: Internal GPS acquisition state and Garmin-calculated elapsed distance used by recording and recovery, not by the match UI.
- **Render Snapshot**: Immutable-at-use projection of the match state for one UI update.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Representative supported targets build with zero errors and zero unresolved warnings that indicate functional, compatibility, or resource defects.
- **SC-002**: All automated core-model tests pass, including at least one delayed-update case crossing each period boundary and boundary cases at zero and the configured period duration.
- **SC-003**: Across a simulated complete match, every displayed match duration differs from the timestamp-derived expected value by no more than one displayed second.
- **SC-004**: Repeating any guarded completion, save, discard, or reset action produces at most one externally visible result.
- **SC-005**: Every supported state and transition is represented by an automated test or a documented device-only validation case.
- **SC-006**: Primary match information is readable without clipping on at least one compact round, one large round, and one rectangular supported profile.
- **SC-007**: A developer can identify the owner of match state, timing, input, recording, and rendering from the README in under five minutes.
- **SC-008**: Repository review finds no unexplained TODOs, production debug hacks, duplicate source implementations, committed generated output, or placeholder tests.
- **SC-009**: A second post-refactor audit finds no unresolved issue rated serious for timing correctness, state integrity, lifecycle safety, or data loss.
- **SC-010**: Back exits normally before kickoff and after match completion, while an active match can be exited through one labelled menu item after its recovery checkpoint is written.
- **SC-011**: Simulator validation shows an acquiring/unavailable GPS state without failure, and physical-device validation confirms a saved FIT route and distance within normal Garmin GPS tolerance.
- **SC-012**: Selecting and confirming Stop & exit terminates the simulator application and a subsequent launch starts without restoring the completed match.

## Assumptions

- Match timing follows the variant values already established by repository specifications unless tests or documented rugby rules show a contradiction.
- The configured minimum Connect IQ API remains the compatibility floor unless actual required functionality proves otherwise.
- Representative validation covers compact round, large round, and rectangular devices; the manifest lists only targets that compile and meet the documented assumptions.
- Haptic feedback is best effort on devices that expose vibration capability and never substitutes for visible state.
- No network dependency, analytics, or telemetry is required.
- Variant preferences may persist independently, but active-match recovery is included only if lifecycle and storage constraints allow it to be reliable and proportionate; otherwise the lack of recovery is made explicit to users and developers.
- Best-effort activity export must never block match completion or erase the in-app summary.
- Unmerged historical branches are evidence of intended or attempted behavior, not automatically accepted product scope.

## Security & Privacy Considerations

- Match state and event history contain team-relative sporting events but no names or account identifiers. When recording is active, the saved Garmin FIT activity contains the GPS route and distance requested by the user.
- The application collects no telemetry or analytics and makes no network calls.
- Runtime match data and cumulative distance are retained only as required for the active session and configured activity save; reset/discard removes application-owned recovery data.
- Saved activity retention and deletion follow the user's Garmin device and Garmin Connect controls.
- Release validation includes confirming least-privilege manifest permissions, absence of secrets or signing keys, no unexpected network behavior, and no newly introduced dependency vulnerabilities.
