// RugbyEventLog.mc - Minimal in-memory EventLog API
// Provides a small, safe implementation: addEvent(event), serialize(), snapshot()

module RugbyEventLog;

class RugbyEventLog {
    var events;

    function initialize() {
        self.events = [];
    }

    function addEvent(event) {
        // Store a shallow copy to avoid external mutation
        self.events.push(event);
    }

    function snapshot() {
        // Return a shallow copy of events for safe iteration
        var copy = [];
        for (var i = 0; i < self.events.length; i++) {
            copy.push(self.events[i]);
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
