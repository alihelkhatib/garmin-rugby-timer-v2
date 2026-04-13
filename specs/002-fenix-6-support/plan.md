# Implementation Plan: fenix-6-support

**Branch**: 002-fenix-6-support | **Date**: 2026-04-13 | **Spec**: specs/002-fenix-6-support/spec.md

## Summary

Small compatibility and validation effort to ensure the Rugby Timer app works reliably on Garmin fenix 6. Focus on UI legibility, manifest/SDK compatibility, haptics, FIT activity recording, and performance under match conditions.

## Technical Context

**Language/Version**: Monkey C / Garmin Connect IQ SDK — specify exact SDK version in plan execution step
**Primary Dependencies**: Garmin Toybox APIs (Application, WatchUi, Graphics, Lang, System, Timer, Attention, Activity, ActivityRecording)
**Storage**: Connect IQ app storage only if required for short-lived state
**Testing**: Physical fenix 6 device validation and Garmin simulator profiles covering small and large round screens
**Target Platform**: Garmin fenix 6 (primary), fenix 6+ families
**Performance Goals**: No visible drift in timers during a 30-minute run; app memory usage stays within fenix 6 tolerances
**Constraints**: Offline watch app, battery and memory-constrained device, limited logging

## Constitution Check

- [x] Referee-first scope: primary match countdown remains dominant
- [x] Spec traceability: spec.md created and validated
- [x] Synchronized timebase: requirement present and testable
- [x] Simplicity/DRY: planned changes small and targeted
- [x] Declarative UI resources: prefer resource XML changes over drawing where feasible
- [x] Garmin compatibility: fenix 6 is explicitly documented as validation device
- [x] Activity recording: FIT recording requirement included
- [x] Regression isolation: plan includes regression checks
- [x] Accessibility/haptics: included
- [x] Security & Privacy: N/A for compatibility check (no telemetry changes)
- [x] Release & Rollback: include in tasks to validate signing and manifest
- [x] Dependency & Supply-Chain: generate SBoM and CVE scan in tasks
- [x] Performance Budgets: set device-level budgets in tasks
- [x] Incident Response & Monitoring: document minimal incident reporting expectations
- [x] Contributor Governance & Approvals: owner listed in tasks
- [x] Legal & App-Store Compliance: manifest/packaging checks included
- [x] Deprecation & Migration: N/A

## Project Structure

(spec folders omitted for brevity — keep existing source/, resources/, manifest.xml, monkey.jungle)

## Phase 0: Research

- R-001 Confirm exact Connect IQ SDK version to target for fenix 6 build. (Owner: dev)
- R-002 Identify any fenix 6-specific manifest flags or device capabilities affecting haptic/vibration and activity recording.
- R-003 Check current code for any hard-coded layout sizes or font metrics that could break on fenix 6.

Deliverable: specs/002-fenix-6-support/research.md

## Phase 1: Design & Contracts

- D-001 Update resource XML (resources/) where necessary to ensure layout fits fenix 6 screen and text is legible at watch scale.
- D-002 Document any manifest adjustments required for fenix 6 in manifest.xml and monkey.jungle.
- D-003 Define performance budgets: max heap usage, permitted binary size increase, acceptable CPU wake frequency during timers.
- D-004 Identify tests and simulator profiles to use and record the commands to run them.

Deliverables: data-model.md (not much data for compatibility), quickstart.md (device validation steps), research.md attached findings

## Phase 2: Implementation Tasks

Phase goals: make the minimal code/resource changes, run validations on physical fenix 6, produce test artifacts

- T001 [P] Update Connect IQ resource XML layouts for fenix 6 if any overflow or illegibility issues found (files: resources/*.xml)
- T002 [P] Adjust fonts, sizes, and label placements in resource files; prefer resource changes to manual drawing
- T003 Implement small device-conditional fallbacks in manifest.xml/monkey.jungle if required
- T004 Run SBoM and CVE scan for dependencies; document results (tools: sbom generator, dependency-check)
- T005 Create device validation script: scripts/validate-fenix6.sh to automate install, run 30-minute simulation, capture logs/FIT file
- T006 Run physical-device validation: install app on fenix 6, run match flows, capture FIT file samples (Owner: dev)
- T007 Add regression tests/simulator checks: tests/timer_sync.mc and tests/haptics.mc
- T008 Update release_checklist.md to include fenix 6 validation step and signing manifest
- T009 Document any required SDK fallbacks for activity recording in docs/compatibility.md

## Phase 3: Polish & Cross-Cutting

- P-001 Review code changes for conformance with constitution and simplicity constraints
- P-002 Update documentation: README and quickstart to mention fenix 6 validation
- P-003 Create SECURITY.md and RELEASE_CHECKLIST.md if not present (referencing added constitution sections)

## Dependencies & Execution Order

- R-001..R-003 (Phase 0) must complete before D-001..D-004
- T001..T003 depend on D-001..D-004
- T006 (physical validation) depends on T005 and completed builds

## Owner

Feature Owner: You (device owner) — coordinate physical-device validation. Technical lead: repo maintainer

---
(Generated by speckit.plan)
