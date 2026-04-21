// tests/impl_export_error_handling.mc - export failure smoke test

using Toybox.Test;

(:test)
function testImplExportErrorHandling(logger) {
    var recorder = new RugbyActivityRecorder();
    var events = [
        {
            "action" => "try",
            "teamId" => RUGBY_TEAM_HOME,
            "matchElapsedSeconds" => 5
        }
    ] as Array<Dictionary>;

    Test.assertEqual(false, recorder.stopAndSaveWithEvents(events));
    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, recorder.state());
}
