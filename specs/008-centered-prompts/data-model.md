# Data Model: Center Prompts for Round Screens

## Prompt/Dialog Placement

- `screenTarget`: which watch profile or screen shape is being rendered.
- `placementMode`: current presentation style used for the prompt or dialog.
- `contentBounds`: effective area available for the prompt/dialog contents.
- `isClipped`: whether the current placement would overlap the screen edge.

### Rules

- A prompt or dialog that would clip at the bottom of a circular screen should use a centered visible placement.
- The same prompt content and actions must remain available after the placement change.
- Square-screen placement should remain readable and should not require a different user path.

## Affected UI Flow

- `sourceScreen`: the menu or view that launched the prompt/dialog.
- `destinationScreen`: the prompt/dialog displayed to the user.
- `selectedAction`: the existing choice made by the user.

### Rules

- The source-to-destination flow must remain unchanged.
- Placement changes must not alter the meaning of the selected action.
- Cancel or back behavior must return to the same prior screen state.
