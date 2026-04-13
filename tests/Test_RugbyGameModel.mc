using Toybox.Test;

function newTestModel() {
    return new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS));
}

(:test)
function testStartPauseResumeEndHalfSnapshot(logger) {
    var model = newTestModel();
    model.startMatch(1000);
    var running = model.snapshot(61000);
    Test.assertEqual(RUGBY_STATE_RUNNING, running["clockState"]);
    Test.assertEqual(60, running["countUpSeconds"]);
    Test.assertEqual((40 * 60) - 60, running["mainCountdownSeconds"]);

    model.pause(61000);
    var paused = model.snapshot(120000);
    Test.assertEqual(RUGBY_STATE_PAUSED, paused["clockState"]);
    Test.assertEqual(60, paused["countUpSeconds"]);

    model.resume(130000);
    var resumed = model.snapshot(190000);
    Test.assertEqual(120, resumed["countUpSeconds"]);

    model.requestEndHalf();
    Test.assertEqual(true, model.confirmPending(190000));
    var halfEnded = model.snapshot(190000);
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
    Test.assertEqual(13, snap["home"]["score"]);
    Test.assertEqual(1, snap["home"]["tryCount"]);
    Test.assertEqual(1, snap["home"]["conversionCount"]);
    Test.assertEqual(1, snap["home"]["penaltyGoalCount"]);
    Test.assertEqual(1, snap["home"]["dropGoalCount"]);

    Test.assertEqual(true, model.correctScore(RUGBY_TEAM_HOME, RUGBY_SCORE_DROP_GOAL));
    snap = model.snapshot(1000);
    Test.assertEqual(10, snap["home"]["score"]);
    Test.assertEqual(0, snap["home"]["dropGoalCount"]);
}

(:test)
function testConversionReplacementAndAlert(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 1000);
    model.recordTry(RUGBY_TEAM_AWAY, 2000);
    var snap = model.snapshot(32000);
    Test.assertEqual(RUGBY_TEAM_AWAY, snap["conversionTimer"]["teamId"]);
    Test.assertEqual(60, snap["conversionTimer"]["remainingSeconds"]);
    Test.assertEqual(1, snap["hapticEvents"].size());
}


(:test)
function testConversionMadeAndMissClearActiveTimer(logger) {
    var model = newTestModel();
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 1000);
    var snap = model.snapshot(1000);
    Test.assertNotEqual(null, snap["conversionTimer"]);

    Test.assertEqual(true, model.recordConversion(RUGBY_TEAM_HOME));
    snap = model.snapshot(1000);
    Test.assertEqual(7, snap["home"]["score"]);
    Test.assertEqual(1, snap["home"]["conversionCount"]);
    Test.assertEqual(null, snap["conversionTimer"]);

    model.recordTry(RUGBY_TEAM_AWAY, 2000);
    snap = model.snapshot(2000);
    Test.assertNotEqual(null, snap["conversionTimer"]);
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
    Test.assertEqual(2, snap["sanctions"].size());
    Test.assertEqual(60, snap["sanctions"][0]["remainingSeconds"]);
    Test.assertEqual(1, snap["hapticEvents"].size());
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
    Test.assertEqual(2, paused["sanctions"].size());
    Test.assertEqual(paused["sanctions"][0]["remainingSeconds"], model.snapshot(120000)["sanctions"][0]["remainingSeconds"]);
}

(:test)
function testRenderSnapshotContainsRequiredFields(logger) {
    var model = newTestModel();
    model.startMatch(0);
    var snap = model.snapshot(1000);
    Test.assertNotEqual(null, snap["mainCountdownSeconds"]);
    Test.assertNotEqual(null, snap["countUpSeconds"]);
    Test.assertNotEqual(null, snap["halfIndex"]);
    Test.assertNotEqual(null, snap["home"]);
    Test.assertNotEqual(null, snap["away"]);
}



