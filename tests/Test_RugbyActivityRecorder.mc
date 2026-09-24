/*
Test: tests/Test_RugbyActivityRecorder.mc

What this test file covers:
- Recorder state, heart-rate lifecycle, real/fake FIT sessions, event mapping, deduplication, corrections, and recovery priming.

How to run locally:
- See docs/testing.md. Tests execute at app startup via Toybox.Test in the simulator.

Key assertions/behaviours:
- Initial state and metadata are stable; heart-rate enable/disable cleans up correctly.
- FIT events carry readable labels, timing, period, and scores exactly once, including corrections.
- A real simulator ActivityRecording session can create the fields, write an event lap, and save.

Preconditions / setup:
- RugbyActivityRecorder can be constructed without external dependencies.
*/

using Toybox.Test;
import Toybox.Lang;

class RecorderTestField {
    var values;

    function initialize() {
        values = [];
    }

    function setData(value) as Void {
        values.add(value);
    }
}

class RecorderTestSession {
    var fields;
    var lapCount as Number;

    function initialize() {
        fields = {};
        lapCount = 0;
    }

    function createField(name, fieldId, dataType, options) {
        var field = new RecorderTestField();
        fields[fieldId] = field;
        return field;
    }

    function addLap() as Boolean {
        lapCount += 1;
        return true;
    }
}

(:test)
function testActivityRecorderInitialSnapshot(logger) {
    var recorder = new RugbyActivityRecorder();
    var snap = recorder.snapshot();
    // Recorder should start in NOT_STARTED state
    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, snap["state"]);
    // Sport and sub-sport identifiers should match expected constants
    Test.assertEqual("Activity.SPORT_RUGBY", snap["sport"]);
    Test.assertEqual("Activity.SUB_SPORT_MATCH", snap["subSport"]);
    Test.assertEqual("skipped", snap["eventExportState"]);
    Test.assertEqual(RUGBY_GPS_STATE_INACTIVE, snap["gpsState"]);
    Test.assertEqual(RUGBY_HEART_RATE_STATE_INACTIVE, snap["heartRateState"]);
    Test.assertEqual(0.0, snap["distanceMeters"]);
    return true;
}

(:test)
function testActivityRecorderFallbackState(logger) {
    var recorder = new RugbyActivityRecorder();
    // When not started, state() should be NOT_STARTED and fallbackReason() should be null
    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, recorder.state());
    Test.assert(recorder.fallbackReason() == null);
    return true;
}

(:test)
function testActivityRecorderDoesNotClaimExportBeforeRecording(logger) {
    var recorder = new RugbyActivityRecorder();
    var events = [
        { "teamId" => RUGBY_TEAM_HOME, "action" => RUGBY_SCORE_TRY, "matchElapsedSeconds" => 10 }
    ];

    Test.assertEqual(false, recorder.stopAndSaveWithEvents(events));
    var snap = recorder.snapshot();
    Test.assertEqual("skipped", snap["eventExportState"]);
    return true;
}

(:test)
function testActivityRecorderDiscardIsTerminal(logger) {
    var recorder = new RugbyActivityRecorder();
    Test.assertEqual(true, recorder.discard());
    var snap = recorder.snapshot();
    Test.assertEqual(RUGBY_RECORDER_STATE_DISCARDED, snap["state"]);
    Test.assertEqual("skipped", snap["eventExportState"]);
    return true;
}

(:test)
function testActivityRecorderHeartRateLifecycle(logger) {
    var recorder = new RugbyActivityRecorder();
    Test.assert(recorder.enableHeartRate());
    Test.assertEqual(RUGBY_HEART_RATE_STATE_ACTIVE, recorder.snapshot()["heartRateState"]);
    recorder.disableHeartRate();
    Test.assertEqual(RUGBY_HEART_RATE_STATE_INACTIVE, recorder.snapshot()["heartRateState"]);
    return true;
}

(:test)
function testActivityRecorderRealSessionExportsAndSaves(logger) {
    var recorder = new RugbyActivityRecorder();
    Test.assert(recorder.start());
    Test.assertEqual(RUGBY_RECORDER_STATE_RECORDING, recorder.state());
    Test.assertEqual(RUGBY_RECORDER_EVENT_EXPORT_READY, recorder.snapshot()["eventExportState"]);

    var events = [{
        "id" => 1,
        "teamId" => RUGBY_TEAM_HOME,
        "action" => RUGBY_SCORE_PENALTY_GOAL,
        "periodIndex" => 1,
        "matchElapsedSeconds" => 12,
        "status" => "active"
    }];
    recorder.syncEventLog(events, { "home" => { "score" => 3 }, "away" => { "score" => 0 } });
    Test.assertEqual(RUGBY_RECORDER_EVENT_EXPORT_EXPORTED, recorder.snapshot()["eventExportState"]);
    Test.assert(recorder.stopAndSaveWithEvents(events));
    Test.assertEqual(RUGBY_RECORDER_STATE_SAVED, recorder.state());
    Test.assertEqual(RUGBY_HEART_RATE_STATE_INACTIVE, recorder.snapshot()["heartRateState"]);
    return true;
}

(:test)
function testActivityRecorderFormatsReadableRugbyEvents(logger) {
    var recorder = new RugbyActivityRecorder();
    Test.assertEqual("Home Try", recorder.eventLabel({ "teamId" => RUGBY_TEAM_HOME, "action" => RUGBY_SCORE_TRY }, false));
    Test.assertEqual("Away Yellow Card", recorder.eventLabel({ "teamId" => RUGBY_TEAM_AWAY, "action" => "yellowCard" }, false));
    Test.assertEqual("Undo Home Conversion", recorder.eventLabel({ "teamId" => RUGBY_TEAM_HOME, "action" => RUGBY_EVENT_CONVERSION_MADE }, true));
    return true;
}

(:test)
function testActivityRecorderExportsEachEventAndCorrectionOnce(logger) {
    var recorder = new RugbyActivityRecorder();
    var session = new RecorderTestSession();
    recorder._session = session;
    recorder._state = RUGBY_RECORDER_STATE_RECORDING;
    Test.assert(recorder.initializeFitEventFields());

    var event = {
        "id" => 7,
        "teamId" => RUGBY_TEAM_HOME,
        "action" => RUGBY_SCORE_TRY,
        "periodIndex" => 1,
        "matchElapsedSeconds" => 75,
        "status" => "active"
    };
    var events = [event];
    var snapshot = {
        "home" => { "score" => 5 },
        "away" => { "score" => 0 }
    };

    recorder.syncEventLog(events, snapshot);
    recorder.syncEventLog(events, snapshot);
    Test.assertEqual(1, session.lapCount);
    Test.assertEqual("Home Try", session.fields[RUGBY_FIT_FIELD_EVENT].values[0]);
    Test.assertEqual(75, session.fields[RUGBY_FIT_FIELD_MATCH_TIME].values[0]);
    Test.assertEqual(1, session.fields[RUGBY_FIT_FIELD_PERIOD].values[0]);
    Test.assertEqual(5, session.fields[RUGBY_FIT_FIELD_HOME_SCORE].values[0]);
    Test.assertEqual(0, session.fields[RUGBY_FIT_FIELD_AWAY_SCORE].values[0]);

    event["status"] = "corrected";
    snapshot["home"]["score"] = 0;
    recorder.syncEventLog(events, snapshot);
    recorder.syncEventLog(events, snapshot);
    Test.assertEqual(2, session.lapCount);
    Test.assertEqual("Undo Home Try", session.fields[RUGBY_FIT_FIELD_EVENT].values[1]);
    Test.assertEqual(0, session.fields[RUGBY_FIT_FIELD_HOME_SCORE].values[1]);
    return true;
}

(:test)
function testActivityRecorderPrimesRestoredEventsWithoutReExport(logger) {
    var recorder = new RugbyActivityRecorder();
    var restored = [{
        "id" => 3,
        "teamId" => RUGBY_TEAM_AWAY,
        "action" => "redCard",
        "periodIndex" => 1,
        "matchElapsedSeconds" => 18,
        "status" => "active"
    }];
    recorder.primeEventLog(restored);

    var session = new RecorderTestSession();
    recorder._session = session;
    recorder._state = RUGBY_RECORDER_STATE_RECORDING;
    recorder.initializeFitEventFields();
    recorder.syncEventLog(restored, { "home" => { "score" => 0 }, "away" => { "score" => 0 } });
    Test.assertEqual(0, session.lapCount);
    return true;
}

(:test)
function testActivityRecorderRestoresCumulativeDistance(logger) {
    var recorder = new RugbyActivityRecorder();
    recorder.restoreDistanceMeters(3218.688);
    var snap = recorder.snapshot();
    Test.assertEqual(3218.688, snap["distanceMeters"]);

    recorder.reset();
    snap = recorder.snapshot();
    Test.assertEqual(RUGBY_RECORDER_STATE_NOT_STARTED, snap["state"]);
    Test.assertEqual(0.0, snap["distanceMeters"]);
    return true;
}
