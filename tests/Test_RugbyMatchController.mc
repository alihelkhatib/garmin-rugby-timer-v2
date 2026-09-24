using Toybox.Test;
import Toybox.Lang;

class ControllerTestRecorder {
    var saveCalls as Number;
    var syncCalls as Number;

    function initialize() {
        saveCalls = 0;
        syncCalls = 0;
    }

    function syncEventLog(events, snapshot) as Void {
        syncCalls += 1;
    }

    function stopAndSaveWithEvents(events) as Boolean {
        saveCalls += 1;
        return true;
    }
}

(:test)
function testControllerPersistsAndSynchronizesFitEvents(logger) {
    var model = newTestModel();
    var recorder = new ControllerTestRecorder();
    var controller = new RugbyMatchController(model, recorder);
    model.startMatch(0);
    model.recordPenaltyGoalAt(RUGBY_TEAM_HOME, 1000);

    controller.persist(1000);
    Test.assertEqual(1, recorder.syncCalls);
    return true;
}

(:test)
function testControllerAutoSavesFinalMatchOnce(logger) {
    var model = newTestModel();
    var recorder = new ControllerTestRecorder();
    var controller = new RugbyMatchController(model, recorder);
    model.startMatch(0);
    model.endHalf(1000);
    model.startMatch(2000);

    var endAt = 2000 + (40 * 60 * 1000);
    var snap = controller.tick(endAt);
    Test.assertEqual(RUGBY_STATE_MATCH_ENDED, snap["clockState"]);
    Test.assertEqual(1, recorder.saveCalls);
    Test.assert(controller.consumeSummaryRequest());
    Test.assert(!controller.consumeSummaryRequest());

    controller.tick(endAt + 1000);
    Test.assertEqual(1, recorder.saveCalls);
    return true;
}
