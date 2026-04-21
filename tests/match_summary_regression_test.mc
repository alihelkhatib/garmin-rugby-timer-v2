// tests/match_summary_regression_test.mc - regression smoke test for summary wiring

using Toybox.Test;

(:test)
function testMatchSummaryRegression(logger) {
    var model = new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS));
    var summaryDelegate = new RugbyMatchSummaryDelegate(model);

    Test.assertNotEqual(null, summaryDelegate);
}
