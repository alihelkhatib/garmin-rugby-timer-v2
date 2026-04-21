# Research: Referee Field Controls

## Decision: Replace Automatic Expiry With Explicit Time-Up Overtime

**Decision**: When regulation reaches zero, the model should enter an explicit time-up overtime condition instead of calling the existing automatic half/match end path from snapshot evaluation.

**Rationale**: Rugby periods end by referee decision when play is dead, not strictly at clock zero. An explicit time-up state keeps the single timebase while allowing score/card/conversion flows to continue until the Back-button match menu confirms the period or match end.

**Alternatives considered**:

- Keep automatic expiry and add a grace period: rejected because any fixed grace period can still end during live play.
- Pause the clock at zero: rejected because it loses visible overtime duration and weakens match review.
- Let Select/Start end the period at zero: rejected by clarification; Select/Start remains pause/resume.

## Decision: Latest-Only Undo

**Decision**: Undo applies only to the latest recorded score/card event and requires confirmation before mutation.

**Rationale**: The feature is for field mis-tap recovery, not post-match editing. Latest-only undo keeps button interactions short and avoids complex watch-scale event selection. It also keeps rollback validation bounded: reverse the single latest score/card state transition and remove the event entry.

**Alternatives considered**:

- Multi-step undo: rejected for v1 because it increases accidental rollback risk during live play.
- Arbitrary event deletion from summary: rejected because selecting older events on a small button-only screen is slower and error-prone.
- Counter-only correction: rejected because it can leave the event log inconsistent.

## Decision: Back-Button Match Menu As Control Hub

**Decision**: Use the existing Back-button match menu for undo, summary access, and time-up period/match-end confirmation.

**Rationale**: The Back-button menu is already the guarded path for end/reset/summary actions. Keeping high-impact non-timer controls there preserves the main buttons: Select/Start for start/pause/resume, Up/Menu for score/menu behavior, and Down for card behavior.

**Alternatives considered**:

- Dedicated direct summary shortcut: rejected because live-match physical buttons are already assigned to higher-frequency actions.
- Long-press confirmation for period end: rejected because long-press behavior varies by device and is harder to discover/test.
- Separate time-up overlay menu: rejected because it adds a new interaction pattern without improving safety.

## Decision: Recent-First Scrollable Summary

**Decision**: Show match summary events newest-first, with physical-button scrolling through all events when the list exceeds one screen.

**Rationale**: During disputes the newest event is most likely to be reviewed. The current summary truncates after visible rows, which does not satisfy a full-match review. A bounded visible row window keeps rendering lightweight.

**Alternatives considered**:

- Chronological first-to-last summary: rejected as the default because recent review is slower.
- Keep truncation with "+N more": rejected because events are not actually reachable.
- Build a second summary view: rejected because one view can handle empty, short, and long lists.

## Decision: Current-Match In-Memory Data Only

**Decision**: Do not add persistent storage for undo history or summary data.

**Rationale**: The spec is scoped to current-match correction and review. Existing activity recording remains responsible for final save/discard behavior, and reset clears the current match.

**Alternatives considered**:

- Persist undo stack across app restarts: rejected as out of scope and inconsistent with the current no-match-history constraint.
- Persist complete match summaries locally: rejected because it creates a match-history feature not requested here.

## Decision: Resource-First Static UI With Bounded Dynamic Drawing

**Decision**: Add static menu labels/status text in resources and prefer existing layout XML for stable positions. Use dynamic drawing only where scrolling summary rows require per-row rendering.

**Rationale**: The constitution favors resource-defined screen structure. The summary list content is data-driven and row count/offset dependent, so manual row drawing may be the simplest safe approach if resource text areas cannot provide reliable scroll behavior on target devices.

**Alternatives considered**:

- All-manual summary rendering: allowed only if resource text areas fail; otherwise less aligned with the constitution.
- All-resource static summary rows: rejected if it prevents clean scrolling through arbitrary event counts.
