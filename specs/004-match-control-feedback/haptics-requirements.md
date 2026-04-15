# Haptics Addendum: Two-minute half & one-minute card warnings

This addendum augments specs/004-match-control-feedback/spec.md with concrete, testable haptic requirements requested by the referee UX update.

Summary

- Add a single two-minute remaining haptic warning for each half.
- Add a single one-minute remaining haptic warning for each active yellow-card timer.
- Ensure a short, distinct vibration when a match or a half first begins (separate from pause/resume vibrations).

Functional Requirements (testable)

- FR-HAPTIC-001: When the main countdown for a half reaches 120 seconds remaining (2:00), the system MUST emit a single haptic warning if device haptics are available. The haptic must fire once per half and must record a diagnostic trace named `haptic_warning_half` with payload { halfIndex, remainingSeconds, snapshotId }.

- FR-HAPTIC-002: When any active yellow-card sanction's remaining timer reaches 60 seconds (1:00), the system MUST emit a single haptic warning for that sanction if device haptics are available. The haptic must fire once per sanction and must record a diagnostic trace named `haptic_warning_card` with payload { sanctionId, teamId, remainingSeconds, snapshotId }.

- FR-HAPTIC-003: When a match or half first begins (match kickoff and half-start transitions), the system MUST emit a short, distinct vibration pattern if device haptics are available. Record a diagnostic trace named `haptic_match_or_half_start` with payload { halfIndex, snapshotId }.

Acceptance Criteria / Tests

- T-H1 (half two-minute): Simulate a running half and advance the main countdown to 120s; assert a single `haptic_warning_half` diagnostic trace was emitted and the RugbyHaptics path executed once for that half.
- T-H2 (card one-minute): Create an active yellow-card sanction and advance time to where its remainingSeconds == 60; assert a single `haptic_warning_card` diagnostic trace was emitted for that sanction and RugbyHaptics executed.
- T-H3 (match/half start): Start a match or start a half transition and assert RugbyHaptics.fireMatchStart (or equivalent) printed the existing start vibrate trace.

Implementation Notes (developer-facing)

- Prefer model-first event generation: add haptic event entries in RugbyGameModel.dueHapticEvents() so existing RugbyTimerView.handleHaptics() coalesces and fires via RugbyHaptics.fireCoalesced(snapshotId).
- Reuse RugbyHaptics.fireCoalesced to avoid duplicate vibrates per snapshotId. Add distinct event types (e.g., `half_two_min`, `card_one_min`) so diagnostics are explicit.
- Diagnostics: emit `haptic_warning_half`, `haptic_warning_card`, and `haptic_match_or_half_start` traces using System.println in the same format as existing traces to keep tests deterministic.
- Tests: update Test_RugbyGameModel.mc and integration tests to assert the presence of these diagnostics and that event sizes reflect the added haptic events.

Notes

- This addendum is intentionally minimal to avoid broad spec churn. If accepted, copy the FRs into specs/004-match-control-feedback/spec.md (Functional Requirements) during the planning phase or keep this addendum as the canonical augmentation.
