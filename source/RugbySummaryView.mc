// RugbySummaryView.mc - UI stub for match summary

// NOTE: This is a minimal placeholder view. Replace with actual WatchUi implementation using resource-first layout.

import Toybox.System;
import Toybox.Lang;

class RugbySummaryView {
    var eventLog as RugbyEventLog?;

    function initialize(eventLog) {
        self.eventLog = eventLog;
    }

    function show() {
        // Render the scrollable list from eventLog using resources/layouts/match_summary_layout.xml
        var events = [] as Array<Dictionary>;
        if (self.eventLog != null) {
            events = self.eventLog.snapshot() as Array<Dictionary>;
        }

        if (events == null || events.size() == 0) {
            // Show empty state message defined in resources/layouts/match_summary_layout.xml
            System.println("[UI] match summary empty state: No events recorded");
            // In actual WatchUi: load the layout and ensure emptyText is shown
        } else {
            // Render list of events
            var i = 0;
            while (i < events.size()) {
                var e = events[i];
                System.println("[UI] event: " + e.toString());
                i = i + 1;
            }
        }
    }
}
