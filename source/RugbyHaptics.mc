import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;

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

    function _firePattern(patternName as String, vibeProfiles as Array<Attention.VibeProfile>) as Boolean {
        if (Attention has :vibrate) {
            System.println("RUGBY|RugbyHaptics|" + patternName + " vibrate");
            Attention.vibrate(vibeProfiles);
            return true;
        }
        System.println("RUGBY|RugbyHaptics|" + patternName + " unavailable");
        return false;
    }
/* Only vibrate once per snapshot id; returns true if a vibration was performed. */

    function fireCoalesced(snapshotId) {
        if (_lastAlertSnapshotId == snapshotId) {
            System.println("RUGBY|RugbyHaptics|fireCoalesced skipped duplicate snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")));
            return false;
        }
        _lastAlertSnapshotId = snapshotId;
        return _firePattern("fireCoalesced snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")), [ new Attention.VibeProfile(80, 500) ]);
    }

    function fireConversionWarning() as Boolean {
        return _firePattern("fireConversionWarning", [ new Attention.VibeProfile(80, 500) ]);
    }

    function fireYellowWarning() as Boolean {
        return _firePattern("fireYellowWarning", [ new Attention.VibeProfile(80, 500) ]);
    }

    function fireHalfWarning() as Boolean {
        return _firePattern("fireHalfWarning", [ new Attention.VibeProfile(100, 350) ]);
    }

    function fireMatchStart() as Boolean {
        return _firePattern("fireMatchStart", [ new Attention.VibeProfile(100, 300) ]);
    }

    function firePause() as Boolean {
        return _firePattern("firePause", [ new Attention.VibeProfile(70, 250), new Attention.VibeProfile(0, 120), new Attention.VibeProfile(70, 250) ]);
    }

    function firePauseReminder() as Boolean {
        return _firePattern("firePauseReminder", [ new Attention.VibeProfile(55, 200) ]);
    }
}

