# Feature Specification: Fix Build Errors

**Feature Branch**: `010-fix-build-errors`
**Created**: 2026-04-15
**Status**: Draft
**Input**: Compile/build errors reported by simulator and monkeyc. Key errors:

- ERROR: fenix6: source/RugbyActivityExporter.mc:22,28: missing '{' at 'return'
- ERROR: fenix6: source/RugbyActivityExporter.mc:39,4: missing '}' at 'function'
- ERROR: fenix6: source/RugbyActivityExporter.mc:40,29: missing '{' at 'return'
- ERROR: fenix6: source/RugbyActivityExporter.mc:78: extraneous input '<EOF>' expecting class or function
- ERROR: fenix6: source/RugbyActivityRecorder.mc:215,4: extraneous input 'function' (likely unmatched braces)
- ERROR: fenix6: source/RugbyActivityRecorder.mc:231,4: missing '}' at 'function'
- ERROR: fenix6: source/RugbyEventLog.mc:4,20: mismatched input ';' expecting '{' (invalid top-level token)
- Warnings: manifest.xml contains invalid device ids and resources layout validation errors reported by the SDK

## Overview / Goal

Fix syntax and resource-schema errors so the project builds cleanly for a validated simulator target (fenix6). Ensure resource XMLs conform to resources.xsd and source files compile with Monkey C. Add deterministic integration tests or CI hooks to prevent regressions.

## User Scenarios & Testing

### User Story 1 - Developer build (Priority: P1)

As a developer, I need the repository to build successfully on the fenix6 simulator so I can validate features locally and in CI.

Why this priority: A green build is the gate for all downstream tasks (tests, CI, PRs).

Independent Test:
- Run `monkeyc -f monkey.jungle -o build/rugby.iq` and expect exit code 0.
- Run the simulator; tests in `tests/` should emit `TEST|...` traces for harness assertions.

Acceptance Scenarios:
1. Given the current repo, when building for fenix6, then monkeyc completes with exit 0 and no parsing errors.
2. Given resource XMLs under `resources/layouts/`, when validating, then no resources.xsd validation errors appear.

---

## Requirements

### Functional Requirements

- **FR-001**: The codebase MUST compile without syntax errors for target `fenix6` with the Connect IQ SDK used by the team.
- **FR-002**: All `resources/layouts/*.xml` files MUST validate against the official Connect IQ resources.xsd (no unknown elements or attributes).
- **FR-003**: The project manifest (`manifest.xml`) MUST list only valid `iq:product` ids supported by the SDK used for CI/simulator runs.
- **FR-004**: Tests that exercise build-time detectable regressions (e.g., resource parsing, export retry harness) MUST exist and be runnable in the simulator or via a CI job when SDK is available.
- **FR-005**: Changes required to fix build errors MUST be low-risk or accompanied by a constitution check if they affect user-facing behavior.

## Key Entities

- **Source files**: e.g., `source/RugbyActivityExporter.mc`, `source/RugbyActivityRecorder.mc`, `source/RugbyEventLog.mc`
- **Resources**: `resources/layouts/*.xml`, `manifest.xml`
- **Test harness**: `tests/impl_export_retry_test.mc`, integration test scaffolds

## Success Criteria

- **SC-001**: `monkeyc -f monkey.jungle -o build/rugby.iq` exits with status 0 for the fenix6 target.
- **SC-002**: No resources.xsd validation errors for layouts used by the Match Summary feature.
- **SC-003**: Unit and integration tests that run in the simulator emit expected `TEST|...` traces; the deterministic export-retry test passes under harness.
- **SC-004**: Manifest contains only validated product ids (no SDK warnings about unknown ids).

## Assumptions

- Developers running builds have a local Connect IQ SDK installed and available on PATH (monkeyc, monkeydo) when running the scripts.
- Fixes are limited to syntax, resource schema, and small API adapter adjustments—no large UX changes are intended in this task.
- CI may not run Connect IQ SDK builds until SDK is enabled on CI; local verification is required until then.

## Security & Privacy Considerations

- No user PII is affected by these changes. Standard code review safeguards apply.

## Implementation Notes (developer-facing)

- Likely root causes observed from reported errors:
  - `source/RugbyActivityExporter.mc`: missing or misbalanced braces and/or mis-placed return statements in methods — verify function bodies and closing braces.
  - `source/RugbyActivityRecorder.mc`: test helpers were added; ensure helper insertion didn't unbalance function braces. Review the `_startExportRetries` function signature and surrounding braces.
  - `source/RugbyEventLog.mc`: top-level `module` token is invalid in Monkey C — convert to a class declaration (`class RugbyEventLog`) matching other modules.
  - `resources/layouts/*.xml`: some layouts used non-`label/text-area` elements or invalid attributes; ensure elements conform to resources.xsd (use `<layouts>` root and `<layout id="...">` with `label`, `text-area`, `bitmap`, etc.).
  - `manifest.xml`: trim or correct `iq:product` ids to those supported by the SDK; for CI runs keep a minimal validated list.

## Next steps (recommended)

1. Run a local `monkeyc` build and capture full error output (already provided slices — run again after fixes to confirm).
2. Fix `RugbyEventLog.mc` by replacing `module RugbyEventLog;` with a proper `class RugbyEventLog` and correct method signatures.
3. Inspect `RugbyActivityExporter.mc` and ensure all functions open and close with matching `{}` and that `return` statements are inside functions.
4. Re-run `monkeyc` and iterate until no syntax/resource errors remain.
5. Once green locally, push a branch and open a PR; add a CI job to run `monkeyc` builds on push if possible.


