<!--
Sync Impact Report
Version change: 1.0.0 -> 1.2.0
Modified principles:
- III. Simplicity, DRY, and Small Surface Area: expanded to prefer declarative resources for UI structure
- Development Workflow and Quality Gates: expanded to require spec traceability before implementation
Added principles:
- VII. Declarative Resource-First UI
Added sections:
none
Removed sections:
none
Templates requiring updates:
- .specify/templates/plan-template.md: updated
- .specify/templates/spec-template.md: updated
- .specify/templates/tasks-template.md: updated
- .specify/templates/commands/*.md: not present
- AGENTS.md: updated
Follow-up TODOs: none
-->
# Rugby Timer Constitution

## Core Principles

### I. Referee-First Rugby Timing
The application MUST prioritize live referee use over secondary analytics or decorative UI.
The main match countdown timer is the primary object and MUST remain the most prominent
state on screen. Supporting state MAY include a count-up or realtime timer, half indicator,
home/away labels, score, small try counters, discipline card timers, and conversion timer
only when they improve in-match decisions without slowing the referee.

Rationale: A referee needs fast, reliable match control while moving. Features that do not
serve in-match decisions increase cognitive load and are outside the core product purpose.

### II. Single Synchronized Timebase
All timers MUST derive their displayed state from one monotonic match timebase or an
equivalent single source of truth. The main countdown, count-up or realtime timer, sin-bin
timers, conversion timer, haptic thresholds, and expiry logic MUST update from the same
tick calculation and MUST NOT maintain independent drifting countdown loops. Critical
timer changes MUST be computed before rendering so no timer visibly lags another timer
during the same UI update.

Rationale: Rugby match management depends on synchronized timing. Independent timers
create drift, lag, and inconsistent haptic alerts.

### III. Simplicity, DRY, and Small Surface Area
Implementations MUST follow KISS, DRY, and YAGNI. Code MUST use clear Monkey C and
Connect IQ APIs, avoid duplicated timer/scoring rules, and avoid abstractions unless they
remove real complexity or match an existing project pattern. The project MUST NOT add
extraneous files, generated clutter, unused dependencies, or speculative features. Rugby
variant rules MUST be represented as compact shared data/configuration instead of
copy-pasted branches. UI code MUST also avoid manual drawing or layout calculations when
Garmin resource XML, layouts, drawables, strings, or styles can express the same structure
clearly.

Rationale: Connect IQ devices have constrained resources, and maintainability matters more
than broad but unproven extension points.

### IV. Garmin Connect IQ Compatibility
The application MUST target Garmin watches from fenix 6 onward and SHOULD support other
compatible Garmin watch lines when screen size, memory, and SDK support allow. Plans MUST
identify the minimum Connect IQ SDK/API assumptions, supported device families, simulator
coverage, and any device exclusions. Activity recording MUST use the Garmin activity type
that registers as rugby in Garmin Connect where the SDK supports it; if the SDK lacks a
rugby-specific constant on a target device, the fallback MUST be documented and tested.

Rationale: Deployment success depends on real Garmin device constraints, not just desktop
simulation or generic mobile-app assumptions.

### V. Accessible, Glanceable Match UI
The UI MUST use a dark background, color-blind-friendly contrast, stable layout, and readable
text at watch scale. Yellow and red card timers MUST be visible only when active or otherwise
needed, and MUST remain distinguishable by text/icon/position in addition to color. Half
indicators SHOULD sit under or near the small realtime/count-up timer unless device layout
constraints justify a different placement. Critical events MUST use haptics where sensible,
including card timers nearing expiry and conversion timers nearing expiry.

Rationale: Referees read the watch under motion, weather, fatigue, and varied vision
conditions. Color alone and unstable layouts are not acceptable.

### VI. Regression Isolation and Feature Preservation
Changes MUST be isolated to the smallest practical set of files and behavior needed for the
approved requirement. Existing functioning features MUST NOT regress. Any change that touches
shared timer, scoring, variant, rendering, storage, or activity-recording behavior MUST include
explicit regression checks for the affected existing features. Refactors MUST preserve behavior
unless the spec explicitly authorizes the behavior change.

Rationale: A referee tool must remain dependable as features are added. Small isolated changes
reduce the chance that working match controls break while improving another area.

### VII. Declarative Resource-First UI
Screen structure, static text, colors, fonts, and stable positions MUST be defined in Connect IQ
resources such as XML layouts, strings, drawables, and styles wherever the platform can represent
them clearly. Monkey C view code MUST focus on binding match state, handling visibility, and
responding to interactions. Manual drawing is allowed only for dynamic visuals that cannot be
expressed cleanly in resources, and the plan MUST document why declarative resources were
insufficient.

Rationale: Declarative resources keep the code smaller, make Garmin screen variants easier to
review, and prevent layout intent from being hidden inside imperative drawing logic.

## Product Scope and Constraints

The product MUST support rugby variants including 15s, 7s, 10s, U19, and other variants
defined by match timing, sin-bin length, conversion length, and half structure. Users MUST be
able to adjust half lengths by plus or minus one minute and modify sin-bin and conversion
lengths based on the selected variant. Recording a try MUST add 5 points and MUST start the
appropriate conversion timer for the active variant.

Beneficial features MAY be added only when they remain lightweight and referee-focused.
Examples include simple match-state resume after accidental app interruption, a concise
pre-match variant picker, and clear haptic patterns for distinct critical events. Features
that require heavy data entry, network access during the match, complex post-match analysis,
or large UI flows MUST be rejected unless the constitution is amended.

## Development Workflow and Quality Gates

Every behavior change MUST be routed into the existing active feature specification when it is
part of that feature, or into a new specification when it is a distinct feature. Implementation
MUST NOT proceed on behavior that is absent from a spec, except for narrow build fixes that
restore already-specified behavior.

Every feature plan MUST pass a Constitution Check before design and again before tasks.
The check MUST document timer synchronization strategy, Garmin SDK/device compatibility,
accessibility and haptic behavior, activity-recording behavior, declarative resource usage for
UI structure, spec traceability for behavior changes, and why the implementation is the simplest
maintainable approach.

Tests or simulator checks MUST cover variant timing rules, score/try behavior, conversion
timer start behavior, card timer expiry behavior, and timer synchronization. Device-specific
UI changes MUST be validated against representative small and large round Garmin watch
screens. Any complexity violation MUST include the simpler alternative considered and the
reason it was insufficient.

## Governance

This constitution supersedes conflicting project practices, plans, specs, and task lists.
Amendments MUST be made through a documented change to this file, including a Sync Impact
Report and updates to affected Spec Kit templates. Versioning follows semantic versioning:
MAJOR for incompatible governance or principle redefinitions, MINOR for new principles or
materially expanded guidance, and PATCH for clarifications or non-semantic fixes.

Compliance review is required for every feature plan and before implementation tasks are
accepted. If a requirement conflicts with the constitution, the team MUST either revise the
requirement or amend the constitution before implementation proceeds.

**Version**: 1.3.0 | **Ratified**: 2026-04-13 | **Last Amended**: 2026-04-13

## Security & Privacy
Security and privacy are mandatory considerations for all features. The project MUST include, at minimum, the following in every feature plan:

- Data classification: identify what data is collected, stored, or transmitted (e.g., FIT session data, logs, telemetry).
- Privacy controls: PII handling, data minimization, user opt-in for telemetry, and documented retention/deletion policies.
- Storage and transmission: encryption requirements and secure transport for any external integrations.
- Security testing: required static analysis, dependency CVE scanning, threat-model summary, and any required runtime tests prior to release.
- Owner and sign-off: feature owner must record completion of the security checklist and obtain sign-off before implementation tasks proceed.

## Release & Rollback
Releases MUST follow an agreed checklist and gates, including CI checks, signing, and any device-specific validation. The project MUST document:

- Release checklist: build, signing, device validation, and post-release verification steps.
- Rollback plan: emergency patch procedure, how to revoke releases, and communication channels for incidents.

## Dependency & Supply-Chain
The project MUST maintain an inventory of third-party dependencies (SBoM), run CVE scanning on dependencies, and document update cadence and criteria for upgrades. Any changes to external dependencies require review for size, licensing, and compatibility.

## Performance Budgets
Define measurable performance budgets (binary size, memory, CPU, battery usage) for supported devices. Feature plans that affect performance MUST include target budgets and device/simulator checks to validate compliance.

## Incident Response & Monitoring
Document incident response expectations: how incidents are reported, contact list, severity classification, required postmortems, and follow-up actions. For telemetry/analytics features, define what monitoring will be in place and how alerts are triggered.

## Contributor Governance
Define contributor roles, who may amend the constitution, and the approval process for spec and plan changes. Include contributor onboarding steps, code review expectations, and a Code of Conduct (link or file reference).

## Deprecation & Migration Policy
Provide a clear deprecation policy: notice periods, migration paths, and versioning strategy for behavioral or API changes that might affect users or stored data.

## Legal & App-Store Compliance
Document required checks for app store policies, licensing compliance (including third-party license tracking), export controls, and any platform-specific legal obligations.

**Sync Impact Report**: Amendments MUST include a short Sync Impact Report capturing what templates and docs were changed and why.

**Version**: 1.3.0 | **Ratified**: 2026-04-13 | **Last Amended**: 2026-04-13


