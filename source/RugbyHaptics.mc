import Toybox.Attention;
import Toybox.Lang;

const RUGBY_ALERT_THRESHOLD_SECONDS = 60;

class RugbyHaptics {

    var _lastAlertSnapshotId;
/* Reset last alert snapshot id to avoid duplicate alerts on startup. */

    function initialize() {
        _lastAlertSnapshotId = null;
    }

    function shouldAlert(remainingSeconds, alertFired) {
        return !alertFired && remainingSeconds != null && remainingSeconds <= RUGBY_ALERT_THRESHOLD_SECONDS && remainingSeconds >= 0;
    }
/* Only vibrate once per snapshot id; returns true if a vibration was performed. */

    function fireCoalesced(snapshotId) {
        if (_lastAlertSnapshotId == snapshotId) {
            return false;
        }
        _lastAlertSnapshotId = snapshotId;
        if (Attention has :vibrate) {
            Attention.vibrate([ new Attention.VibeProfile(80, 500) ]);
            return true;
        }
        return false;
    }
}



