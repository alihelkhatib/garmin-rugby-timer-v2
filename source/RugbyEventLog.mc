// RugbyEventLog.mc - lightweight stub implementation

class RugbyEvent {
    var type;
    var timestamp; // monotonic match time
    var actor;
    var value;
    var details;

    function initialize(type, timestamp, actor, value, details) {
        self.type = type;
        self.timestamp = timestamp;
        self.actor = actor;
        self.value = value;
        self.details = details;
    }
}

class RugbyEventLog {
    var events;

    function initialize() {
        self.events = [];
    }

    function addEvent(type, timestamp, actor, value, details) {
        var e = new RugbyEvent(type, timestamp, actor, value, details);
        self.events.add(e);
    }

    function clear() {
        self.events.clear();
    }

    function serializeToFit() {
        // TODO: implement serialization to ActivityRecording / FIT payload
        return "";
    }
}
