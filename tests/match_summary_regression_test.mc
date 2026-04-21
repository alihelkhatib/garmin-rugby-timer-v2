// tests/match_summary_regression_test.mc - regression smoke test for summary wiring

using Toybox.Test;

(:test)
function testMatchSummaryRegression(logger) {
    var model = new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS));
    var view = new RugbyMatchSummaryView(model);
    var summaryDelegate = new RugbyMatchSummaryDelegate(model, view);

    Test.assertNotEqual(null, summaryDelegate);
}

(:test)
function testSummaryNewestFirstSnapshotAfterUndo(logger) {
    var model = new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS));
    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 10000);
    model.recordPenaltyGoalAt(RUGBY_TEAM_AWAY, 20000);

    var events = model.eventLog();
    Test.assertEqual(2, events.size());
    Test.assertEqual(RUGBY_SCORE_PENALTY_GOAL, events[events.size() - 1]["action"]);

    model.requestUndoLastEvent();
    Test.assertEqual(true, model.confirmPending(21000));
    events = model.eventLog();
    Test.assertEqual(1, events.size());
    Test.assertEqual(RUGBY_SCORE_TRY, events[0]["action"]);
}
