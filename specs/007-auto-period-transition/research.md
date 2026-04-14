# Research: Auto Period Transition

## Decision: Automatic countdown-expiry transition belongs in the match model

**Rationale**: The main countdown, count-up timer, yellow-card timers, haptic thresholds, and expiry state already derive from `RugbyGameModel` active elapsed time. Evaluating the 00:00 boundary in the model keeps the transition tied to the same match snapshot/update that computes timer values and avoids a separate UI timer path that could drift or transition twice.

**Alternatives considered**:
- Trigger from the view when it renders 00:00: rejected because rendering should bind state, not mutate match lifecycle.
- Trigger from an independent timer callback: rejected because it would add a second timing source and violate the single synchronized timebase principle.

## Decision: Final vs non-final period uses the selected setup's period count

**Rationale**: Existing variant/setup state includes the current half/period index and total period count. Using that setup keeps 15s, 7s, 10s, U19, and future configured variants consistent with the referee's selected match format.

**Alternatives considered**:
- Hard-code "second half is final": rejected because variant support should remain data-driven and future match setups may differ.
- Ask for a new configuration value: rejected because the selected setup already provides the necessary boundary.

## Decision: Non-final expiry enters the existing between-period flow

**Rationale**: The app already has a half-ended/between-period state and next-period start flow. Reusing it provides the requested automatic end without changing how the referee starts the next period.

**Alternatives considered**:
- Automatically start the next period after a break duration: rejected because the spec asks to pause card timers and have them present for the next period, not to remove referee control of restart.
- Create a new "auto period ended" screen: rejected as unnecessary surface area.

## Decision: Final-period expiry enters the existing match-ended summary/save flow

**Rationale**: The final 00:00 boundary is equivalent to the existing deliberate end-match outcome. Reusing the match-ended flow preserves final score, event log, activity-save behavior, and fallback review behavior.

**Alternatives considered**:
- Require the referee to confirm final match end at 00:00: rejected because the requested behavior is automatic match end when the countdown runs out.
- Add a separate full-time pending state: rejected because it adds navigation complexity without new user value.

## Decision: Unexpired yellow-card timers carry forward by preserving remaining active time at non-final period end

**Rationale**: Yellow-card timers currently depend on match active elapsed time. At a period boundary the prior period active elapsed resets for the next period, so active yellow cards need their remaining duration preserved before the reset. Carrying that remaining time forward keeps team assignment, alert state, and display behavior intact while matching the requested pause/resume behavior.

**Alternatives considered**:
- Let yellow-card timers continue decrementing during the period break: rejected because the user requested they pause.
- Expire all yellow cards at period end: rejected because unexpired card timers must be present for the next period.
- Convert to wall-clock timers during the break: rejected because sanctions should remain tied to active match time, not real-world break duration.

## Decision: Paused-at-zero does not auto-transition until active timing reaches the expiry boundary or the referee explicitly ends the period/match

**Rationale**: The spec says automatic transition happens when the countdown timer runs out. If the app is already paused at 00:00 or clamped there, treating every paused snapshot as an automatic transition would surprise the referee and could bypass existing deliberate end controls.

**Alternatives considered**:
- Always transition whenever a snapshot shows 00:00: rejected because paused snapshots could mutate lifecycle unexpectedly.
- Never auto-transition if paused first: rejected because resuming from the boundary should still resolve the expired period.

## Decision: Conversion timers and red cards keep existing period-end behavior

**Rationale**: The feature scope explicitly targets the main countdown and card timers, with assumptions clarifying that "card timers" means yellow-card countdowns. Red cards have no countdown in the current app, and conversion timer behavior is governed by prior specs.

**Alternatives considered**:
- Carry conversion timers across periods: rejected as a separate rugby rule decision not requested in this feature.
- Add red-card countdown pause/resume behavior: rejected because existing specs say red cards remain non-countdown sanctions.

## Decision: Validation focuses on model unit tests plus compile/simulator checks

**Rationale**: The risky behavior is match state transition and timer continuity, which is most directly validated in `RugbyGameModel` tests. Compile and simulator/device checks still matter to confirm the existing period/match-ended UI remains readable after automatic transitions.

**Alternatives considered**:
- Visual-only validation: rejected because state boundary bugs can pass visually in narrow cases.
- Manual match-only validation: rejected because repeated edge cases such as simultaneous yellow expiry and period expiry need deterministic tests.
