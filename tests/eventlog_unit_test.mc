// tests/eventlog_unit_test.mc - Unit test for RugbyEventLog
import Toybox.System;

function main() {
    var log = new RugbyEventLog.RugbyEventLog();
    log.initialize();
    var e = {"type" => "test", "timestamp" => 12345, "actor" => "ref", "value" => 1, "details" => "ok"};
    log.addEvent(e);
    var snap = log.snapshot();
    System.println("TEST|eventlog|count=" + snap.size().format("%d"));
    var s = log.serialize();
    System.println("TEST|eventlog|serialize=" + s);
    if (snap.size() == 1 && s != null) {
        System.println("TEST|eventlog|PASS");
        return true;
    }
    System.println("TEST|eventlog|FAIL");
    return false;
}
