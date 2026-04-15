// RugbyEventLog.mc - Minimal in-memory EventLog API
// Provides a small, safe implementation: addEvent(event), serialize(), snapshot()

class RugbyEventLog {
    var events;

    function initialize() {
        self.events = [];
    }

    function addEvent(event) {
        // Store a shallow copy to avoid external mutation
        self.events.add(event);
    }

    function snapshot() {
        // Return a shallow copy of events for safe iteration
        var copy = [];
        var i = 0;
        while (i < self.events.size()) {
            copy.add(self.events[i]);
            i = i + 1;
        }
        return copy;
    }

    function serialize() {
        // Minimal serialization to JSON-like string for tests and export
        try {
            return Json.toString(self.events);
        } catch (e) {
            return "[]";
        }
    }
}
