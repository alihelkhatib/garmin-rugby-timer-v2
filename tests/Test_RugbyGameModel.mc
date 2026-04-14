/*
Test: tests/Test_RugbyGameModel.mc

What this test file covers:
- Validates RugbyGameModel behaviour: start/pause/resume, half transitions, scoring, conversion handling, sanctions (yellow/red), haptic events and snapshot structure.

How to run locally:
- See docs/testing.md for SDK and CLI commands.
- Example:
    monkeyc -f monkey.jungle -o build/garmin-rugby-timer.prg
    monkeydo -s fenix6 build/garmin-rugby-timer.prg
- Tests run automatically at app startup via Toybox.Test.

Key assertions/behaviours under test:
- Clock state transitions and derived timers (countUpSeconds, mainCountdownSeconds).
- Scoring and correction logic (try, conversion, penalty, drop goal).
- Conversion timers start/clear and generate haptic events.
- Sanction lifecycle across pause/resume and clearing behaviour.
- Snapshot provides required fields for UI rendering.

Preconditions / setup:
- newTestModel() constructs a RugbyGameModel using the default FIFTEENS variant.
- No external services required.
*/

using Toybox.Test;

function newTestModel() {
    return new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS));
}

(:test)
function testStartPauseResumeEndHalfSnapshot(logger) {
    var model = newTestModel();
    model.startMatch(1000);
    var running = model.snapshot(61000);
    // Expect the clock to be running after start and the first tick
    Test.assertEqual(RUGBY_STATE_RUNNING, running["clockState"]);
    // Count-up should reflect ~60 seconds since the start (ms -> s)
    Test.assertEqual(60, running["countUpSeconds"]);
    // Main countdown should be half length minus elapsed seconds
    Test.assertEqual((40 * 60) - 60, running["mainCountdownSeconds"]);

    model.pause(61000);
    var paused = model.snapshot(120000);
    // After pause, the clock state should be paused and countUp frozen
    Test.assertEqual(RUGBY_STATE_PAUSED, paused["clockState"]);
    Test.assertEqual(60, paused["countUpSeconds"]);

    model.resume(130000);
    var resumed = model.snapshot(190000);
    // After resume and further time, countUp should increase
    Test.assertEqual(120, resumed["countUpSeconds"]);

    model.requestEndHalf();
    // confirmPending should report the pending end-of-half confirmation
    Test.assertEqual(true, model.confirmPending(190000));
    var halfEnded = model.snapshot(190000);
    // Snapshot should reflect half-ended state and next half index
    Test.assertEqual(RUGBY_STATE_HALF_ENDED, halfEnded["clockState"]);
    Test.assertEqual(2, halfEnded["halfIndex"]);
}

(:test)
function testCountdownExpiryHelpers(logger) {
    var model = newTestModel();
    model.startMatch(0);

    Test.assertEqual(false, model.isFinalPeriod());
    Test.assertEqual(false, model.isRunningCountdownExpired((40 * 60 * 1000) - 1000));
    Test.assertEqual(true, model.isRunningCountdownExpired(40 * 60 * 1000));

    model.requestEndHalf();
    Test.assertEqual(true, model.confirmPending(40 * 60 * 1000));
    Test.assertEqual(true, model.isFinalPeriod());
}

(:test)
function testNonFinalPeriodAutoEndsAtCountdownExpiry(logger) {
    var model = newTestModel();
    model.startMatch(0);

    var beforeExpiry = model.snapshot((40 * 60 * 1000) - 1000);
    Test.assertEqual(RUGBY_STATE_RUNNING, beforeExpiry["clockState"]);
    Test.assertEqual(1, beforeExpiry["mainCountdownSeconds"]);

    var expired = model.snapshot(40 * 60 * 1000);
    Test.assertEqual(RUGBY_STATE_HALF_ENDED, expired["clockState"]);
    Test.assertEqual(2, expired["halfIndex"]);
    Test.assertEqual(40 * 60, expired["mainCountdownSeconds"]);
    Test.assertEqual(0, expired["countUpSeconds"]);

    model.startMatch((40 * 60 * 1000) + 1000);
    var nextHalf = model.snapshot((40 * 60 * 1000) + 61000);
    Test.assertEqual(RUGBY_STATE_RUNNING, nextHalf["clockState"]);
    Test.assertEqual(2, nextHalf["halfIndex"]);
    Test.assertEqual((40 * 60) - 60, nextHalf["mainCountdownSeconds"]);
}

(:test)
function testManualEndHalfStillUsesBetweenPeriodState(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.requestEndHalf();

    Test.assertEqual(true, model.confirmPending(10000));
    var snap = model.snapshot(10000);
    Test.assertEqual(RUGBY_STATE_HALF_ENDED, snap["clockState"]);
    Test.assertEqual(2, snap["halfIndex"]);
    Test.assertEqual(40 * 60, snap["mainCountdownSeconds"]);
}

(:test)
function testFinalPeriodAutoEndsMatchAtCountdownExpiry(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.requestEndHalf();
    Test.assertEqual(true, model.confirmPending(1000));
    model.startMatch(2000);

    var beforeExpiry = model.snapshot(2000 + (40 * 60 * 1000) - 1000);
    Test.assertEqual(RUGBY_STATE_RUNNING, beforeExpiry["clockState"]);
    Test.assertEqual(2, beforeExpiry["halfIndex"]);
    Test.assertEqual(1, beforeExpiry["mainCountdownSeconds"]);

    var expired = model.snapshot(2000 + (40 * 60 * 1000));
    Test.assertEqual(RUGBY_STATE_MATCH_ENDED, expired["clockState"]);
    Test.assertEqual(true, expired["matchSummaryVisible"]);
    Test.assertEqual(true, expired["autoMatchEndPendingSave"]);
    Test.assertEqual(true, model.consumeAutoMatchEndPendingSave());
    Test.assertEqual(false, model.consumeAutoMatchEndPendingSave());
    Test.assertEqual(0, expired["mainCountdownSeconds"]);
}

(:test)
function testFinalPeriodAutoEndPreservesSummaryState(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 10000);
    model.startYellowCard(RUGBY_TEAM_AWAY, 20000);
    model.requestEndHalf();
    Test.assertEqual(true, model.confirmPending(30000));
    model.startMatch(40000);
    model.recordPenaltyGoalAt(RUGBY_TEAM_AWAY, 50000);

    var expired = model.snapshot(40000 + (40 * 60 * 1000));
    Test.assertEqual(RUGBY_STATE_MATCH_ENDED, expired["clockState"]);
    Test.assertEqual(5, expired["home"]["score"]);
    Test.assertEqual(3, expired["away"]["score"]);
    Test.assertEqual(3, expired["eventLog"].size());
    Test.assertEqual("expired", expired["sanctions"][0]["state"]);
}

(:test)
function testManualEndMatchStillShowsSummary(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 10000);
    model.endMatch(20000);

    var snap = model.snapshot(20000);
    Test.assertEqual(RUGBY_STATE_MATCH_ENDED, snap["clockState"]);
    Test.assertEqual(true, snap["matchSummaryVisible"]);
    Test.assertEqual(false, snap["autoMatchEndPendingSave"]);
    Test.assertEqual(1, snap["eventLog"].size());
}

(:test)
function testScoringAndCorrection(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 1000);
    model.recordConversion(RUGBY_TEAM_HOME);
    model.recordPenaltyGoal(RUGBY_TEAM_HOME);
    model.recordDropGoal(RUGBY_TEAM_HOME);
    var snap = model.snapshot(1000);
    // Total score: try(5) + conversion(2) + penalty(3) + drop(3) = 13
    Test.assertEqual(13, snap["home"]["score"]);
    // Each scoring counter should increment appropriately
    Test.assertEqual(1, snap["home"]["tryCount"]);
    Test.assertEqual(1, snap["home"]["conversionCount"]);
    Test.assertEqual(1, snap["home"]["penaltyGoalCount"]);
    Test.assertEqual(1, snap["home"]["dropGoalCount"]);

    // Correcting the last score (drop goal) should return true and adjust totals
    Test.assertEqual(true, model.correctScore(RUGBY_TEAM_HOME, RUGBY_SCORE_DROP_GOAL));
    snap = model.snapshot(1000);
    Test.assertEqual(10, snap["home"]["score"]);
    Test.assertEqual(0, snap["home"]["dropGoalCount"]);
}

(:test)
function testIdleMainTimerAdjustmentBounds(logger) {
    var model = new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_SEVENS));

    for (var i = 0; i < 8; i += 1) {
        model.adjustIdleMainTimer(-1);
    }
    var snap = model.snapshot(0);
    Test.assertEqual(0, snap["mainCountdownSeconds"]);

    for (var j = 0; j < 8; j += 1) {
        model.adjustIdleMainTimer(1);
    }
    snap = model.snapshot(0);
    Test.assertEqual(7 * 60, snap["mainCountdownSeconds"]);
}

(:test)
function testStartMatchUsesAdjustedIdleTimer(logger) {
    var model = newTestModel();
    for (var i = 0; i < 5; i += 1) {
        model.adjustIdleMainTimer(-1);
    }

    var idle = model.snapshot(0);
    Test.assertEqual(35 * 60, idle["mainCountdownSeconds"]);

    model.startMatch(1000);
    var running = model.snapshot(61000);
    Test.assertEqual(RUGBY_STATE_RUNNING, running["clockState"]);
    Test.assertEqual((35 * 60) - 60, running["mainCountdownSeconds"]);
}

(:test)
function testIdleMainTimerAdjustmentIgnoredAfterHalfEnded(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.requestEndHalf();
    Test.assertEqual(true, model.confirmPending(1000));

    model.adjustIdleMainTimer(-5);
    var snap = model.snapshot(1000);
    Test.assertEqual(RUGBY_STATE_HALF_ENDED, snap["clockState"]);
    Test.assertEqual(40 * 60, snap["mainCountdownSeconds"]);
}

(:test)
function testScoreActionsRemainAvailableAfterIdleTimerChange(logger) {
    var model = newTestModel();
    model.adjustIdleMainTimer(-1);
    model.startMatch(0);

    model.recordTry(RUGBY_TEAM_HOME, 1000);
    Test.assertEqual(true, model.recordConversion(RUGBY_TEAM_HOME));
    model.recordPenaltyGoal(RUGBY_TEAM_HOME);
    model.recordDropGoal(RUGBY_TEAM_HOME);

    var snap = model.snapshot(1000);
    Test.assertEqual(13, snap["home"]["score"]);
    Test.assertEqual(1, snap["home"]["tryCount"]);
    Test.assertEqual(1, snap["home"]["conversionCount"]);
    Test.assertEqual(1, snap["home"]["penaltyGoalCount"]);
    Test.assertEqual(1, snap["home"]["dropGoalCount"]);
}

(:test)
function testConversionReplacementAndAlert(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 1000);
    model.recordTry(RUGBY_TEAM_AWAY, 2000);
    var snap = model.snapshot(32000);
    // Conversion timer should be active for the team that last scored
    Test.assertEqual(RUGBY_TEAM_AWAY, snap["conversionTimer"]["teamId"]);
    // Conversion window length should match variant default
    Test.assertEqual(60, snap["conversionTimer"]["remainingSeconds"]);
    // Recording a conversion should have queued a haptic event (alert)
    Test.assertEqual(1, snap["hapticEvents"].size());
}


(:test)
function testConversionMadeAndMissClearActiveTimer(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 1000);
    var snap = model.snapshot(1000);
    // Conversion timer present immediately after a try
    Test.assertNotEqual(null, snap["conversionTimer"]);

    // Recording a successful conversion should add score and clear conversion timer
    Test.assertEqual(true, model.recordConversion(RUGBY_TEAM_HOME));
    snap = model.snapshot(1000);
    Test.assertEqual(7, snap["home"]["score"]);
    Test.assertEqual(1, snap["home"]["conversionCount"]);
    Test.assertEqual(null, snap["conversionTimer"]);

    // New try by away team should create a new conversion timer
    model.recordTry(RUGBY_TEAM_AWAY, 2000);
    snap = model.snapshot(2000);
    Test.assertNotEqual(null, snap["conversionTimer"]);
    // Missing the conversion should keep score correct and clear the timer
    Test.assertEqual(true, model.missConversion());
    snap = model.snapshot(2000);
    Test.assertEqual(5, snap["away"]["score"]);
    Test.assertEqual(0, snap["away"]["conversionCount"]);
    Test.assertEqual(null, snap["conversionTimer"]);
}

(:test)
function testPausedTryStartsWallClockConversionTimer(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.pause(10000);

    model.recordTry(RUGBY_TEAM_HOME, 20000);
    var snap = model.snapshot(20000);
    Test.assertEqual(RUGBY_STATE_PAUSED, snap["clockState"]);
    Test.assertNotEqual(null, snap["conversionTimer"]);
    Test.assertEqual(90, snap["conversionTimer"]["remainingSeconds"]);

    snap = model.snapshot(50000);
    Test.assertEqual(RUGBY_STATE_PAUSED, snap["clockState"]);
    Test.assertEqual(60, snap["conversionTimer"]["remainingSeconds"]);
}

(:test)
function testNonTryScoresDoNotStartConversionTimer(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.pause(10000);

    model.recordPenaltyGoalAt(RUGBY_TEAM_HOME, 20000);
    var snap = model.snapshot(20000);
    Test.assertEqual(null, snap["conversionTimer"]);

    model.recordDropGoalAt(RUGBY_TEAM_AWAY, 30000);
    snap = model.snapshot(30000);
    Test.assertEqual(null, snap["conversionTimer"]);
}

(:test)
function testPauseReminderStateIsInSnapshot(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.pause(10000);
    var snap = model.snapshot(10000);

    Test.assertEqual(RUGBY_STATE_PAUSED, snap["clockState"]);
    Test.assertEqual(RUGBY_PAUSE_REMINDER_INTERVAL_MS, snap["pauseReminderIntervalMs"]);
}

(:test)
function testYellowAndRedCards(logger) {

    var model = newTestModel();
    model.startMatch(0);
    var yellow = model.startYellowCard(RUGBY_TEAM_HOME, 0);
    var red = model.recordRedCard(RUGBY_TEAM_AWAY, 0);
    var snap = model.snapshot((9 * 60 * 1000));
    // Sanctions list should contain both yellow and red entries
    Test.assertEqual(2, snap["sanctions"].size());
    // The first sanction should have remaining sin-bin seconds as configured
    Test.assertEqual(60, snap["sanctions"][0]["remainingSeconds"]);
    // Haptic event(s) should have been queued for sanctions
    Test.assertEqual(1, snap["hapticEvents"].size());
    // Clearing a sanction should return true and remove it from the list
    Test.assertEqual(true, model.clearSanction(red));
    snap = model.snapshot((9 * 60 * 1000));
    Test.assertEqual(1, snap["sanctions"].size());
}

(:test)
function testCardsPauseRunningMatch(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.startYellowCard(RUGBY_TEAM_HOME, 10000);
    var snap = model.snapshot(10000);
    Test.assertEqual(RUGBY_STATE_PAUSED, snap["clockState"]);

    model.resume(20000);
    model.recordRedCard(RUGBY_TEAM_AWAY, 30000);
    snap = model.snapshot(30000);
    Test.assertEqual(RUGBY_STATE_PAUSED, snap["clockState"]);
}

(:test)
function testSameTeamYellowTimersAndRedMarkerState(logger) {
    var model = newTestModel();
    var view = new RugbyTimerView(model);
    model.startMatch(0);
    model.startYellowCard(RUGBY_TEAM_HOME, 0);
    model.resume(300000);
    model.startYellowCard(RUGBY_TEAM_HOME, 300000);
    model.recordRedCard(RUGBY_TEAM_HOME, 300000);

    var snap = model.snapshot(300000);
    var yellowLabel = view.teamYellowCardTimerLabel(snap["sanctions"], RUGBY_TEAM_HOME);

    Test.assertEqual("5:00 10:00", yellowLabel);
    Test.assertEqual(true, view.teamHasRedCard(snap["sanctions"], RUGBY_TEAM_HOME));
}

(:test)
function testEventLogRecordsScoringAndCards(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 10000);
    model.recordConversionAt(RUGBY_TEAM_HOME, 20000);
    model.recordPenaltyGoalAt(RUGBY_TEAM_AWAY, 30000);
    model.recordDropGoalAt(RUGBY_TEAM_HOME, 40000);
    model.startYellowCard(RUGBY_TEAM_AWAY, 50000);
    model.recordRedCard(RUGBY_TEAM_HOME, 60000);

    var events = model.eventLog();
    Test.assertEqual(6, events.size());
    Test.assertEqual(RUGBY_TEAM_HOME, events[0]["teamId"]);
    Test.assertEqual(RUGBY_SCORE_TRY, events[0]["action"]);
    Test.assertEqual(10, events[0]["matchElapsedSeconds"]);
    Test.assertEqual(RUGBY_EVENT_CONVERSION_MADE, events[1]["action"]);
    Test.assertEqual(RUGBY_SCORE_PENALTY_GOAL, events[2]["action"]);
    Test.assertEqual(RUGBY_SCORE_DROP_GOAL, events[3]["action"]);
    Test.assertEqual("yellowCard", events[4]["action"]);
    Test.assertEqual("redCard", events[5]["action"]);
}

(:test)
function testEventLogClearsOnResetAndNewMatch(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 10000);
    Test.assertEqual(1, model.eventLog().size());

    model.resetMatch();
    var reset = model.snapshot(10000);
    Test.assertEqual(RUGBY_STATE_NOT_STARTED, reset["clockState"]);
    Test.assertEqual(0, model.eventLog().size());
    Test.assertEqual(0, reset["home"]["score"]);

    model.startMatch(20000);
    model.recordTry(RUGBY_TEAM_AWAY, 30000);
    Test.assertEqual(1, model.eventLog().size());
    model.endMatch(40000);
    Test.assertEqual(true, model.snapshot(40000)["matchSummaryVisible"]);
    model.resetMatch();
    Test.assertEqual(0, model.eventLog().size());
}

(:test)
function testMultipleYellowCardsAndPausedHalfBoundary(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.startYellowCard(RUGBY_TEAM_HOME, 0);
    model.startYellowCard(RUGBY_TEAM_AWAY, 1000);
    model.pause(10000);
    var paused = model.snapshot(60000);
    // Two sanctions should be active concurrently
    Test.assertEqual(2, paused["sanctions"].size());
    // Remaining seconds for a sanction should not advance while paused
    Test.assertEqual(paused["sanctions"][0]["remainingSeconds"], model.snapshot(120000)["sanctions"][0]["remainingSeconds"]);
}

(:test)
function testYellowCardCarriesForwardAcrossAutoPeriodEnd(logger) {
    var model = newTestModel();
    var view = new RugbyTimerView(model);
    model.startMatch(0);
    model.startYellowCard(RUGBY_TEAM_HOME, 39 * 60 * 1000);
    model.resume(39 * 60 * 1000);

    var halfEnded = model.snapshot(40 * 60 * 1000);
    Test.assertEqual(RUGBY_STATE_HALF_ENDED, halfEnded["clockState"]);
    Test.assertEqual("pausedForPeriod", halfEnded["sanctions"][0]["state"]);
    Test.assertEqual(9 * 60, halfEnded["sanctions"][0]["remainingSeconds"]);
    Test.assertEqual(RUGBY_TEAM_HOME, halfEnded["sanctions"][0]["teamId"]);
    Test.assertEqual("9:00", view.teamYellowCardTimerLabel(halfEnded["sanctions"], RUGBY_TEAM_HOME));

    model.startMatch((40 * 60 * 1000) + 1000);
    var nextHalf = model.snapshot((41 * 60 * 1000) + 1000);
    Test.assertEqual(RUGBY_STATE_RUNNING, nextHalf["clockState"]);
    Test.assertEqual("active", nextHalf["sanctions"][0]["state"]);
    Test.assertEqual(8 * 60, nextHalf["sanctions"][0]["remainingSeconds"]);
}

(:test)
function testMultipleYellowCardsCarryForwardWithTeams(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.startYellowCard(RUGBY_TEAM_HOME, 38 * 60 * 1000);
    model.resume(38 * 60 * 1000);
    model.startYellowCard(RUGBY_TEAM_AWAY, 39 * 60 * 1000);
    model.resume(39 * 60 * 1000);

    var halfEnded = model.snapshot(40 * 60 * 1000);
    Test.assertEqual(RUGBY_STATE_HALF_ENDED, halfEnded["clockState"]);
    Test.assertEqual(2, halfEnded["sanctions"].size());
    Test.assertEqual(RUGBY_TEAM_HOME, halfEnded["sanctions"][0]["teamId"]);
    Test.assertEqual(8 * 60, halfEnded["sanctions"][0]["remainingSeconds"]);
    Test.assertEqual(RUGBY_TEAM_AWAY, halfEnded["sanctions"][1]["teamId"]);
    Test.assertEqual(9 * 60, halfEnded["sanctions"][1]["remainingSeconds"]);

    model.startMatch((40 * 60 * 1000) + 1000);
    var nextHalf = model.snapshot((40 * 60 * 1000) + 31000);
    Test.assertEqual("active", nextHalf["sanctions"][0]["state"]);
    Test.assertEqual((8 * 60) - 30, nextHalf["sanctions"][0]["remainingSeconds"]);
    Test.assertEqual("active", nextHalf["sanctions"][1]["state"]);
    Test.assertEqual((9 * 60) - 30, nextHalf["sanctions"][1]["remainingSeconds"]);
}

(:test)
function testExpiredYellowCardDoesNotReviveAcrossAutoPeriodEnd(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.startYellowCard(RUGBY_TEAM_HOME, 30 * 60 * 1000);
    model.resume(30 * 60 * 1000);

    var halfEnded = model.snapshot(40 * 60 * 1000);
    Test.assertEqual(RUGBY_STATE_HALF_ENDED, halfEnded["clockState"]);
    Test.assertEqual("expired", halfEnded["sanctions"][0]["state"]);
    Test.assertEqual(0, halfEnded["sanctions"][0]["remainingSeconds"]);

    model.startMatch((40 * 60 * 1000) + 1000);
    var nextHalf = model.snapshot((40 * 60 * 1000) + 61000);
    Test.assertEqual("expired", nextHalf["sanctions"][0]["state"]);
    Test.assertEqual(0, nextHalf["sanctions"][0]["remainingSeconds"]);
}

(:test)
function testPausedAtZeroDoesNotAutoTransition(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.pause(40 * 60 * 1000);

    var paused = model.snapshot((40 * 60 * 1000) + 60000);
    Test.assertEqual(RUGBY_STATE_PAUSED, paused["clockState"]);
    Test.assertEqual(0, paused["mainCountdownSeconds"]);
    Test.assertEqual(1, paused["halfIndex"]);
}

(:test)
function testRedCardAndConversionRemainUnchangedAroundAutoPeriodEnd(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, (39 * 60 * 1000) + 50000);
    model.recordRedCard(RUGBY_TEAM_AWAY, (39 * 60 * 1000) + 55000);
    model.resume((39 * 60 * 1000) + 55000);

    var halfEnded = model.snapshot(40 * 60 * 1000);
    Test.assertEqual(RUGBY_STATE_HALF_ENDED, halfEnded["clockState"]);
    Test.assertNotEqual(null, halfEnded["conversionTimer"]);
    Test.assertEqual(RUGBY_TEAM_HOME, halfEnded["conversionTimer"]["teamId"]);
    Test.assertEqual(RUGBY_CARD_RED, halfEnded["sanctions"][0]["cardType"]);
    Test.assertEqual("active", halfEnded["sanctions"][0]["state"]);
    Test.assertEqual(null, halfEnded["sanctions"][0]["remainingSeconds"]);
}

(:test)
function testRenderSnapshotContainsRequiredFields(logger) {
    var model = newTestModel();
    model.startMatch(0);
    var snap = model.snapshot(1000);
    // Snapshot shape must include fields used by UI renderers
    Test.assertNotEqual(null, snap["mainCountdownSeconds"]);
    Test.assertNotEqual(null, snap["countUpSeconds"]);
    Test.assertNotEqual(null, snap["halfIndex"]);
    Test.assertNotEqual(null, snap["home"]);
    Test.assertNotEqual(null, snap["away"]);
}
