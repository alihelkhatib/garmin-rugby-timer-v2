# Research: idle-timer-controls

## Decision: Keep idle button routing in the existing delegate

**Rationale**: Physical button handling for the app is already centralized in `source/RugbyTimerDelegate.mc`. Keeping the state gate there preserves the current app boundary: the delegate maps watch inputs, the model owns match state/timer values, and the view renders snapshots.

**Alternatives considered**:

- Add a new input controller module. Rejected because the behavior is narrow and would add surface area without reducing complexity.
- Push button interpretation into the view. Rejected because the current view primarily renders snapshot state and should not own input policy.

## Decision: Own timer adjustment in the model/configuration path

**Rationale**: The main countdown is derived from `RugbyGameModel.snapshot()` and match setup values from `RugbyVariantConfig`. Idle adjustments should update the same setup that start-match timing uses so the displayed value and started match value cannot diverge.

**Alternatives considered**:

- Store a separate "idle displayed time" value in the view. Rejected because it risks drift from the actual match start value.
- Start a pre-match timer loop. Rejected because the idle screen is not running match time; only explicit button presses change the value.

## Decision: Clamp idle timer to selected variant normal half length

**Rationale**: The clarification session set the upper bound as the selected variant's normal half length. This prevents accidental over-incrementing and keeps the idle timer tied to rugby variant expectations. The lower bound remains 00:00.

**Alternatives considered**:

- No upper cap. Rejected because repeated watch button presses could silently create unrealistic match lengths.
- Fixed global maximum. Rejected because the project already has variant-specific half lengths and the spec selected the variant-specific bound.

## Decision: Treat running, paused, and half-ended as active match states

**Rationale**: The clarification session defined active match states for score-dialog availability as running, paused, and half-ended. This preserves existing score management during active match administration while preventing score menu access before kickoff and after match end.

**Alternatives considered**:

- Running-only score availability. Rejected because paused and half-ended score corrections may be part of normal match administration.
- Running-or-paused only. Rejected because the existing app already treats half-ended as part of active match flow for several controls.

## Decision: No new persistence, dependency, or UI layout

**Rationale**: The feature changes local match-preparation behavior only. Existing resource-backed UI can display the adjusted timer value, and existing local setup/persistence behavior should be preserved.

**Alternatives considered**:

- Add persistence specifically for idle adjustments. Rejected as out of scope and not required by the spec.
- Add a setup dialog. Rejected because the requested behavior is direct physical-button adjustment on the idle screen.
