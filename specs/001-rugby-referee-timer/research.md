# Research: Rugby Referee Timer

## Decision: Target Connect IQ API 4.1.6 for v1

**Rationale**: Garmin's official `Toybox.Activity` docs list `SPORT_RUGBY` as a sport constant available since API Level 4.1.6. The constitution requires rugby activity recording where supported, so v1 should target API 4.1.6 instead of relying on a generic sport label by default. This means the fenix 6+ goal is constrained by actual target support for the selected API level; devices without exact rugby support need a validated rugby-equivalent fallback or exclusion from v1.

**Alternatives considered**:
- Lower API with `SPORT_GENERIC`: rejected for v1 because it does not satisfy the exact rugby activity goal.
- Lower API with `SPORT_TEAM_SPORT`: acceptable only as a documented rugby-equivalent fallback if a target watch cannot use `SPORT_RUGBY`, but not the primary v1 path. Arbitrary non-rugby labels remain unacceptable for v1.

**Source**: Garmin Connect IQ `Toybox.Activity` API docs, `SPORT_RUGBY` entry, generated 2026-03-10: https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity.html

## Decision: Use ActivityRecording for FIT session handling

**Rationale**: Garmin's `Toybox.ActivityRecording` module provides FIT recording session support, accepts `:sport`, `:subSport`, and `:name`, and requires Fit permission. It also documents that only one session object can exist at a time, so the app must centralize session lifecycle in one recorder component.

**Alternatives considered**:
- No FIT recording: rejected by spec requirement to record a rugby activity.
- Multiple recorder/session owners: rejected because Garmin permits only one active session object.

**Source**: Garmin Connect IQ `Toybox.ActivityRecording` API docs: https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording.html

## Decision: Single match-state timebase

**Rationale**: The constitution requires synchronized timers with no visible lag. All timer displays and haptic thresholds will derive from one match-state snapshot: match clock running state, elapsed active time, active half, variant durations, sanctions, and conversion state.

**Alternatives considered**:
- Independent timer instances for countdown, count-up, cards, and conversion: rejected because independent loops can drift and violate the constitution.
- Rendering timers directly from wall-clock reads in the view: rejected because it spreads timing rules into UI code and makes regression checks harder.

## Decision: Variant rules as compact shared configuration

**Rationale**: Built-in variants need defaults for half length, half count, sin-bin length, and conversion length, with one-minute half adjustments and configurable sin-bin/conversion lengths. A shared preset table plus per-match overrides keeps the implementation DRY and testable.

**Alternatives considered**:
- Separate code branches per variant: rejected as duplication.
- Fully free-form setup only: rejected because common variants should be quick to start.

## Decision: Red cards are persistent sanctions, not countdown timers

**Rationale**: Clarification resolved that yellow cards use countdown timers while red cards show persistent active indicators without expiry countdowns. This avoids building a red-card timer that would imply an expiry.

**Alternatives considered**:
- Countdown timers for red cards: rejected by clarification.
- Hidden red-card event only: rejected because the spec requires visible active sanction state.

## Decision: Lightweight UI/input contract instead of external API contracts

**Rationale**: This is a watch app with no external service API. The useful contract is the referee-facing interaction and state contract: what inputs must do and what state must be visible after each action.

**Alternatives considered**:
- REST/OpenAPI contracts: not applicable.
- No contracts: rejected because the input/state behavior is central enough to preserve in planning and tasks.
