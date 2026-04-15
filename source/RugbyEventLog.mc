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
            var out = "[";
            var i = 0;
            while (i < self.events.size()) {
                var e = self.events[i] as Dictionary;
                var ts = e["timestamp"] == null ? "null" : ("" + e["timestamp"]);
                var t = e["type"] == null ? "" : e["type"];
                var a = e["actor"] == null ? "" : e["actor"];
                var v = e["value"] == null ? "null" : ("" + e["value"]);
                var d = e["details"] == null ? "" : e["details"];
                var obj = "{\"type\":\"" + t + "\",\"timestamp\":" + ts + ",\"actor\":\"" + a + "\",\"value\":" + v + ",\"details\":\"" + d + "\"}";
                if (i > 0) {
                    out = out + ",";
                }
                out = out + obj;
                i = i + 1;
            }
            out = out + "]";
            return out;
        } catch (e) {
            return "[]";
        }
    }
}
