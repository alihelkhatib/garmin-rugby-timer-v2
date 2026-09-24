# Source map

| File | Responsibility | Primary coverage |
|---|---|---|
| `RugbyGameModel.mc` | Authoritative match state, timing, scoring, sanctions, events, recovery payload | `Test_RugbyGameModel.mc`, `Test_RugbyPersistence.mc` |
| `RugbyTime.mc` | Safe elapsed-time and clock formatting helpers | `Test_RugbyTime.mc` |
| `RugbyMatchController.mc` | Periodic advancement, persistence, one-shot automatic save/summary | `Test_RugbyMatchController.mc` |
| `RugbyVariantConfig.mc` | Variant presets, bounds, preference storage | `Test_RugbyVariantConfig.mc` |
| `RugbyPersistence.mc` | Versioned active-match checkpoint storage | `Test_RugbyPersistence.mc` |
| `RugbyActivityRecorder.mc` | Supported ActivityRecording lifecycle and failure state | `Test_RugbyActivityRecorder.mc` |
| `RugbyTimerDelegate.mc` | Main button state gates, confirmations, and menu routing | `Test_RugbyIdleTimerControls.mc` |
| `RugbyTeamSelectionDelegate.mc`, `RugbyTeamActionDelegate.mc` | Validated team/action menu routing | Model and manual input-flow checks |
| `RugbyTimerView.mc`, `RugbyConversionView.mc` | Snapshot rendering and visible-only refresh timers | Model helpers and simulator checks |
| `RugbyMatchSummaryView.mc` | Latest-event match summary | Model event-log tests and simulator checks |
| `RugbyLayoutSupport.mc` | Resource-layout selection | Build matrix and simulator checks |
| `RugbyHaptics.mc` | Coalesced match alerts | Model haptic-event tests and physical-device checks |
| `RugbyTimerApp.mc` | Lifecycle wiring and recovery bootstrap | Build matrix and recovery tests |

All paths above are under `source/`; test paths are under `tests/`. The active behavior specification is `specs/011-codebase-rehabilitation/spec.md`.
