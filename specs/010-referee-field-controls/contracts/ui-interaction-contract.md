# UI Interaction Contract: Referee Field Controls

## Scope

This contract defines physical-button behavior and visible state for undo, time-up overtime, and scrollable match summary. It is intended for implementation and regression tests, not as an external API.

## Main Timer Screen

### Select/Start

- Before match start: starts the match and activity recording as today.
- Running: pauses the match.
- Paused: resumes the match.
- Half-ended: starts the next half.
- Time-up overtime: preserves pause/resume behavior and does not confirm period or match end.
- Match-ended: no new match mutation.

### Back

- If a pending confirmation exists: cancels the pending confirmation.
- Active, paused, half-ended, time-up, or match-ended: opens the Back-button match menu.
- Pre-match/reset: exits according to existing app behavior.

### Up/Menu

- Pre-match: keeps existing variant/timer adjustment behavior.
- Active, paused, half-ended, or time-up: opens score flow according to existing match-state rules.

### Down

- Pre-match: keeps existing timer adjustment behavior.
- Active, paused, half-ended, or time-up: opens card flow according to existing match-state rules.

## Back-Button Match Menu

Menu actions are state-dependent:

| State | Required actions |
|-------|------------------|
| Active | End match, Match summary, Undo last event when available, Reset match |
| Paused | End match, Match summary, Undo last event when available, Reset match |
| Half-ended | End match, Match summary, Undo last event when available, Reset match |
| Time-up non-final period | End half, Match summary, Undo last event when available, Reset match |
| Time-up final period | End match, Match summary, Undo last event when available, Reset match |
| Match-ended | Match summary, Undo last event when available, Reset match or exit per existing behavior |
| Pre-match/reset | No match summary or undo action |

Confirmation rules:

- Undo last event requires explicit confirmation before state changes.
- End half/end match/reset require confirmation according to existing guarded-action pattern.
- Back cancels confirmation without mutation.

## Time-Up Overtime Display

When regulation reaches zero:

- Main countdown displays `0:00`.
- Status clearly indicates `TIME` or equivalent time-up label.
- Overtime duration remains visible or reachable without hiding critical score/card/conversion state.
- Time-up haptic fires once per period.
- Score/card/conversion flows remain available unless existing rules block them.

## Match Summary View

Entry:

- Opened from the Back-button match menu in active, paused, half-ended, time-up, and match-ended states.

Ordering:

- Newest event appears first on initial display.
- Older events are reached by scrolling down through the list.

Navigation:

- Up moves toward newer events when available.
- Down moves toward older events when available.
- Back exits to prior match context.
- Select may also exit only if that matches existing summary behavior and does not mutate match state.

Empty state:

- If no events exist, show a clear empty message.

State preservation:

- Entering, scrolling, and exiting summary does not change timer, score, card, conversion, activity-recording, or pending confirmation state.

## Undo Last Event

Entry:

- Available from the Back-button match menu only when at least one latest score/card event can be undone.

Behavior:

- Confirmation accepted: reverse latest score/card event and remove it from the summary.
- Confirmation canceled: no state change.
- No eligible event: action absent or disabled.

Expected rollback:

- Try: remove 5 points and try count; clear related active conversion opportunity if it was created by that try and remains active.
- Conversion: remove 2 points and conversion count only.
- Penalty goal: remove 3 points and penalty goal count.
- Drop goal: remove 3 points and drop goal count.
- Yellow card: remove only the sanction created by that event.
- Red card: remove only the sanction created by that event.
