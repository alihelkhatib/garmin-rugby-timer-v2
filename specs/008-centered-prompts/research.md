# Research: Center Prompts for Round Screens

## Decision 1: Center the affected bottom-screen dialogs when their current position risks clipping

- **Decision**: Move the affected prompts/dialogs into a centered visible area for the screens where the bottom placement can clip content.
- **Rationale**: The user reported clipping on circle screens. Centering the affected prompt area is the simplest way to keep full text and controls visible without changing the underlying action flow.
- **Alternatives considered**: Keeping the bottom placement and shortening text; adding per-screen text variants; redesigning all dialogs. Those options either do not solve clipping reliably or add unnecessary scope.

## Decision 2: Keep the change limited to affected match-control dialogs rather than redesigning the whole app layout

- **Decision**: Limit the fix to dialogs and prompts that are currently shown near the bottom and can clip on round watches.
- **Rationale**: The issue is localized to certain prompt/dialog presentations. Narrow scope reduces regression risk and keeps the change aligned with the feature request.
- **Alternatives considered**: Reworking every screen for round display safety. That would be broader than needed and could disturb working layouts.

## Decision 3: Preserve existing menu flow and button behavior

- **Decision**: Keep the same prompts, menu ordering, and return behavior, changing placement only.
- **Rationale**: The issue is readability, not interaction design. Users should not have to learn a different flow to get a safer layout.
- **Alternatives considered**: Introducing new confirmation steps or alternative navigation. That would add friction and is not required to fix clipping.

## Decision 4: Validate on both circular and square watch profiles

- **Decision**: Use simulator/device checks on representative round and square watch profiles to confirm the affected dialogs remain readable and usable.
- **Rationale**: The bug appears on circle screens, but the same placement change must not make square screens worse.
- **Alternatives considered**: Testing only on a round profile. That would miss regressions on the already-working square layouts.
