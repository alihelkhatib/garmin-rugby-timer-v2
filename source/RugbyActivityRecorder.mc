import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Lang;
import Toybox.Position;

const RUGBY_RECORDER_STATE_NOT_STARTED = "notStarted";
const RUGBY_RECORDER_STATE_RECORDING = "recording";
const RUGBY_RECORDER_STATE_SAVED = "saved";
const RUGBY_RECORDER_STATE_DISCARDED = "discarded";
const RUGBY_RECORDER_STATE_UNSUPPORTED = "unsupported";
const RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED = "eventExportUnsupported";
const RUGBY_GPS_STATE_INACTIVE = "inactive";
const RUGBY_GPS_STATE_ACQUIRING = "acquiring";
const RUGBY_GPS_STATE_READY = "ready";
const RUGBY_GPS_STATE_UNAVAILABLE = "unavailable";

class RugbyActivityRecorder {
    var _session;
    var _state as String;
    var _fallbackReason as String?;
    var _eventExportState as String;
    var _gpsState as String;
    var _gpsEnabled as Boolean;
    var _segmentDistanceMeters;
    var _priorDistanceMeters;

    function initialize() {
        _session = null;
        _state = RUGBY_RECORDER_STATE_NOT_STARTED;
        _fallbackReason = null;
        _eventExportState = "skipped";
        _gpsState = RUGBY_GPS_STATE_INACTIVE;
        _gpsEnabled = false;
        _segmentDistanceMeters = 0.0;
        _priorDistanceMeters = 0.0;
    }

    function enableGps() as Boolean {
        if (_gpsEnabled) {
            return true;
        }
        try {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
            _gpsEnabled = true;
            _gpsState = RUGBY_GPS_STATE_ACQUIRING;
            return true;
        } catch (gpsError) {
            _gpsEnabled = false;
            _gpsState = RUGBY_GPS_STATE_UNAVAILABLE;
            return false;
        }
    }

    function disableGps() as Void {
        if (_gpsEnabled) {
            try {
                Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            } catch (gpsError) {
            }
        }
        _gpsEnabled = false;
        if (!_gpsState.equals(RUGBY_GPS_STATE_UNAVAILABLE)) {
            _gpsState = RUGBY_GPS_STATE_INACTIVE;
        }
    }

    function onPosition(info as Position.Info) as Void {
        _gpsState = info != null && info.position != null
            ? RUGBY_GPS_STATE_READY
            : RUGBY_GPS_STATE_ACQUIRING;
    }

    function start() as Boolean {
        if (_state.equals(RUGBY_RECORDER_STATE_RECORDING)) {
            return true;
        }
        if (_state.equals(RUGBY_RECORDER_STATE_SAVED) || _state.equals(RUGBY_RECORDER_STATE_DISCARDED)) {
            return false;
        }
        if (!(ActivityRecording has :createSession)) {
            markUnsupported("Activity recording unavailable");
            return false;
        }

        var sport = Activity has :SPORT_RUGBY ? Activity.SPORT_RUGBY : Activity.SPORT_GENERIC;
        var options = {
            :sport => sport,
            :name => "Rugby Match"
        } as Dictionary;
        if (Activity has :SUB_SPORT_MATCH) {
            options[:subSport] = Activity.SUB_SPORT_MATCH;
        }

        try {
            enableGps();
            _session = ActivityRecording.createSession(options);
            _session.start();
            _state = RUGBY_RECORDER_STATE_RECORDING;
            _fallbackReason = null;
            return true;
        } catch (ex) {
            _session = null;
            markUnsupported("Activity recording failed to start");
            return false;
        }
    }

    function stopAndSave() as Boolean {
        return stopAndSaveWithEvents(null);
    }

    function stopAndSaveWithEvents(eventLog) as Boolean {
        var eventCount = eventLog == null ? 0 : eventLog.size();
        _eventExportState = eventCount > 0 ? RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED : "skipped";

        if (_state.equals(RUGBY_RECORDER_STATE_SAVED)) {
            return true;
        }
        if (!_state.equals(RUGBY_RECORDER_STATE_RECORDING) || _session == null) {
            return false;
        }

        try {
            refreshDistance();
            _session.stop();
            _session.save();
            _session = null;
            _state = RUGBY_RECORDER_STATE_SAVED;
            _fallbackReason = null;
            disableGps();
            return true;
        } catch (ex) {
            _fallbackReason = "Activity recording failed to save";
            return false;
        }
    }

    function discard() as Boolean {
        if (_state.equals(RUGBY_RECORDER_STATE_DISCARDED)) {
            return true;
        }
        if (_session != null) {
            try {
                _session.stop();
            } catch (stopError) {
                // A session may already be stopped; discard is still the terminal operation.
            }
            try {
                _session.discard();
            } catch (discardError) {
                _session = null;
                markUnsupported("Activity recording failed to discard");
                return false;
            }
        }
        _session = null;
        _state = RUGBY_RECORDER_STATE_DISCARDED;
        _fallbackReason = null;
        _eventExportState = "skipped";
        _segmentDistanceMeters = 0.0;
        _priorDistanceMeters = 0.0;
        disableGps();
        return true;
    }

    function reset() as Void {
        _session = null;
        _state = RUGBY_RECORDER_STATE_NOT_STARTED;
        _fallbackReason = null;
        _eventExportState = "skipped";
        _segmentDistanceMeters = 0.0;
        _priorDistanceMeters = 0.0;
    }

    function restoreDistanceMeters(distanceMeters) as Void {
        if (distanceMeters != null && distanceMeters >= 0) {
            _priorDistanceMeters = distanceMeters;
            _segmentDistanceMeters = 0.0;
        }
    }

    function refreshDistance() as Void {
        if (!_state.equals(RUGBY_RECORDER_STATE_RECORDING)) {
            return;
        }
        try {
            var info = Activity.getActivityInfo();
            if (info != null && info.elapsedDistance != null && info.elapsedDistance >= 0) {
                _segmentDistanceMeters = info.elapsedDistance;
            }
        } catch (distanceError) {
        }
    }

    function totalDistanceMeters() {
        refreshDistance();
        return _priorDistanceMeters + _segmentDistanceMeters;
    }

    function state() as String {
        return _state;
    }

    function fallbackReason() as String? {
        return _fallbackReason;
    }

    function snapshot() as Dictionary {
        var distance = totalDistanceMeters();
        return {
            "state" => _state,
            "sport" => "Activity.SPORT_RUGBY",
            "subSport" => "Activity.SUB_SPORT_MATCH",
            "fallbackReason" => _fallbackReason,
            "eventExportState" => _eventExportState,
            "gpsState" => _gpsState,
            "distanceMeters" => distance
        } as Dictionary;
    }

    function markUnsupported(reason as String) as Void {
        _state = RUGBY_RECORDER_STATE_UNSUPPORTED;
        _fallbackReason = reason;
    }
}
