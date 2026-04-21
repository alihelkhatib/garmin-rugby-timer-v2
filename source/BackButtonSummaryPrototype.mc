// BackButtonSummaryPrototype.mc - exploratory prototype for Back-button summary access

import Toybox.System;
import Toybox.WatchUi;

// This prototype demonstrates hooking the back button to open the match summary without interfering with end/reset confirmation flows.
// It is intentionally minimal and intended for manual prototyping on device simulator.

class BackButtonSummaryPrototype {
    var _model;
    var _recorder;

    function initialize(model, recorder) {
        _model = model;
        _recorder = recorder;
    }

    function onBackPressed() {
        // If a pending confirmation is active, respect it
        var snap = _model.snapshot(System.getTimer());
        if (snap["pendingConfirmAction"] != null) {
            return false;
        }

        // Otherwise show summary view non-destructively
        var view = new RugbyMatchSummaryView(_model);
        WatchUi.pushView(view, new RugbyMatchSummaryDelegate(_model, view), WatchUi.SLIDE_UP);
        return true;
    }
}
