# Match Control and UI Contract

## Controller tick

`tick(nowMs)` performs one model advance using `nowMs`, persists any resulting mutation, dispatches one-shot haptics/recording effects, and returns a render snapshot plus navigation intent. Repeating the same tick without a new transition must not repeat an external effect.

## User actions

- Start/Select: start, pause, resume, or confirm the explicitly displayed pending action according to current state.
- Up/Menu before kickoff: open the variant picker or adjust the pre-match clock according to the device's documented mapping.
- Score during an active match: choose team, then event type; a try opens the conversion flow.
- Card during an active match: choose team, then yellow/red; issuing a card pauses a running match once.
- Back during an active match: open period, event, summary, reset, recoverable exit, and terminal Stop & exit options. End, Stop & exit, and Reset require a second explicit confirmation. Back exits normally before kickoff and after completion.
- Conversion flow: Made applies two points once; Miss/Back closes without points. Countdown follows wall time.

## View lifecycle

- `onShow`: synchronize state and start only the timers required by the visible state.
- `onUpdate`: bind one already-evaluated snapshot and draw bounded dynamic visuals; no authoritative state or external side effects.
- Refresh callback: request a controller tick/redraw only.
- `onHide`: stop and release all view-owned timers.

## Recovery

- Persist after meaningful match mutations and normal application stop.
- Normalize a running match to paused before storage.
- Restore valid supported snapshots as paused and visibly identify the state.
- Reset/discard clears active recovery. Invalid data falls back to a new match without throwing.

## Recording

- First match start requests recording once.
- End match requests stop/save once and opens the summary regardless of export success.
- Stop & exit ends the match, requests stop/save once, clears recovery, and closes the app after confirmation.
- Exit & save stops/saves the current segment, checkpoints the active match, and closes for later paused recovery.
- Reset requests discard once.
- Repeated or delayed UI callbacks never repeat start/save/discard.

## Rendering

- The main countdown is the largest element.
- State and card meaning is conveyed by text/position as well as color.
- Static labels and positions come from resources.
- Dynamic summary rows are capped to visible space and clearly report additional events.
