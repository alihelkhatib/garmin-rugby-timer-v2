# Implementation Plan: Center Prompts for Round Screens

**Branch**: `feature/008-centered-prompts` | **Date**: 2026-04-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-centered-prompts/spec.md`

## Brief problem statement and scope

Problem: On circular (round) watch displays, prompts and dialogs that are positioned near the bottom of the screen can be visually clipped or partially off-screen. This reduces readability and can interfere with referee actions during match control.

Scope: Detect affected match-control prompts/dialogs and present them in a centered, screen-safe region on round screens while preserving existing flows, choices, and behavior on square screens. No persistent storage, networking, or new settings are introduced.

## Proposed approach and architecture / stack choices

- Language & SDK: Monkey C (Connect IQ) — target the project's current SDK baseline (>= 4.1.x).
- Resources-first: Prefer Connect IQ XML resource changes (resources/layouts, resources/menus, resources/strings) to reposition prompts where possible. Use WatchUi and resource-backed popup/dialog layouts.
- View classes to touch (examples):
  - source/RugbyTimerDelegate.mc — for any prompts originating from the primary match timer flow
  - source/RugbyConversionView.mc or source/PromptView.mc (existing prompt/dialog views)
  - Any view or delegate that currently uses WatchUi.showDialog / WatchUi.showMenu should be reviewed
- Event model: Keep current synchronous prompt/event handling. Intercept prompt creation points and, based on System.getDisplayInfo().shape (or equivalent API for round vs square), select alternative layout or center the dialog using resource offsets or a dedicated centered-popup view.
- Graphics & layout: Use WatchUi.DrawContext and resource XML where possible. For dynamic sizing, compute safe bounds using Graphics.getDisplayWidth()/getDisplayHeight() and center content rect.
- Backwards compatibility: On square profiles, keep current bottom placement unless centering produces strictly better layout without harming existing flows.

Rationale: Small targeted UI adjustments reduce regression risk and keep implementation minimal and reviewable; resources changes are preferred for maintainability and platform consistency.

## Data model references and mapping to app state

This feature does not introduce new persistent data. Map affected prompt metadata to transient runtime state only:

- PromptContext (transient) — the existing in-memory object describing the prompt's title, body, actions, and callback. No schema changes required.
- If existing code stores a prompt "type" or "origin" (e.g., timer-based, manual action), ensure the placement decision references that so we can apply centering only to prompts that were bottom-anchored and at risk of clipping.

Implementation note: Add a small helper function in a shared UI utility module (e.g., source/ui/PromptUtils.mc) that exposes shouldCenterPrompt(context, displayInfo) → boolean and computeCenteredBounds(displayInfo, contentSize) → Rect. This remains transient and testable.

## Phases with clear deliverables

Phase 0 — Research (deliverables)
- research.md (specs/008-centered-prompts/research.md)
  - Inventory of all prompts/dialogs used during match control (list of prompt identifiers and source locations in source/ and resources/)
  - Per-prompt risk assessment indicating whether clipping occurs on representative round devices
  - Decision: center-on-round-only OR center-on-all
  - Prototype notes: resource-only approach vs view-based fallback

Phase 1 — Design (deliverables)
- data-model.md (minimal; maps transient PromptContext fields used by placement logic)
- design notes inside plan.md describing chosen resource changes and helper utilities
- quickstart.md with steps to run simulator profiles and validate dialogs
- contract doc N/A (no external interfaces)

Phase 2 — Implementation (deliverables)
- Code changes:
  - resources/layouts/* (new or modified centered dialog layouts)
  - resources/menus/* (if menu placements need alternative variants)
  - source/ui/PromptUtils.mc (helper functions)
  - source/* (minor edits in views/delegates to call PromptUtils.shouldCenterPrompt and to use alternate layouts or compute centered bounds)
- Tests:
  - tests/ui/prompt_centering_test.mc (unit tests for PromptUtils)
  - simulator validation checklist (see Testing strategy)

Final polish (deliverables)
- research.md, data-model.md, quickstart.md finalized
- checklists/requirements.md updated with acceptance criteria and per-device checks
- tasks.md listing implementation subtasks and reviewers

## Device-specific constraints and measurable performance budgets and per-device checks

Constraints:
- Round displays have non-rectangular usable areas (corners are not usable) — ensure dialogs fit entirely in circular viewport.
- Small watches (low resolution) may require truncation or multi-line wrapping for long labels.

Performance budgets (measurable):
- Prompt display latency: additional centering calculation must not add more than 10ms to prompt show time on simulator (measured as time between prompt request and first draw). Target: <10ms extra overhead.
- Memory: No additional heap growth beyond a few KB for transient layout calculation; avoid allocating large buffers while computing bounds.

Per-device checks (representative list):
- fenix 6 (round, large) — verify all prompts fully visible; check latency and that timer updates remain smooth while prompt is visible.
- venu/forerunner small (square or small round depending on model) — verify readability and no overlap with critical timer UI.
- vivoactive (square) — ensure existing behavior unchanged.
- Approach: Use the Garmin simulator device profiles corresponding to these devices and run the acceptance checklist.

## Testing strategy and acceptance criteria

Simulator steps (manual/automated):
1. Start simulator profile for each target device (fenix 6, vivoactive, small round/square profile).
2. Exercise each prompt identifier from research inventory:
   - Trigger prompt in the same sequence and timing as in-app flows (e.g., during match start, pause, carding)
   - Observe and record: clipped text, button visibility, overlap with timer
3. Compare before/after (if possible) by toggling resource variants or running branch vs baseline

Automated/perf checks:
- Unit tests for PromptUtils.shouldCenterPrompt and layout math covering multiple display sizes
- Timing test: measure time between prompt request and draw (instrumented or simulated) to ensure latency budget

Unit / Integration tests:
- Unit: tests/ui/prompt_utils_test.mc — boundary cases for small width/height and long text
- Integration: tests/integration/prompt_flow_test.mc — simulate user selection flow with centered dialogs to ensure callbacks behave identically

Acceptance criteria (derived from spec success criteria):
- On representative circular watch profiles, 100% of affected prompts and dialogs appear fully within view with no clipped text or controls.
- On representative square watch profiles, affected prompts and dialogs remain usable and retain identical actions.
- No prompt/dialog flow introduces new navigation steps or changes action results.
- Prompt display latency remains within the performance budget (<10ms extra overhead for centering calculation).

## Deliverables and next steps (files to create, tests to add)

Files to create or update (paths relative to repo root):
- specs/008-centered-prompts/research.md
- specs/008-centered-prompts/data-model.md
- specs/008-centered-prompts/quickstart.md
- specs/008-centered-prompts/checklists/requirements.md
- source/ui/PromptUtils.mc (new helper)
- resources/layouts/centered_prompt.xml (new resource)
- resources/menus/* (modified as required)
- source/* edits where prompts are created (e.g., source/RugbyTimerDelegate.mc, source/RugbyConversionView.mc)
- tests/ui/prompt_centering_test.mc
- tests/integration/prompt_flow_test.mc

Next steps:
1. Phase 0: Create research.md and perform inventory on a simulator to identify affected prompts.
2. Decide resource-only vs view-fallback approach and document in data-model.md.
3. Implement PromptUtils and add resource variants for centered prompts.
4. Add unit/integration tests and run simulator checks on the representative device set.
5. Code review and merge.

## Risks & mitigations

- Risk: Some prompts generated by third-party libraries or deeply-nested flows may be hard to change via resources. Mitigation: Add view-level fallback that computes centered bounds and draws a transient centered popup.
- Risk: Long labels may require text wrapping that wasn't previously exercised. Mitigation: Ensure resource XML uses multiline labels and verify on small devices during research.

## Notes for reviewers

- Reviewers should focus on the prompt inventory (research.md) and the minimal set of source files changed to ensure no flow/logic changes were introduced.
- Verify that helper math in PromptUtils is well-tested and that resource fallbacks are present for devices with atypical bounds.

---

*Plan generated to satisfy specs/008-centered-prompts/spec.md. Implementations should remain small, resource-first, and reversible.*
