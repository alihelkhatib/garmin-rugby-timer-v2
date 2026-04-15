// BackButtonSummaryPrototype.mc - exploratory prototype for Back-button summary access

// This prototype demonstrates hooking the back button to open the match summary without interfering with end/reset confirmation flows.
// It is intentionally minimal and intended for manual prototyping on device simulator.

import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;

class BackButtonSummaryPrototype {
    var _model;
    var _recorder;

    function initialize(model, recorder) {
        _model = model;
        _recorder = recorder;
    }

    function onBackPressed() as Boolean {
        // If a pending confirmation is active, respect it
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (snap["pendingConfirmAction"] != null) {
            return false;
        }

        // Otherwise show summary view non-destructively
        WatchUi.pushView(new RugbyMatchSummaryView(_model), new RugbyMatchSummaryDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
}
