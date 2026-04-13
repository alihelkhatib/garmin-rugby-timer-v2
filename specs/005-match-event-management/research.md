# Research: Match Event Management

## Decision: Conversion countdown starts automatically for tries, independent of match pause state

**Rationale**: The conversion attempt is tied to the try event and must be timed even when the main match clock is paused for scoring administration. Starting it in the model when a try is recorded keeps the conversion overlay and haptic thresholds consistent with the same match snapshot flow.

**Alternatives considered**:
- Start conversion only when Select is pressed on the overlay: rejected because the user reported this fails and adds an unnecessary referee action.
- Resume the main match clock to drive conversion: rejected because conversion administration can happen while match time remains paused.

## Decision: Pause reminders use an approximately 10-second haptic interval only while paused

**Rationale**: The user requested 10 seconds or a reasonable interval. A pause-only recurring timer provides a clear reminder without adding constant background work while running or idle.

**Alternatives considered**:
- Single pause haptic only: rejected because it does not address forgotten paused state.
- More frequent reminders: rejected as potentially annoying and battery-costly on a watch.

## Decision: Issuing a yellow or red card pauses the match

**Rationale**: The user specified cards are issued during stopped/paused play in their rugby context. Pausing when a card is issued prevents match time from continuing during disciplinary administration.

**Alternatives considered**:
- Leave match state unchanged on card issue: rejected because it conflicts with the requested rugby workflow.
- Pause only yellow cards: rejected because the user said card issuance generally pauses the match.

## Decision: Event log contains point-scoring actions and issued cards only

**Rationale**: Clarification selected a focused event log: try, made conversion, penalty goal, drop goal, yellow card, and red card. This captures match-significant events without cluttering the log with missed conversions or navigation events.

**Alternatives considered**:
- Log all score workflow actions including missed conversions: rejected by clarification.
- Log only tries and cards: rejected because penalty goals, drop goals, and made conversions change the score.

## Decision: Event log retention is current-match only

**Rationale**: Clarification selected current-match summary retention. This keeps storage simple, avoids new persistence, and aligns with Reset/new match clearing.

**Alternatives considered**:
- Persist across app restarts: rejected as unnecessary for current scope and more complex.
- Keep after Reset: rejected because Reset is explicitly discard/reset behavior.

## Decision: Activity-file event export is best effort and non-blocking

**Rationale**: Garmin activity recording support may not expose an appropriate event-annotation path for this app/device profile. The match must still save successfully, and the in-app match-end summary is the required fallback.

**Alternatives considered**:
- Make activity export mandatory: rejected because platform support is uncertain and would block core match saving.
- Do not attempt export at all: rejected because the spec asks for save-with-activity if possible.

## Decision: Back opens explicit End match and Reset match choices

**Rationale**: Explicit choices reduce accidental destructive actions. Clarification selected Reset as a discard of current unsaved activity/match and event log back to pre-match setup.

**Alternatives considered**:
- Back immediately cancels pending action only: rejected because it does not meet match lifecycle needs.
- Reset prompts to save first: rejected by clarification.

## Decision: Conversion overlay layout changes are isolated to conversion resources

**Rationale**: The requested clipping fix applies only to the conversion overlay. Keeping the main match layout unchanged limits regression risk and follows the resource-first UI principle.

**Alternatives considered**:
- Change global timer positions: rejected because it would risk regressing the already-working main screen.
