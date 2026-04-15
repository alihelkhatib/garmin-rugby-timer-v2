# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

**Language/Version**: Monkey C 4.1.6 (minimum). Develop and test with Connect IQ SDK 9.1.0; validate backward compatibility as needed.
**Primary Dependencies**: Toybox modules: Application, WatchUi, Graphics, Lang, System, Timer, Attention, Activity, ActivityRecording. Avoid nonstandard Toybox modules unless validated per-device.
**Storage**: No new persistent storage. Use ActivityRecording for FIT export; fallback to in-memory RugbyEventLog on devices without ActivityRecording.
**Testing**: Unit tests under tests/, integration via monkeyc/monkeydo on local simulator. Use scripts/run_simulator.sh for perf runs and device validation.
**Target Platform**: Primary: fenix6 family. Secondary: Forerunner and Venu families if perf budgets pass. Record device matrix in specs/009-match-summary-access/device-validation-report.md.
**Performance Goals**: fenix-family: binary_size_delta <= 200 KB; peak_heap_delta <= 128 KB; avg_cpu_overhead <= 5.0% over a 90-minute simulated match. Record per-device thresholds in perf-validation.md.
**Constraints**: Declarative resource-first UI; MAX_EXPORT_RETRIES = 3 with backoffs [2000,5000,10000] ms; ActivityRecording export must be non-blocking and not block match end flows.
**Scope**: Single-referee match runs; support rugby variants (15s, 7s, 10s, U19).
**Owners**: Feature owner: TBD; Approver: TBD.


## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [ ] Referee-first scope: primary match countdown remains the dominant object and supporting UI is limited to in-match referee decisions.
- [ ] Spec traceability: each behavior change is captured in the existing active spec or a new spec before implementation tasks proceed.
- [ ] Synchronized timebase: main countdown, count-up/realtime, card timers, conversion timer, haptics, and expiry logic derive from one time source.
- [ ] Simplicity/DRY: variant rules are shared data/configuration; no speculative abstractions, unused dependencies, or extraneous files.
- [ ] Declarative UI resources: screen structure, static text, colors, fonts, and stable positions use Connect IQ XML/resources where feasible; any manual drawing is justified.
- [ ] Garmin compatibility: Connect IQ SDK/API assumptions, fenix 6+ support, representative device coverage, and exclusions are documented.
- [ ] Activity recording: rugby activity type or documented SDK fallback is planned and testable.
- [ ] Regression isolation: existing functioning timer, scoring, variant, UI, storage, and activity-recording behavior affected by the feature has explicit regression coverage.
- [ ] Accessibility/haptics: dark color-blind-friendly UI, non-color-only card distinction, stable watch layout, and critical haptic alerts are specified.
- [ ] Security & Privacy: feature plan includes data classification, PII handling, telemetry opt-in, retention/deletion policy, and a completed security checklist.
- [ ] Release & Rollback: release checklist, CI/CD gates, signing, device validation, and rollback/emergency patch procedures are documented.
- [ ] Dependency & Supply-Chain: SBoM for dependencies, CVE scanning, license review, and upgrade policy documented.
- [ ] Performance Budgets: measurable budgets for binary size, memory, CPU/battery and device validation tests are defined.
- [ ] Incident Response & Monitoring: monitoring/alerting plan, incident contacts, and postmortem expectations are present.
- [ ] Contributor Governance & Approvals: owner and approver for the feature, any required contributor approvals, and Code of Conduct link.
- [ ] Legal & App-Store Compliance: licensing, store policy checks, and export-control considerations are documented.
- [ ] Deprecation & Migration: deprecation notices, migration path, and compatibility considerations are described when applicable.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
|-- plan.md              # This file (/speckit.plan command output)
|-- research.md          # Phase 0 output (/speckit.plan command)
|-- data-model.md        # Phase 1 output (/speckit.plan command)
|-- quickstart.md        # Phase 1 output (/speckit.plan command)
|-- contracts/           # Phase 1 output (/speckit.plan command)
`-- tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
source/                  # Monkey C application code
resources/               # Connect IQ XML resources and layouts
manifest.xml             # Connect IQ device/app manifest
monkey.jungle            # Build configuration
tests/                   # Monkey C tests where supported
```

**Structure Decision**: [Document the selected structure and reference the real directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


