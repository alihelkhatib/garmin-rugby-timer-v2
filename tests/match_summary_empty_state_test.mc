// match_summary_empty_state_test.mc - empty-state smoke test for the summary helper

using Toybox.Test;

(:test)
function testMatchSummaryEmptyState(logger) {
    var log = new RugbyEventLog();
    var view = new RugbySummaryView(log);

    view.show();

    Test.assertEqual(0, log.snapshot().size());
    Test.assertEqual("[]", log.serialize());
}
