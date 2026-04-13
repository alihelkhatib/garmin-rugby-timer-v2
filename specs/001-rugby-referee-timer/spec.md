# Feature Specification: Rugby Referee Timer

**Feature Branch**: `001-rugby-referee-timer`
**Created**: 2026-04-12
**Status**: Draft
**Input**: User description: "Create a rugby timer app for a rugby referee on Garmin watches with synchronized timers, rugby variants, scoring, card/conversion timers, haptics, color-blind-friendly dark UI, and rugby activity recording."

## Clarifications

### Session 2026-04-13

- Q: What does SELECT do during an active running match? -> A: SELECT pauses/resumes the match clock during active match timing.
- Q: What happens to active yellow card timers when a half ends? -> A: Yellow card timers pause at half-end and resume when the second half starts, staying consistent with the match timebase.
- Q: How does score correction work in v1? -> A: A single undo of the last scoring event per team is accessible from the scoring menu; it reverses the most recent score entry for that team, including points and relevant counters for that event type.
- Q: How many yellow card timers can be shown per team at once? -> A: Up to 2 yellow card timers are shown per team at a time; additional cards are tracked but hidden until earlier timers for that team expire.
- Q: How does the referee start the second half? -> A: After the first half ends a dedicated half-time screen appears with a count-up half-time timer; UP/MENU increments the half-time timer on-the-fly; SELECT on the "Start 2nd half" confirmation begins the second half clock.
- Q: What is the default half-time target duration and does DOWN decrement it? -> A: Half-time defaults are variant-specific: 10 minutes for 15s and U19, 2 minutes for 7s, 5 minutes for 10s; DOWN decrements the target duration symmetrically to UP/MENU.
- Q: Where in the scoring flow does the undo action appear? -> A: Undo appears as a top-level option in the scoring dialog alongside Home/Away, before team selection, labelled "Undo last — Home" and "Undo last — Away"; it is only shown when a last event exists for that team.
- Q: What does SELECT do on the conversion action screen? -> A: SELECT pauses/resumes the match clock only, identical to its behaviour on the main match screen; it does not record any conversion outcome.
- Q: When a yellow card expires or is cleared, do subsequent cards continue the sequence or reset? -> A: Yellow card and red card sequence numbers continue across the entire match regardless of team or expiry/clear; the first card issued is Y1, the next is Y2, and so on; red cards follow the same pattern starting at R1.

### Session 2026-04-12

- Q: How should hardware buttons behave before and during a match? -> A: Before the first match start only, UP/MENU increases the half length by 1 minute, DOWN decreases the half length by 1 minute, and SELECT starts the match. During a started match, UP/MENU opens scoring for Home/Away, DOWN opens discipline/sanction card entry for Home/Away, and idle half-length adjustment is no longer available.
- Q: What should happen when a discipline card is issued? -> A: Issuing either a yellow or red card first pauses the match clock, then creates the selected team sanction. Yellow card display uses the card sequence label and timer format such as `Y1  9:59`; red card display uses a persistent red-card sequence indicator without a countdown.

- Q: How should match stoppage time be controlled? -> A: Match clock supports start, pause, resume, and end-half controls; all timers pause/resume from the same match state unless explicitly configured otherwise.
- Q: What happens if a try is recorded while a conversion timer is already active? -> A: A new try replaces any active conversion timer with a new conversion timer for the latest try.
- Q: How should red cards be represented? -> A: Yellow cards use countdown timers; red cards show a persistent active sanction indicator without an expiry timer.
- Q: When should near-expiry haptic alerts fire? -> A: Near-expiry haptic alerts fire at 60 seconds remaining for yellow card and conversion timers.
- Q: Which scoring actions are in scope for v1? -> A: V1 records all common rugby scoring: try +5, conversion +2, penalty +3, drop goal +3.
- Q: Should team labels be editable in v1? -> A: V1 uses fixed Home and Away labels to keep match setup lightweight; editable team names are out of scope unless a later spec adds them.
- Q: What is the secondary timer? -> A: The secondary timer is the count-up active match timer derived from the same match timebase as the main countdown; wall-clock realtime is out of scope for v1.
- Q: How should simultaneous haptic alerts behave? -> A: Simultaneous yellow-card and conversion 60-second alerts coalesce into one haptic alert during the same update cycle while preserving each timer's alert-fired state.
- Q: How should accidental actions be handled in v1? -> A: Pause and resume are reversible, end-half/end-match/save require a deliberate confirm action, active sanctions can be cleared, and score/counter corrections are handled by explicit lightweight correction actions for the affected team/event type.
- Q: What is the required v1 match screen layout? -> A: The count-up active match timer sits at the very top; the half indicator is directly underneath it; both teams' try counts sit under the half indicator; Home and Away labels are colored blue and orange respectively with each score directly underneath its label; each team's active card timers appear underneath that team's score; the main countdown is large and placed at the bottom.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run Match Clock (Priority: P1)

As a rugby referee, I can start, pause, resume, end a half, and manage a match with a prominent countdown timer, a secondary count-up active match timer, and a clear half indicator so I can control match time without confusion.

**Why this priority**: Match timing is the core value of the app and must be usable before scoring or sanctions add value.

**Independent Test**: Start a match with a selected rugby variant and verify the countdown, secondary timer, and half indicator remain visible, synchronized, and readable throughout normal match timing.

**Acceptance Scenarios**:

1. **Given** a referee selected a rugby variant, **When** the match starts, **Then** the app displays the main countdown as the dominant timer and displays a secondary count-up active match timer with a half indicator.
2. **Given** match time is running, **When** the display updates repeatedly, **Then** all visible timers update from the same match state without visible drift or lag.
3. **Given** match time is running, **When** the referee pauses or resumes match time, **Then** all timers pause or resume from the same match state unless explicitly configured otherwise.
4. **Given** the match has not started, **When** the referee presses UP/MENU or DOWN, **Then** the half length changes in +1 or -1 minute steps and the idle main countdown reflects the selected length.
5. **Given** the match has not started, **When** the referee presses SELECT, **Then** the match clock starts and the app leaves idle half-length adjustment mode.

---

### User Story 2 - Manage Scores and Conversion Timer (Priority: P2)

As a rugby referee, I can use fixed Home/Away team labels, record tries, conversions, penalties, and drop goals, and have a conversion timer start automatically after a try so I can track key match events with minimal interaction.

**Why this priority**: Scores and conversions are frequent match actions and should not require extra manual timer setup while refereeing.

**Independent Test**: Record a try, successful conversion, penalty goal, and drop goal for each team and verify the score, scoring counters, and conversion timer update correctly for the active variant.

**Acceptance Scenarios**:

1. **Given** a match is active, **When** the referee records a try for a team, **Then** that team gains 5 points and its small try counter increases by one.
2. **Given** a try is recorded, **When** the active rugby variant defines a conversion window, **Then** the appropriate conversion timer starts automatically.
3. **Given** a conversion is successful, **When** the referee records the conversion for the correct team, **Then** that team gains 2 points.
4. **Given** a penalty or drop goal is scored, **When** the referee records it for the correct team, **Then** that team gains 3 points.
5. **Given** the conversion timer reaches 60 seconds remaining, **When** haptics are supported, **Then** the referee receives a near-expiry haptic alert.
6. **Given** a match has started, **When** the referee presses UP/MENU, **Then** the app opens the scoring flow for selecting Home or Away and then selecting try, penalty goal, or drop goal.

---

### User Story 3 - Manage Discipline Timers (Priority: P3)

As a rugby referee, I can start yellow card countdown timers and show persistent red card sanction indicators for either team so I can track active sanctions without losing the main match clock.

**Why this priority**: Discipline timing is essential but depends on the core match clock already working.

**Independent Test**: Start a yellow card timer and a red card sanction indicator during a match and verify they appear only when needed, remain readable, and that the yellow card timer stays synchronized with the match timebase and alerts before expiry.

**Acceptance Scenarios**:

1. **Given** a match is active, **When** the referee starts a yellow card sanction, **Then** a countdown timer becomes visible without hiding the main countdown.
2. **Given** a match is active, **When** the referee records a red card sanction, **Then** a persistent red card indicator becomes visible without an expiry countdown.
3. **Given** a yellow card timer reaches 60 seconds remaining, **When** haptics are supported, **Then** the referee receives a near-expiry haptic alert.
4. **Given** multiple timers and sanction indicators are active, **When** the display updates, **Then** yellow card timers, conversion timer, red card indicators, and match timers remain synchronized without visible lag.
5. **Given** a match has started, **When** the referee presses DOWN and selects a team and card type, **Then** the app pauses the match before creating the selected card sanction.
6. **Given** a yellow card is issued, **When** it appears under the affected team score, **Then** it displays with a sequence label and timer, such as `Y1  9:59`; red cards display as persistent sequence indicators without countdown timers.

---

### User Story 4 - Choose and Adjust Rugby Variant (Priority: P4)

As a rugby referee, I can select a rugby variant and adjust key timing values so the app supports 15s, 7s, 10s, U19, and similar match formats without duplicating setup work.

**Why this priority**: Variant support broadens usefulness, but it relies on the main timer, score, and sanction flows.

**Independent Test**: Select each built-in variant, verify default half, sin-bin, and conversion timing values are applied, then adjust timing values and confirm the match uses the adjusted values.

**Acceptance Scenarios**:

1. **Given** the referee chooses a built-in variant, **When** match setup completes, **Then** the app applies that variant's half, sin-bin, and conversion timing defaults.
2. **Given** the referee changes sin-bin or conversion length, **When** a card or try is recorded, **Then** the modified length is used.
3. **Given** a referee needs a variant not exactly covered by built-in presets, **When** they adjust the configurable timing values, **Then** the app can support the match without requiring a new app version.

### Edge Cases

- Multiple timers are active at once: main countdown, secondary timer, conversion timer, and one or more yellow card timers must update together without visible drift, while red card indicators remain persistent until cleared by the referee.
- Match time is paused or resumed during a stoppage: all timers must follow the same pause/resume state unless a later requirement explicitly exempts a timer type.
- A try is recorded while a conversion timer is already active: the app must replace the active conversion timer with a new conversion timer for the latest try and prevent hidden overlapping conversion timers.
- A yellow card timer is started near the end of a half: the timer remains active across half-ended and paused states, stops decrementing while match active time is stopped, resumes from the same timebase when play resumes, and remains visible until it expires, is cleared, or the match ends.
- A red card is recorded: the red card indicator must remain visible as an active sanction until the referee clears it or the match ends.
- Multiple yellow-card sanctions may be active for the same or different teams: each sanction is tracked independently, the most urgent remaining times stay visible when space allows, and constrained layouts must still preserve a visible count/indicator for additional active sanctions.
- A haptic-capable event occurs while another alert is due in the same update cycle: the app sends one coalesced haptic alert, marks each due yellow-card or conversion alert as fired, and avoids repeated vibration for the same threshold.
- The display is constrained on a smaller supported watch: main countdown, score, half indicator, and active critical timer/indicator state must remain readable; the secondary count-up timer may be abbreviated before any critical match state is hidden; color must not be the only way to distinguish card state.
- Timing values are adjusted while a timer is already active: updated half length affects match setup or not-yet-started halves only; updated sin-bin and conversion lengths affect newly created yellow-card and conversion timers only, while already-active timers keep the duration they started with.
- An accidental action occurs: pause/resume can be reversed directly, end-half/end-match/save require deliberate confirmation, active sanctions can be cleared, and incorrect scoring entries can be corrected with explicit lightweight correction actions.
- The final half ends: match timing transitions to match-ended, active timers stop, and the activity recording session is stopped and saved where recording is available.
- The selected watch or activity history cannot label the activity as rugby exactly: the app may use only a documented rugby-equivalent Garmin sport fallback such as a team-sport match label; if no acceptable fallback is validated, that target must be excluded for v1 rather than silently using an arbitrary non-rugby label.

## Requirements *(mandatory)*

### Functional Requirements

For this project, requirements MUST identify affected existing timer, scoring, variant,
rendering, storage, and activity-recording behavior so regression isolation can be tested.

- **FR-001**: The app MUST let a referee select or configure a rugby match variant before starting match timing.
- **FR-002**: The app MUST provide built-in timing defaults for 15s, 7s, 10s, and U19 rugby variants.
- **FR-003**: The app MUST let the referee adjust half length in plus or minus one-minute steps.
- **FR-004**: The app MUST let the referee adjust sin-bin and conversion timer lengths for the selected match setup.
- **FR-005**: The app MUST support not-started, running, paused, half-ended, match-ended, expired, and cleared states across match, conversion, and sanction timing where applicable.
- **FR-006**: The app MUST support start, pause, resume, end-half, and end-match/save controls for match timing.
- **FR-007**: The app MUST display a main match countdown timer as the most prominent on-screen element during active match timing, using the largest timer text and primary central/top visual position with no other timer equal to or larger than it.
- **FR-008**: The app MUST display a secondary count-up active match timer and a half indicator near that secondary timer when the screen size allows.
- **FR-009**: The app MUST keep the main countdown, secondary timer, yellow card timers, red card indicators, conversion timer, haptic thresholds, and expiry states synchronized by deriving one render snapshot from a single match timebase per display refresh.
- **FR-010**: The app MUST display fixed Home and Away labels with each team's score in v1.
- **FR-011**: The app MUST allow the referee to record a try worth 5 points for either team.
- **FR-012**: The app MUST display a small try counter near each team's score.
- **FR-013**: The app MUST allow the referee to record a successful conversion worth 2 points for either team.
- **FR-014**: The app MUST allow the referee to record a penalty goal worth 3 points for either team.
- **FR-015**: The app MUST allow the referee to record a drop goal worth 3 points for either team.
- **FR-016**: The app MUST automatically start the selected variant's conversion timer when a try is recorded; if a conversion timer is already active, the new try replaces it with a new conversion timer for the latest try.
- **FR-017**: The app MUST allow multiple yellow discipline card countdown timers to be started, independently tracked, expired, and cleared when needed.
- **FR-018**: The app MUST allow red discipline card sanctions to be shown as persistent active indicators without expiry countdowns.
- **FR-019**: The app MUST show active yellow card timers and red card indicators without relying on color alone to identify the card type.
- **FR-020**: The app MUST use haptic alerts for critical referee attention events, including yellow card timers and conversion timers reaching 60 seconds remaining; simultaneous alerts in one update cycle MUST coalesce into one haptic event.
- **FR-021**: The app MUST use a dark, color-blind-friendly display treatment with stable, readable watch-scale layout, non-color sanction cues, and validation on representative small and large round watch screens. The v1 match screen MUST place the count-up active match timer at the very top, the half indicator directly below it, both teams' try counts below the half indicator, blue Home and orange Away labels with scores directly underneath those labels, team-assigned card timers underneath each team score, and the large main countdown at the bottom.
- **FR-022**: The app MUST support Garmin watches from the fenix 6 generation onward where device capabilities and the selected Connect IQ API level allow, plus other compatible watch models where feasible after simulator or device validation.
- **FR-023**: The app MUST record the session as a rugby activity in the user's activity history when the target device supports a rugby activity label.
- **FR-024**: The app MUST document and validate the closest supported rugby-equivalent activity-label fallback when an exact rugby activity label is unavailable on a supported target; unsupported or arbitrary non-rugby fallbacks MUST result in target exclusion for v1.
- **FR-025**: The app MUST provide lightweight recovery for accidental actions: reversible pause/resume, deliberate confirmation for end-half/end-match/save, clear sanction controls, and explicit correction actions for incorrect scoring entries.
- **FR-026**: The app MUST store only lightweight preferences for selected variant and timing defaults, with no match-history persistence or network dependency in v1.
- **FR-027**: The app MUST avoid heavyweight, non-referee-facing features such as in-match network dependency, complex post-match analytics, or large data-entry workflows.
- **FR-028**: The app MUST preserve existing functioning timer, scoring, variant, display, haptic, storage, and activity-recording behavior when adding or changing features.
- **FR-029**: Pressing UP/MENU during active match management MUST open a lightweight scoring dialog. The dialog MUST first offer top-level options: Home, Away, Undo last — Home (only if a last event exists for Home), and Undo last — Away (only if a last event exists for Away). Selecting Home or Away then asks the score type; supported v1 score types MUST include try, penalty goal, and drop goal.
- **FR-030**: Selecting try in the scoring dialog MUST immediately add 5 points, increment that team's try count, start the active variant's conversion timer, and show a conversion action screen. On that screen UP/MENU MUST record a successful conversion for +2 points, DOWN MUST record the conversion as missed with no score change, and either action MUST return the referee to the main match screen. SELECT on the conversion action screen MUST pause or resume the match clock only, identical to its behaviour on the main match screen, and MUST NOT record any conversion outcome.
- **FR-031**: Before the first match start only, UP/MENU MUST increase the half length by 1 minute, DOWN MUST decrease the half length by 1 minute, and SELECT MUST start the match clock. Half-length +/- controls MUST NOT remain active after the match has started.
- **FR-032**: During a started match, UP/MENU MUST open the scoring flow for selecting Home or Away and a score type; DOWN MUST open the discipline/sanction flow for selecting Home or Away and yellow or red card.
- **FR-033**: Issuing a yellow or red card during a started match MUST pause the match clock before creating the selected sanction, so all match-derived timers stop together while the sanction is recorded.
- **FR-034**: Yellow-card sanctions MUST display under the affected team score with a yellow-card sequence label and countdown timer, using a format such as `Y1  9:59`; red-card sanctions MUST display as persistent red-card sequence indicators without countdown timers.
- **FR-035**: During an active running match, SELECT MUST pause the match clock if running, or resume it if paused, affecting all match-derived timers together.
- **FR-036**: Active yellow card timers MUST pause when a half ends and MUST resume when the next half starts, remaining consistent with the match timebase; yellow card remaining time MUST be preserved across the half-time break.
- **FR-037**: The scoring dialog MUST present "Undo last — Home" and "Undo last — Away" as top-level options before team selection, visible only when a last scoring event exists for that team. Selecting an undo option MUST reverse the associated point value and relevant scoring counter (try count, etc.) for the most recent event of that team; a further undo attempt after reversal MUST NOT affect any earlier events.
- **FR-038**: The app MUST show at most 2 yellow card timers per team at a time on screen; additional yellow card sanctions for a team MUST be tracked in the model but hidden from the display until earlier timers for that team expire, at which point the next hidden timer becomes visible.
- **FR-039**: After the first half ends the app MUST display a dedicated half-time screen showing a count-up half-time timer; on that screen UP/MENU MUST increment the half-time timer target duration on-the-fly; DOWN MUST decrement the target duration symmetrically; SELECT on the half-time screen MUST present a "Start 2nd half" confirmation and, upon confirmation, start the second half clock.
- **FR-040**: The half-time default target duration MUST be variant-specific: 10 minutes for 15s and U19, 2 minutes for 7s, and 5 minutes for 10s; the referee MAY adjust the target duration using UP/MENU and DOWN before confirming the second half start.
- **FR-041**: After the second half ends the app MUST display a brief post-match summary screen showing the final score and half results; the activity recording MUST auto-save on entry to the summary screen; the referee exits the summary screen via BACK or SELECT.
- **FR-042**: Yellow card sequence numbers MUST be assigned as a single match-wide counter regardless of team, expiry, or clear; the first card issued is Y1, the second Y2, and so on. Red card sequence numbers MUST follow the same pattern starting at R1 and incrementing match-wide.

### Key Entities *(include if feature involves data)*

- **Match Setup**: Selected rugby variant, half length, sin-bin length, conversion length, fixed Home/Away team labels, and display preferences needed before or during a match.
- **Match Clock State**: Current half, running/paused/half-ended/half-time state, main countdown value, secondary timer value, and synchronization source for all visible timers.
- **Team State**: Home or away label, score, try count, conversion count, penalty goal count, drop goal count, and last scoring event for undo purposes.
- **Discipline Sanction**: Card type, assigned team, match-wide sequence number (Y1/Y2/R1/R2…), remaining time for yellow cards, persistent active state for red cards, expired/cleared state, alert state, and display visibility (visible vs. queued).
- **Conversion Timer**: Remaining time, associated try context, active/expired state, and alert state.
- **Half-time State**: Half-time timer elapsed value, current target duration (variant-specific default, incrementable/decrementable), and whether the second half has been confirmed to start.
- **Activity Recording State**: Whether the match session is being recorded as rugby or an accepted rugby-equivalent fallback.

## Success Criteria *(mandatory)*

Success criteria MUST include measurable outcomes for timer synchronization/no visible lag,
regression preservation for existing functioning features, and watch-scale readability when
those areas are affected.

### Measurable Outcomes

- **SC-001**: During a 40-minute simulated half with all timer types active, every display refresh uses one model snapshot for the main countdown, secondary timer, yellow card timers, red card indicators, conversion timer, expiry state, and haptic thresholds, and observers detect no visible mismatch during updates.
- **SC-002**: A referee can start a match for any built-in variant and begin active timing within 30 seconds from opening the app.
- **SC-003**: A referee can record a try, conversion, penalty goal, or drop goal for either team after match start and see the score and relevant scoring counters update within one display refresh cycle; recording a try starts the conversion timer immediately.
- **SC-004**: In representative small and large round watch-size validation, the top count-up timer, half indicator, try counts, Home/Away labels, team scores, team-assigned card timers, and bottom main countdown are readable without overlap; the main countdown is the largest timer and yellow/red sanctions use non-color cues.
- **SC-005**: Haptic alerts occur for 100% of yellow card and conversion timer events at 60 seconds remaining during simulator or device validation when haptics are supported; simultaneous due alerts in one update cycle produce one coalesced haptic event and mark each due alert as fired.
- **SC-006**: Regression validation confirms previously functioning timer, scoring, card, conversion, variant, display, haptic, storage, and activity-recording behaviors still pass after feature changes.
- **SC-007**: Activity history validation shows the recorded session appears as rugby or a documented rugby-equivalent fallback on each validated supported device class.
- **SC-008**: Input validation confirms idle UP/MENU and DOWN adjust half length by exactly +1/-1 minute before first start only; after the match starts, UP/MENU opens scoring, DOWN opens discipline, and SELECT does not fail to start the match from idle.
- **SC-009**: Card-entry validation confirms issuing either team a yellow or red card pauses the match first; yellow cards display with a `Y#` label and countdown under the affected team score, and red cards display with a persistent `R#` indicator.
- **SC-010**: Input validation confirms SELECT pauses a running match and resumes a paused match during active match timing, and that all match-derived timers follow the same pause/resume state.
- **SC-011**: Yellow card timer continuity validation confirms that a yellow card started in the first half retains its remaining time across the half-time break and resumes correctly when the second half begins.
- **SC-012**: Score correction validation confirms that triggering the undo action for a team reverses the last recorded scoring event by the correct point value and counter, and that further undo attempts do not affect earlier events.
- **SC-013**: Yellow card display validation confirms that when more than 2 yellow card sanctions are active for a team, only 2 are shown; after the earliest expires, the next queued sanction becomes visible without manual intervention.
- **SC-014**: Half-time screen validation confirms the count-up half-time timer runs after the first half ends, UP/MENU increments the target duration on-the-fly, DOWN decrements it symmetrically, and SELECT triggers the "Start 2nd half" confirmation before the second half clock begins.
- **SC-015**: Half-time default validation confirms each built-in variant loads the correct default target duration: 10 min for 15s and U19, 2 min for 7s, 5 min for 10s.
- **SC-016**: Undo validation confirms "Undo last — Home" and "Undo last — Away" appear as top-level scoring dialog options only when a last event exists for that team, and that selecting one reverses the correct point value and counter without affecting earlier events.
- **SC-017**: Post-match screen validation confirms the summary screen appears after the second half ends, shows correct final score and half results, auto-saves the activity on entry, and exits cleanly via BACK or SELECT.
- **SC-018**: Conversion screen SELECT validation confirms pressing SELECT on the conversion action screen pauses or resumes the match clock without recording any conversion outcome.
- **SC-019**: Card sequence validation confirms yellow and red card sequence numbers increment match-wide (Y1, Y2… and R1, R2…) regardless of which team received the card or whether earlier cards have expired or been cleared.

## Assumptions

- Built-in variant presets cover 15s, 7s, 10s, and U19; additional variants are supported through configurable timing values rather than a separate preset for every possible local rule variation.
- The referee is the only active user during a match, so no multi-user permissions or account management are required.
- Team labels are fixed to Home and Away in v1 to avoid adding setup friction.
- If a supported watch lacks an exact rugby activity label, only a documented rugby-equivalent Garmin sports activity label such as a team-sport match fallback is acceptable; otherwise the target is excluded for v1.
- Haptic behavior is only required on devices that support haptic alerts.
- The app has no in-match network dependency and stores preferences locally only.
- Any additional beneficial feature must directly support live referee match control and must not add network dependency, bulky data entry, or complex post-match workflows.
