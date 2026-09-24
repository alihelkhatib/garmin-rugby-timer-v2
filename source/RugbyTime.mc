import Toybox.Lang;

class RugbyTime {
    static function elapsedMs(startMs as Number?, nowMs as Number) as Number {
        if (startMs == null) {
            return 0;
        }
        var elapsed = nowMs - startMs;
        return elapsed < 0 ? 0 : elapsed;
    }

    static function formatClock(totalSeconds as Number?) as String {
        if (totalSeconds == null) {
            return "--:--";
        }
        var seconds = totalSeconds < 0 ? 0 : totalSeconds;
        var minutes = seconds / 60;
        var remainder = seconds % 60;
        return minutes.format("%d") + ":" + (remainder < 10 ? "0" : "") + remainder.format("%d");
    }
}
