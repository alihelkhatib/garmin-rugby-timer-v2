using Toybox.Test;

(:test)
function testRunningRecoveryRestoresPaused(logger) {
    var original = newTestModel();
    original.startMatch(1000);
    original.recordTry(RUGBY_TEAM_HOME, 11000);
    var saved = original.recoverySnapshot(61000);

    var restored = newTestModel();
    Test.assert(restored.restoreRecovery(saved, 90000));
    var snap = restored.snapshot(120000);
    Test.assertEqual(RUGBY_STATE_PAUSED, snap["clockState"]);
    Test.assertEqual(60, snap["countUpSeconds"]);
    Test.assertEqual(5, snap["home"]["score"]);
    return true;
}

(:test)
function testMalformedRecoveryIsRejected(logger) {
    var restored = newTestModel();
    Test.assert(!restored.restoreRecovery({ "schemaVersion" => 99 }, 0));
    Test.assertEqual(RUGBY_STATE_NOT_STARTED, restored.snapshot(0)["clockState"]);
    return true;
}

(:test)
function testConversionRecoveryUsesStoredRemainingTime(logger) {
    var original = newTestModel();
    original.startMatch(0);
    original.recordTry(RUGBY_TEAM_HOME, 1000);
    var saved = original.recoverySnapshot(31000);

    var restored = newTestModel();
    Test.assert(restored.restoreRecovery(saved, 100000));
    var snap = restored.snapshot(100000);
    Test.assertEqual(60, snap["conversionTimer"]["remainingSeconds"]);
    return true;
}

(:test)
function testOnlyActiveMatchesAreRecoverable(logger) {
    var model = new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS));
    Test.assertEqual(false, model.hasRecoverableMatch());
    model.startMatch(0);
    Test.assertEqual(true, model.hasRecoverableMatch());
    model.pause(1000);
    Test.assertEqual(true, model.hasRecoverableMatch());
    model.endMatch(1000);
    Test.assertEqual(false, model.hasRecoverableMatch());
    model.resetMatch();
    Test.assertEqual(false, model.hasRecoverableMatch());
    return true;
}
