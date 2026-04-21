// tests/test_eventlog.mc - smoke test for RugbyEventLog

using Toybox.Test;

(:test)
function testEventLogStoresAndSerializes(logger) {
    var log = new RugbyEventLog();
    var event = {
        "action" => "try",
        "teamId" => RUGBY_TEAM_HOME,
        "matchElapsedSeconds" => 42
    };

    log.addEvent(event);

    var snapshot = log.snapshot();
    Test.assertEqual(1, snapshot.size());
    Test.assertEqual("try", snapshot[0]["action"]);
    Test.assertEqual(RUGBY_TEAM_HOME, snapshot[0]["teamId"]);
    Test.assertEqual(42, snapshot[0]["matchElapsedSeconds"]);
    Test.assertNotEqual("[]", log.serialize());
}
