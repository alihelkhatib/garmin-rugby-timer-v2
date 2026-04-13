# Extra tasks: Activity recording markers

T071 [P] [US7] Implement activity event markers in RugbyActivityRecorder
- Add a recorder API to record per-event markers/laps with the agreed schema.
- Ensure markers are written to the ActivityRecording session when possible and to a sidecar fallback when not.
- Files: source/RugbyActivityRecorder.mc

T072 [P] [US7] Wire model events to recorder
- Emit marker calls on scoring, conversion made/miss, penalties, drop goals, yellow/red card issuance, substitutions, and manual stoppage adjustments.
- Files: source/RugbyGameModel.mc, source/RugbyTimerDelegate.mc

T073 [P] [US7] Add tests for activity recording markers
- Extend tests/Test_RugbyActivityRecorder.mc and tests/Test_RugbyGameModel.mc to assert markers are recorded with correct event_type and timestamps or present in the fallback sidecar.
