# Implementation Plan: Codebase Rehabilitation

**Branch**: `011-codebase-rehabilitation` | **Date**: 2026-09-19 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/011-codebase-rehabilitation/spec.md`

## Summary

Restore a non-building, partially merged watch application by first making resources, manifest, and test configuration valid, then consolidating runtime behavior around one explicit match model and one small application controller. Time is computed from monotonic timestamp anchors; callbacks only evaluate state and request redraws. Views bind resource-backed layouts and have explicit show/hide timer lifecycles. The model owns scores, corrections, events, sanctions, period transitions, and a serializable recovery snapshot. Representative builds and deterministic model tests gate each phase, followed by repository cleanup, documentation, diff review, and a second audit.

## Technical Context

**Language/Version**: Monkey C; Connect IQ API 3.4.0 compatibility floor, validated with local SDK 8.3.0  
**Primary Dependencies**: Built-in Toybox `Application`, `WatchUi`, `Graphics`, `Lang`, `System`, `Timer`, `Attention`, `Activity`, and `ActivityRecording`; no third-party libraries  
**Storage**: `Application.Storage` for variant preferences and a compact active-match recovery snapshot; no network or external application database  
**Testing**: Connect IQ unit-test compilation/execution plus representative Fēnix 6, modern round, and rectangular/touch simulator builds; static repository checks  
**Target Platform**: Garmin Connect IQ watch apps, Fēnix 6 onward plus manifest-listed compatible devices that compile under SDK 8.3.0  
**Project Type**: Offline Garmin Connect IQ watch application  
**Performance Goals**: One-second visible refresh while clocks are active; no display drift beyond one displayed second; no more than one repeating UI timer per visible timed view; no background refresh timer while hidden  
**Constraints**: Memory- and battery-constrained devices; monotonic timer wrap handling; no network; dark and glanceable UI; resource-first layouts; best-effort haptics and FIT recording  
**Scale/Scope**: One active match, two teams, bounded in-memory event/sanction data, variants 15s/7s/10s/U19, compact round/large round/rectangular layouts

## Constitution Check

*GATE: Passed before research and re-checked after design.*

- [x] Referee-first scope: the main countdown remains dominant; rehabilitation adds no analytics or non-match workflow.
- [x] Spec traceability: all behavior changes map to FR-001 through FR-021 in the active specification.
- [x] Synchronized timebase: a single model evaluation uses one supplied monotonic timestamp for main time, sanctions, conversions, alerts, and transitions.
- [x] Simplicity/DRY: existing shared variant data is retained; duplicate prototypes and formatting/state helpers are consolidated only where duplication causes defects.
- [x] Declarative UI resources: primary and conversion screens remain XML-backed; summary static structure moves to valid resources where feasible. Only variable event rows and compact red-card markers may be drawn manually because their count is runtime-dependent.
- [x] Garmin compatibility: API 3.4.0 is the Fēnix 6-compatible floor; SDK 8.3.0 builds cover Fēnix 6, a modern round profile, and a rectangular profile. Unsupported or invalid product IDs are removed rather than claimed.
- [x] Activity recording: `SPORT_RUGBY` is used when available with a documented generic fallback; start/save/discard are idempotent and tested through a fake recorder seam.
- [x] Regression isolation: model tests cover timing, variants, score/try/conversion, cards, auto transitions, summary, recording calls, and recovery.
- [x] Accessibility/haptics: black background, stable labels, text/position in addition to color, and best-effort distinct start/pause/expiry alerts are preserved.
- [x] Security & Privacy: only team-relative match data is stored; no PII, telemetry, network, or secrets. Reset/discard clears the recovery snapshot. Security owner/sign-off remains the repository maintainer's release responsibility.
- [x] Release & Rollback: release requires clean representative builds/tests, simulator smoke checks, signing with the maintainer key, and store validation. Rollback is a signed prior release or a minimal hotfix from the last release tag.
- [x] Dependency & Supply-Chain: SBoM is the Garmin SDK/Toybox platform only; no third-party runtime dependencies. SDK upgrades require release-note, license, build, and device review.
- [x] Performance Budgets: no new dependency; one active refresh timer per visible timed view; bounded event display; package/memory build stats recorded for Fēnix 6 and a modern profile; 40-minute simulator smoke test documents battery-sensitive behavior.
- [x] Incident Response & Monitoring: the offline app has no telemetry. Crashes or incorrect match results are reported through repository issues, classified as critical for timing/data integrity, and require reproduction notes and a postmortem before the next release.
- [x] Contributor Governance & Approvals: the repository maintainer owns the feature and release sign-off; changes require spec traceability, review, tests, and adherence to `AGENTS.md` and the project license. Add a concise contributing section and Code of Conduct link/status to developer docs.
- [x] Legal & App-Store Compliance: verify Garmin store policy, permission necessity, icon/assets licensing, MIT license coverage, export-control applicability, and signing identity before upload.
- [x] Deprecation & Migration: internal obsolete files are removed with no public API. Recovery data carries a schema version and safely resets on incompatible data.

## Architecture and Implementation Phases

### Phase A — Restore build and test observability

1. Remove or repair the unused invalid summary layout, normalize the manifest, verify product IDs, and replace incompatible launcher assets where practical.
2. Give application and unit-test builds explicit jungle configurations and reproducible PowerShell validation commands.
3. Compile with warnings and informative type checking on representative devices; record every newly exposed error before broader refactoring.

### Phase B — Authoritative state and timing

1. Make model evaluation explicit: mutating `advance(nowMs)` applies expiry/transitions once; `snapshot(nowMs)` projects state without navigation, recording, or haptic side effects.
2. Use wrap-safe elapsed calculations and clamp invalid/backward deltas. Preserve accumulated active time on pause and period completion.
3. Define transition return events (period ended, match ended, alerts due) so a controller can perform one-shot external effects.
4. Validate event team/state, make corrections update event history, and centralize clock formatting/constants.

### Phase C — Lifecycle, persistence, and recording

1. Introduce a small controller between delegates/views and the model. It supplies a single timestamp per action/tick, saves recovery state after mutations, and owns one-shot recorder/navigation effects.
2. Persist variant preferences and a versioned recovery snapshot. A running match is checkpointed as paused so relaunch never invents unobserved playing time; completed/reset matches clear active recovery as appropriate.
3. Make recorder start/save/discard idempotent, cancel retry timers on terminal/discard paths, and keep summary availability independent of FIT export success.

### Phase D — Input and resource-backed UI

1. Remove overlapping raw-key and behavior callbacks where they can double-handle a single button; retain one documented route per device interaction.
2. Start repeating refresh/reminder timers in `onShow`/state sync and stop them in `onHide`; do not create or start them from rendering repeatedly.
3. Keep main and conversion structure in layouts/strings, provide valid compact/large/rect variants, and use bounded manual drawing only for dynamic summary rows and red-card multiplicity.
4. Ensure confirmations state the pending destructive action rather than a generic `CONFIRM` label.

### Phase E — Cleanup, verification, and documentation

1. Delete confirmed prototypes, duplicate models/views, placeholder tests, and committed temporary artifacts; remove unconditional debug logging and stale comments.
2. Expand deterministic model/controller/recorder tests, including delayed callbacks, wrap/boundaries, invalid transitions, recovery, and duplicate external actions.
3. Update README and developer/testing docs to actual commands, architecture, state diagram, device assumptions, known limitations, release/rollback, and incident/reporting expectations.
4. Run full checks, inspect the diff, audit source/resources/tests/docs again, update `CLEANUP_NOTES.md`, and resolve all serious findings.

## Project Structure

### Documentation (this feature)

```text
specs/011-codebase-rehabilitation/
|-- spec.md
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- match-control-contract.md
|-- checklists/
|   `-- requirements.md
`-- tasks.md
```

### Source Code (repository root)

```text
source/                  # Authoritative model, controller, recorder, views, delegates
resources/               # Valid layouts, strings, menus, and launcher assets
manifest.xml             # Minimal permissions and validated product support
monkey.jungle            # Application build configuration
tests/                   # Executable deterministic unit tests and test doubles
scripts/                  # Small reproducible validation helpers only if needed
docs/                     # Developer, testing, release, and store documentation
```

**Structure Decision**: Retain the single Connect IQ application layout. Add only a controller and shared formatting/time helper if build/test evidence shows they remove real duplicated responsibilities. Do not add frameworks, packages, or a second application project.

## Validation Gates

1. Resource/manifest gate: every representative target reaches Monkey C compilation.
2. Model gate: strict or informative type checking succeeds and deterministic unit tests pass.
3. Lifecycle gate: repeated start/save/discard/navigation actions are proven one-shot by tests.
4. Device gate: compact round, large round, and rectangular builds succeed; simulator smoke results and screenshots are recorded where available.
5. Performance gate: build stats fit Fēnix 6 limits, timer count remains bounded, and a full-length simulated match shows no drift or repeated callbacks.
6. Release gate: documentation, security/privacy review, license/store checks, final diff review, and second audit are complete.

## Complexity Tracking

No constitution violations are planned.
