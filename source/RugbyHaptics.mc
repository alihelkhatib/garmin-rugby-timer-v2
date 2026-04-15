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

    /* Original coalesced single-vibe path (kept for compatibility). */
    function fireCoalesced(snapshotId) {
        if (_lastAlertSnapshotId == snapshotId) {
            System.println("RUGBY|RugbyHaptics|fireCoalesced skipped duplicate snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")));
            return false;
        }
        _lastAlertSnapshotId = snapshotId;
        if (Attention has :vibrate) {
            System.println("RUGBY|RugbyHaptics|fireCoalesced vibrate snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")));
            Attention.vibrate([ new Attention.VibeProfile(80, 500) ]);
            return true;
        }
        System.println("RUGBY|RugbyHaptics|fireCoalesced unavailable snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")));
        return false;
    }

    /* New: coalesced handler that accepts event list and fires per-event patterns once per snapshot. */
    function fireCoalescedForEvents(snapshotId as Number, events as Array<Dictionary>) as Boolean {
        if (_lastAlertSnapshotId == snapshotId) {
            System.println("RUGBY|RugbyHaptics|fireCoalescedForEvents skipped duplicate snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")));
            return false;
        }
        _lastAlertSnapshotId = snapshotId;
        if (!(Attention has :vibrate)) {
            System.println("RUGBY|RugbyHaptics|fireCoalescedForEvents unavailable snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")));
            return false;
        }
        for (var i = 0; i < events.size(); i += 1) {
            var ev = events[i] as Dictionary;
            var et = ev["type"];
            if (et != null && ("" + et).equals("half_two_min")) {
                var halfIdx = ev["halfIndex"] == null ? null : ev["halfIndex"];
                System.println("RUGBY|RugbyHaptics|fireHalfTwoMin vibrate snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")) + " halfIndex=" + (halfIdx == null ? "null" : halfIdx.format("%d")));
                Attention.vibrate([ new Attention.VibeProfile(100, 300), new Attention.VibeProfile(0, 120), new Attention.VibeProfile(100, 300) ]);
            } else if (et != null && ("" + et).equals("yellow")) {
                var sid = ev["id"];
                System.println("RUGBY|RugbyHaptics|fireCardOneMin vibrate snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")) + " sanctionId=" + (sid == null ? "null" : sid.format("%d")));
                Attention.vibrate([ new Attention.VibeProfile(55, 200) ]);
            } else {
                System.println("RUGBY|RugbyHaptics|fireCoalesced vibrate snapshotId=" + (snapshotId == null ? "null" : snapshotId.format("%d")));
                Attention.vibrate([ new Attention.VibeProfile(80, 500) ]);
            }
        }
        return true;
    }

    function fireMatchStart() as Boolean {
        if (Attention has :vibrate) {
            System.println("RUGBY|RugbyHaptics|fireMatchStart vibrate");
            Attention.vibrate([ new Attention.VibeProfile(100, 300) ]);
            return true;
        }
        System.println("RUGBY|RugbyHaptics|fireMatchStart unavailable");
        return false;
    }

    function firePause() as Boolean {
        if (Attention has :vibrate) {
            System.println("RUGBY|RugbyHaptics|firePause vibrate");
            Attention.vibrate([ new Attention.VibeProfile(70, 250), new Attention.VibeProfile(0, 120), new Attention.VibeProfile(70, 250) ]);
            return true;
        }
        System.println("RUGBY|RugbyHaptics|firePause unavailable");
        return false;
    }

    function firePauseReminder() as Boolean {
        if (Attention has :vibrate) {
            System.println("RUGBY|RugbyHaptics|firePauseReminder vibrate");
            Attention.vibrate([ new Attention.VibeProfile(55, 200) ]);
            return true;
        }
        System.println("RUGBY|RugbyHaptics|firePauseReminder unavailable");
        return false;
    }
}

