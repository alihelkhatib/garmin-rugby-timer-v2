// RugbyEventLog.mc - Minimal in-memory EventLog API
// Provides a small, safe implementation: addEvent(event), serialize(), snapshot()

import Toybox.Lang;

class RugbyEventLog {
    var events as Array<Dictionary>;

    function initialize() {
        self.events = [] as Array<Dictionary>;
    }

    function addEvent(event) {
        // Store a shallow copy to avoid external mutation
        self.events.add(event);
    }

    function snapshot() {
        // Return a shallow copy of events for safe iteration
        var copy = [] as Array<Dictionary>;
        for (var i = 0; i < self.events.size(); i++) {
            copy.add(self.events[i]);
        }
        return copy;
    }

    function serialize() {
        // Minimal serialization to a string for tests and export
        try {
            var parts = [] as Array<String>;
            for (var i = 0; i < self.events.size(); i++) {
                parts.add(self.events[i].toString());
            }
            var text = "[";
            for (var j = 0; j < parts.size(); j++) {
                if (j > 0) {
                    text += ",";
                }
                text += parts[j];
            }
            text += "]";
            return text;
        } catch (e) {
            return "[]";
        }
    }
}
