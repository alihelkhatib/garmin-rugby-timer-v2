# Research: Codebase Rehabilitation

## Decision 1: Treat repository branches as evidence, not merge targets

**Decision**: Rehabilitate from `main` and selectively recover validated ideas or fixes from unmerged `009`/`010` history.

**Rationale**: The branches diverge, contain partial generated artifacts and feature additions, and are not release-approved. Whole-branch merging would make failures harder to attribute.

**Alternatives considered**: Reset to `010-referee-field-controls`; merge all remote branches; ignore history completely.

## Decision 2: Separate state advancement from rendering

**Decision**: Use an explicit `advance(nowMs)` mutation before producing a render snapshot. Views never save activities, navigate, or authoritatively end periods from `onUpdate`.

**Rationale**: Current `snapshot()` and `onUpdate()` calls mutate match state and trigger external effects. Redraw frequency is not a safe transaction boundary and can repeat or omit actions.

**Alternatives considered**: Keep snapshot mutation with flags; move only match-save navigation out of the view. Both retain hidden write behavior.

## Decision 3: Preserve timestamp-derived timing with wrap-safe deltas

**Decision**: Supply one monotonic `nowMs` to each model operation and compute deltas from anchors, using a helper that handles wrap and clamps invalid values.

**Rationale**: Callback counting drifts during delayed execution and sleep. A shared timestamp keeps all values coherent during one update.

**Alternatives considered**: Increment counters on every one-second callback; independent timers for each visible countdown.

## Decision 4: Recover interrupted matches in a paused state

**Decision**: Persist a versioned compact snapshot after meaningful mutations and during normal app stop. Before storage, fold any running interval into accumulated active time and mark the recovery state paused. On launch, restore only valid, supported schemas.

**Rationale**: This protects scores/events after an accidental app exit without claiming that play continued while execution was unavailable or relying on a monotonic anchor across reboot.

**Alternatives considered**: No recovery; continue running from a saved wall-clock timestamp; full event-sourced persistence. No recovery is poor referee UX, wall time can jump, and event sourcing is unnecessary complexity.

## Decision 5: Keep auxiliary timer semantics explicit

**Decision**: Yellow-card timers use active match time and pause during match pause/half-time. Conversion timers use monotonic wall time and continue while the match clock is paused, matching existing documented behavior.

**Rationale**: Existing tests and README consistently encode these two different rugby-use semantics. Both still derive from the single timestamp supplied per evaluation.

**Alternatives considered**: Make all timers active-time based; run independent decrementing callbacks.

## Decision 6: Use a lightweight application controller

**Decision**: A single controller coordinates model advance, persistence, recording, haptics, and one-shot navigation signals. Views and delegates call it rather than duplicating orchestration.

**Rationale**: The model should remain deterministic and testable, while external device APIs cannot be hidden inside snapshots. One coordinator is smaller than distributed side-effect flags.

**Alternatives considered**: Put all effects in the model; keep orchestration split between main view and delegate.

## Decision 7: Resource-first UI with bounded dynamic drawing

**Decision**: Static screen structure, text, colors, and positions stay in valid Connect IQ resources. Runtime-variable summary rows and repeated red-card markers may be drawn manually with explicit bounds.

**Rationale**: Resource layouts provide device adaptation, while a variable event list cannot be expressed cleanly as a fixed set of labels without waste and clipping risk.

**Alternatives considered**: Hand-draw every screen; create a large fixed set of hidden labels.

## Decision 8: Test through dedicated application and unit-test jungles

**Decision**: Keep production source free of test startup behavior and compile tests with the SDK unit-test flag and an explicit test source path/configuration.

**Rationale**: Current documentation claims tests run during startup, but the jungle file does not include them. Explicit targets make results reproducible.

**Alternatives considered**: Include tests in production `base.sourcePath`; rely only on simulator smoke testing.

## Decision 9: Minimize permissions and device claims

**Decision**: Keep only permissions exercised by production code and only product IDs accepted by the chosen SDK/build matrix. Document device assumptions instead of listing unvalidated products.

**Rationale**: Duplicate and unused permissions increase review surface; a long unverified product list creates false compatibility claims.

**Alternatives considered**: Preserve all current permissions/products unchanged; target only one watch.

## Decision 10: No third-party dependencies or telemetry

**Decision**: Depend only on the Garmin SDK/Toybox modules already required. Add no analytics, network, or external persistence.

**Rationale**: This minimizes binary size, battery cost, privacy surface, licensing, and CVE exposure.

**Alternatives considered**: External analytics/crash reporting or a generic state framework.
