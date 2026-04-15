// tests/integration/match_summary_open_test.mc - Integration test scaffold for opening match summary
import Toybox.System;

function main() {
    System.println("TEST|match_summary_open|start");

    // Prepare a small event log and ensure RugbySummaryView prints expected output.
    var log = new RugbyEventLog.RugbyEventLog();
    log.initialize();
    var ev = { "type" => "TRY", "matchElapsedSeconds" => 345, "teamId" => 1, "actor" => "ref", "value" => 5, "details" => "Scored try" };
    log.addEvent(ev);

    var view = new RugbySummaryView();
    view.initialize(log);
    view.show();

    System.println("TEST|match_summary_open|end");
}
