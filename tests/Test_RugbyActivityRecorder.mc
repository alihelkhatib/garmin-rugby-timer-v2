using Toybox.Test;

(:test)
function testActivityRecorderInitialSnapshot(logger) {
    var recorder = new RugbyActivityRecorder();
    var snap = recorder.snapshot();
    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, snap["state"]);
    Test.assertEqual("Activity.SPORT_RUGBY", snap["sport"]);
    Test.assertEqual("Activity.SUB_SPORT_MATCH", snap["subSport"]);
}

(:test)
function testActivityRecorderFallbackState(logger) {
    var recorder = new RugbyActivityRecorder();
    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, recorder.state());
    Test.assertEqual(null, recorder.fallbackReason());
}



