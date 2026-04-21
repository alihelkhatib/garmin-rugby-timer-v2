/*
Test: tests/Test_RugbyActivityRecorder.mc

What this test file covers:
- Basic RugbyActivityRecorder state and snapshot behaviour (initial state, sport/subSport, fallback state).

How to run locally:
- See docs/testing.md. Tests execute at app startup via Toybox.Test in the simulator.

Key assertions/behaviours:
- Initial snapshot reports not-started state and correct sport/sub-sport identifiers.
- Recorder fallback state is null and the state accessor returns the expected enum when not started.

Preconditions / setup:
- RugbyActivityRecorder can be constructed without external dependencies.
*/

using Toybox.Test;

(:test)
function testActivityRecorderInitialSnapshot(logger) {
    var recorder = new RugbyActivityRecorder();
    var snap = recorder.snapshot();
    // Recorder should start in NOT_STARTED state
    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, snap["state"]);
    // Sport and sub-sport identifiers should match expected constants
    Test.assertNotEqual(null, snap["sport"]);
    Test.assertNotEqual(null, snap["subSport"]);
    Test.assertEqual("skipped", snap["eventExportState"]);
    Test.assertNotEqual(null, snap["motionData"]);
    Test.assertEqual(0, snap["motionSampleCount"]);
}

(:test)
function testActivityRecorderFallbackState(logger) {
    var recorder = new RugbyActivityRecorder();
    // When not started, state() should be NOT_STARTED and fallbackReason() should be null
    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, recorder.state());
    Test.assertEqual(null, recorder.fallbackReason());
}

(:test)
function testActivityRecorderEventExportFallbackState(logger) {
    var recorder = new RugbyActivityRecorder();
    var events = [
        { "teamId" => RUGBY_TEAM_HOME, "action" => RUGBY_SCORE_TRY, "matchElapsedSeconds" => 10 }
    ];

    Test.assertEqual(false, recorder.stopAndSaveWithEvents(events));
    var snap = recorder.snapshot();
    Test.assertEqual(RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED, snap["eventExportState"]);
}

(:test)
function testActivityRecorderDiscardResetsState(logger) {
    var recorder = new RugbyActivityRecorder();
    Test.assertEqual(true, recorder.discard());
    var snap = recorder.snapshot();
    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, snap["state"]);
    Test.assertEqual("skipped", snap["eventExportState"]);
}
