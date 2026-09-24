using Toybox.Test;

(:test)
function testElapsedTimeClampsBackwardValues(logger) {
    Test.assertEqual(0, RugbyTime.elapsedMs(1000, 999));
    Test.assertEqual(500, RugbyTime.elapsedMs(1000, 1500));
    return true;
}

(:test)
function testElapsedTimeSurvivesSystemTimerRollover(logger) {
    Test.assertEqual(96, RugbyTime.elapsedMs(2147483600, -2147483600));
    return true;
}

(:test)
function testClockFormattingClampsAndPads(logger) {
    Test.assertEqual("--:--", RugbyTime.formatClock(null));
    Test.assertEqual("0:00", RugbyTime.formatClock(-1));
    Test.assertEqual("1:05", RugbyTime.formatClock(65));
    return true;
}
