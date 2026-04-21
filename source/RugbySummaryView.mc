// RugbySummaryView.mc - Compatibility helper for match summary smoke checks

import Toybox.System;

class RugbySummaryView {
    var eventLog;

    function initialize(eventLog) {
        self.eventLog = eventLog;
    }

    function show() {
        var events = [];
        if (self.eventLog != null) {
            events = self.eventLog.snapshot();
        }

        if (events == null || events.size() == 0) {
            System.println("[UI] match summary empty state: No events recorded");
            return;
        }

        for (var i = 0; i < events.size(); i += 1) {
            var e = events[i];
            System.println("[UI] event: " + e.toString());
        }
    }
}
