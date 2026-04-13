# Test summaries

This document contains short, per-test descriptions to help reviewers and maintainers quickly understand test intent.

## tests/Test_RugbyGameModel.mc
- testStartPauseResumeEndHalfSnapshot: Verifies clock start/pause/resume behaviour, derived timers (countUpSeconds, mainCountdownSeconds), and end-of-half confirmation.
- testScoringAndCorrection: Exercises try, conversion, penalty and drop goal scoring and correction of the last score.
- testIdleMainTimerAdjustmentBounds: Verifies idle timer decrement/increment clamps at 00:00 and the selected variant normal half length.
- testStartMatchUsesAdjustedIdleTimer: Verifies a match starts from the adjusted idle timer value.
- testIdleMainTimerAdjustmentIgnoredAfterHalfEnded: Verifies idle timer adjustment does not apply once a match is half-ended.
- testScoreActionsRemainAvailableAfterIdleTimerChange: Verifies try, conversion, penalty goal, and drop goal scoring still work after idle timer adjustment.
- testConversionReplacementAndAlert: Ensures conversion timers are assigned to the team that scored and that haptic alerts are queued.
- testConversionMadeAndMissClearActiveTimer: Verifies conversion success/miss clears timers and updates scores accordingly.
- testYellowAndRedCards: Tests sanction creation (yellow/red), sin-bin countdown and clearing behavior.
- testMultipleYellowCardsAndPausedHalfBoundary: Ensures sanctions persist and countdowns behave across pauses/half boundaries.
- testRenderSnapshotContainsRequiredFields: Snapshot shape validation for UI renderers.

## tests/Test_RugbyVariantConfig.mc
- testBuiltInVariantDefaults: Confirms default timing values for FIFTEENS, SEVENS, TENS, U19 variants.
- testVariantOverrides: Ensures helper functions correctly produce a CUSTOM variant with adjusted timings.
- testVariantNormalHalfBounds: Verifies idle half-length increments cannot exceed each built-in variant's normal half length.
- testVariantIdleLowerBound: Verifies repeated idle decrement reaches and remains bounded at 00:00.
- testFixedTeamLabels: Validates default team labels (Home/Away).

## tests/Test_RugbyActivityRecorder.mc
- testActivityRecorderInitialSnapshot: Verifies initial recorder snapshot state, sport and sub-sport identifiers.
- testActivityRecorderFallbackState: Verifies recorder exposes fallbackReason() as null when not started.

## tests/Test_RugbyIdleTimerControls.mc
- testIdleUpMenuIncrementsTimerAndBlocksScoreDialog: Verifies idle Up/Menu increments the timer and keeps score dialog blocked.
- testIdleDownDecrementsTimerAndBlocksMenus: Verifies idle Down decrements the timer and keeps score/card menus blocked.
- testMatchEndedBlocksScoreDialog: Verifies match-ended state blocks score dialog access.
- testActiveMatchScoreDialogStates: Verifies running, paused, and half-ended states allow score dialog access.
- testActiveMatchCardDialogStates: Verifies running, paused, and half-ended states preserve card dialog access.
