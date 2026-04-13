# Test summaries

This document contains short, per-test descriptions to help reviewers and maintainers quickly understand test intent.

## tests/Test_RugbyGameModel.mc
- testStartPauseResumeEndHalfSnapshot: Verifies clock start/pause/resume behaviour, derived timers (countUpSeconds, mainCountdownSeconds), and end-of-half confirmation.
- testScoringAndCorrection: Exercises try, conversion, penalty and drop goal scoring and correction of the last score.
- testConversionReplacementAndAlert: Ensures conversion timers are assigned to the team that scored and that haptic alerts are queued.
- testConversionMadeAndMissClearActiveTimer: Verifies conversion success/miss clears timers and updates scores accordingly.
- testYellowAndRedCards: Tests sanction creation (yellow/red), sin-bin countdown and clearing behavior.
- testMultipleYellowCardsAndPausedHalfBoundary: Ensures sanctions persist and countdowns behave across pauses/half boundaries.
- testRenderSnapshotContainsRequiredFields: Snapshot shape validation for UI renderers.

## tests/Test_RugbyVariantConfig.mc
- testBuiltInVariantDefaults: Confirms default timing values for FIFTEENS, SEVENS, TENS, U19 variants.
- testVariantOverrides: Ensures helper functions correctly produce a CUSTOM variant with adjusted timings.
- testFixedTeamLabels: Validates default team labels (Home/Away).

## tests/Test_RugbyActivityRecorder.mc
- testActivityRecorderInitialSnapshot: Verifies initial recorder snapshot state, sport and sub-sport identifiers.
- testActivityRecorderFallbackState: Verifies recorder exposes fallbackReason() as null when not started.
