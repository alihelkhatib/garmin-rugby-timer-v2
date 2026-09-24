# Test Suite

`tests/monkey.jungle` combines production source with Toybox.Test files only for unit-test builds. Tests are never included in the production jungle.

Main suites:

- `Test_RugbyGameModel.mc`: match state, timing, scores, conversions, cards, events, and boundaries.
- `Test_RugbyIdleTimerControls.mc`: delegate input mapping and state gates.
- `Test_RugbyVariantConfig.mc`: preset rules and bounds.
- `Test_RugbyActivityRecorder.mc`: supported fallback and terminal states.
- `Test_RugbyTime.mc`: shared elapsed-time and formatting helpers.
- `Test_RugbyPersistence.mc`: recovery validation and paused restoration.
- `Test_RugbyMatchController.mc`: one-shot automatic match save.
- `Test_RugbyLayoutSupport.mc`: validated display-family routing, including the Instinct inset layout.

See `docs/testing.md` for commands and simulator validation.
