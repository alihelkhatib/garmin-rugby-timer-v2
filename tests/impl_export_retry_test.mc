// tests/impl_export_retry_test.mc - Integration test for ActivityRecording export retry behavior
// Purpose: deterministically simulate a failing initial save() then a successful retry and assert diagnostics

import Toybox.System;
import Toybox.Json;

function main() {
    System.println("TEST|impl_export_retry|start");

    var recorder = new RugbyActivityRecorder();
    recorder.initialize();

    // Prepare a small synthetic event list
    var events = [];
    var ev = { "type" => "TRY", "timestamp" => 12345, "matchElapsedSeconds" => 12345, "teamId" => 1, "actor" => "ref", "value" => 5, "details" => "Scored try" };
    events.add(ev);

    // Fake session that fails on first save() call and succeeds thereafter
    class FakeSession {
        var savedOnce;
        var records;
        function initialize() {
            self.savedOnce = false;
            self.records = [];
        }
        function start() {}
        function stop() {}
        function save() {
            if (!self.savedOnce) {
                self.savedOnce = true;
                throw "simulated save failure";
            }
            // success on subsequent calls
        }
        function appendRecords(recs) {
            self.records = recs;
        }
        function addEvent(type, ts, actor, value, details) {
            var obj = { "type" => type, "timestamp" => ts, "actor" => actor, "value" => value, "details" => details };
            self.records.add(obj);
        }
    }

    var s = new FakeSession();
    s.initialize();
    recorder.setSessionForTest(s);

    // Trigger stop/save with events. First attempt will fail and schedule retries.
    var initial = recorder.stopAndSaveWithEvents(events);
    System.println("TEST|impl_export_retry|initial_result=" + (initial ? "true" : "false"));

    // Simulate the retry timer firing (synchronously in test harness)
    recorder._onExportRetryTimer();

    // Inspect last diagnostic emitted by recorder
    var lastDiag = recorder.getLastExportDiagnosticForTest();
    if (lastDiag != null) {
        System.println("TEST|impl_export_retry|last_diag=" + Json.toString(lastDiag));
    } else {
        System.println("TEST|impl_export_retry|no_diag");
    }

    // Snapshot recorder state for assertions
    var snap = recorder.snapshot();
    System.println("TEST|impl_export_retry|snapshot=" + Json.toString(snap));

    System.println("TEST|impl_export_retry|end");
}
