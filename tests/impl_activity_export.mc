// tests/impl_activity_export.mc - recorder smoke test for activity export state

using Toybox.Test;

(:test)
function testImplActivityExportSnapshot(logger) {
    var recorder = new RugbyActivityRecorder();
    var snap = recorder.snapshot();

    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, snap["state"]);
    Test.assertEqual("skipped", snap["eventExportState"]);
    Test.assertEqual(0, snap["motionSampleCount"]);
    Test.assertNotEqual(null, snap["motionData"]);
}
