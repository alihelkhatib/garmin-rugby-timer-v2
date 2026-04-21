// tests/match_summary_endflow_test.mc - smoke test for summary entry point wiring

using Toybox.Test;

(:test)
function testMatchSummaryEndFlow(logger) {
    var model = new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS));
    var recorder = new RugbyActivityRecorder();
    var delegate = new RugbyTimerDelegate(model, recorder);

    Test.assertEqual(true, delegate.canOpenMatchOptionsForState(RUGBY_STATE_MATCH_ENDED));
    Test.assertEqual(true, delegate.canExitAppForState(RUGBY_STATE_MATCH_ENDED));
}
