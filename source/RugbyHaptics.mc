import Toybox.Attention;
import Toybox.Lang;
const RUGBY_ALERT_THRESHOLD_SECONDS = 60;

class RugbyHaptics {

    function initialize() {
    }

    function shouldAlert(remainingSeconds, alertFired) {
        return !alertFired && remainingSeconds != null && remainingSeconds <= RUGBY_ALERT_THRESHOLD_SECONDS && remainingSeconds >= 0;
    }
    function patternForEvents(events as Array<Dictionary>) as String {
        var hasWarning = false;
        for (var i = 0; i < events.size(); i += 1) {
            var event = events[i] as Dictionary;
            var type = "" + event["type"];
            if (type.equals("yellowExpired")) {
                return "expired";
            }
            if (type.equals("yellowWarning")) {
                hasWarning = true;
            }
        }
        return hasWarning ? "warning" : "generic";
    }

    function fireEvents(events as Array<Dictionary>) as Boolean {
        if (events.size() == 0 || !(Attention has :vibrate)) {
            return false;
        }
        var pattern = patternForEvents(events) as String;
        if (pattern.equals("expired")) {
            Attention.vibrate([
                new Attention.VibeProfile(100, 400),
                new Attention.VibeProfile(0, 120),
                new Attention.VibeProfile(100, 400),
                new Attention.VibeProfile(0, 120),
                new Attention.VibeProfile(100, 700)
            ]);
        } else if (pattern.equals("warning")) {
            Attention.vibrate([
                new Attention.VibeProfile(80, 250),
                new Attention.VibeProfile(0, 150),
                new Attention.VibeProfile(80, 250)
            ]);
        } else {
            Attention.vibrate([ new Attention.VibeProfile(80, 500) ]);
        }
        return true;
    }

    function fireMatchStart() as Boolean {
        if (Attention has :vibrate) {
            Attention.vibrate([ new Attention.VibeProfile(100, 300) ]);
            return true;
        }
        return false;
    }

    function firePause() as Boolean {
        if (Attention has :vibrate) {
            Attention.vibrate([ new Attention.VibeProfile(70, 250), new Attention.VibeProfile(0, 120), new Attention.VibeProfile(70, 250) ]);
            return true;
        }
        return false;
    }

    function firePauseReminder() as Boolean {
        if (Attention has :vibrate) {
            Attention.vibrate([ new Attention.VibeProfile(55, 200) ]);
            return true;
        }
        return false;
    }
}

