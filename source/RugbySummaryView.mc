// RugbySummaryView.mc - UI stub for match summary

// NOTE: This is a minimal placeholder view. Replace with actual WatchUi implementation using resource-first layout.

class RugbySummaryView {
    var eventLog;

    function initialize(eventLog) {
        self.eventLog = eventLog;
    }

    function show() {
        // Render the scrollable list from eventLog using resources/layouts/match_summary_layout.xml
        var events = [];
        if (self.eventLog != null) {
            events = self.eventLog.snapshot();
        }

        if (events == null || events.length == 0) {
            // Show empty state message defined in resources/layouts/match_summary_layout.xml
            System.println("[UI] match summary empty state: No events recorded");
            // In actual WatchUi: load the layout and ensure emptyText is shown
        } else {
            // Render list of events
            for (var i = 0; i < events.length; i++) {
                var e = events[i];
                System.println("[UI] event: " + e.toString());
            }
        }
    }
}
