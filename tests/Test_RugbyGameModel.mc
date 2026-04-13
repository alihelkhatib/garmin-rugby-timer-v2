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


