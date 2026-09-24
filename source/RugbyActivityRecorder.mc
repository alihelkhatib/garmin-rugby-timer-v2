import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Sensor;

const RUGBY_RECORDER_STATE_NOT_STARTED = "notStarted";
const RUGBY_RECORDER_STATE_RECORDING = "recording";
const RUGBY_RECORDER_STATE_SAVED = "saved";
const RUGBY_RECORDER_STATE_DISCARDED = "discarded";
const RUGBY_RECORDER_STATE_UNSUPPORTED = "unsupported";
const RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED = "eventExportUnsupported";
const RUGBY_RECORDER_EVENT_EXPORT_READY = "ready";
const RUGBY_RECORDER_EVENT_EXPORT_EXPORTED = "exported";
const RUGBY_GPS_STATE_INACTIVE = "inactive";
const RUGBY_GPS_STATE_ACQUIRING = "acquiring";
const RUGBY_GPS_STATE_READY = "ready";
const RUGBY_GPS_STATE_UNAVAILABLE = "unavailable";
const RUGBY_HEART_RATE_STATE_INACTIVE = "inactive";
const RUGBY_HEART_RATE_STATE_ACTIVE = "active";
const RUGBY_HEART_RATE_STATE_UNAVAILABLE = "unavailable";
const RUGBY_FIT_FIELD_EVENT = 0;
const RUGBY_FIT_FIELD_MATCH_TIME = 1;
const RUGBY_FIT_FIELD_PERIOD = 2;
const RUGBY_FIT_FIELD_HOME_SCORE = 3;
const RUGBY_FIT_FIELD_AWAY_SCORE = 4;
class RugbyActivityRecorder {
    var _session;
    var _state as String;
    var _fallbackReason as String?;
    var _eventExportState as String;
    var _gpsState as String;
    var _gpsEnabled as Boolean;
    var _heartRateState as String;
    var _heartRateEnabled as Boolean;
    var _segmentDistanceMeters;
    var _priorDistanceMeters;
    var _eventField;
    var _matchTimeField;
    var _periodField;
    var _homeScoreField;
    var _awayScoreField;
    var _exportedEventStatuses as Dictionary;

    function initialize() {
        _session = null;
        _state = RUGBY_RECORDER_STATE_NOT_STARTED;
        _fallbackReason = null;
        _eventExportState = "skipped";
        _gpsState = RUGBY_GPS_STATE_INACTIVE;
        _gpsEnabled = false;
        _heartRateState = RUGBY_HEART_RATE_STATE_INACTIVE;
        _heartRateEnabled = false;
        _segmentDistanceMeters = 0.0;
        _priorDistanceMeters = 0.0;
        clearFitEventFields();
        _exportedEventStatuses = {} as Dictionary;
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

    function enableHeartRate() as Boolean {
        if (_heartRateEnabled) {
            return true;
        }
        try {
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
            Sensor.enableSensorEvents(method(:onSensor));
            _heartRateEnabled = true;
            _heartRateState = RUGBY_HEART_RATE_STATE_ACTIVE;
            return true;
        } catch (sensorError) {
            _heartRateEnabled = false;
            _heartRateState = RUGBY_HEART_RATE_STATE_UNAVAILABLE;
            return false;
        }
    }

    function disableHeartRate() as Void {
        if (_heartRateEnabled) {
            try {
                Sensor.enableSensorEvents(null);
                Sensor.setEnabledSensors([]);
            } catch (sensorError) {
            }
        }
        _heartRateEnabled = false;
        if (!_heartRateState.equals(RUGBY_HEART_RATE_STATE_UNAVAILABLE)) {
            _heartRateState = RUGBY_HEART_RATE_STATE_INACTIVE;
        }
    }

    function onSensor(info as Sensor.Info) as Void {
        // Enabling the sensor is sufficient for ActivityRecording to write HR samples.
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

        var sport = recordingSport();
        var options = {
            :sport => sport,
            :name => "Rugby Match"
        } as Dictionary;
        if (Activity has :SUB_SPORT_MATCH) {
            options[:subSport] = Activity.SUB_SPORT_MATCH;
        }

        try {
            enableGps();
            enableHeartRate();
            _session = ActivityRecording.createSession(options);
            _session.start();
            _state = RUGBY_RECORDER_STATE_RECORDING;
            _fallbackReason = null;
            initializeFitEventFields();
            return true;
        } catch (ex) {
            _session = null;
            disableHeartRate();
            markUnsupported("Activity recording failed to start");
            return false;
        }
    }

    function stopAndSave() as Boolean {
        return stopAndSaveWithEvents(null);
    }

    function stopAndSaveWithEvents(eventLog as Array<Dictionary>?) as Boolean {
        if (_state.equals(RUGBY_RECORDER_STATE_SAVED)) {
            return true;
        }
        if (!_state.equals(RUGBY_RECORDER_STATE_RECORDING) || _session == null) {
            return false;
        }

        try {
            syncEventLog(eventLog, scoreSnapshotFromEvents(eventLog));
            refreshDistance();
            _session.stop();
            _session.save();
            _session = null;
            clearFitEventFields();
            _state = RUGBY_RECORDER_STATE_SAVED;
            _fallbackReason = null;
            disableGps();
            disableHeartRate();
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
        clearFitEventFields();
        _exportedEventStatuses = {} as Dictionary;
        disableGps();
        disableHeartRate();
        return true;
    }

    function recordingSport() as Number {
        if (Activity has :SPORT_RUGBY) {
            return Activity.SPORT_RUGBY;
        }
        // Fenix 6 predates the native rugby enum. Soccer + match is the
        // supported field-sport compatibility path used by peer timer apps.
        return Activity.SPORT_SOCCER;
    }

    function reset() as Void {
        _session = null;
        _state = RUGBY_RECORDER_STATE_NOT_STARTED;
        _fallbackReason = null;
        _eventExportState = "skipped";
        _segmentDistanceMeters = 0.0;
        _priorDistanceMeters = 0.0;
        clearFitEventFields();
        _exportedEventStatuses = {} as Dictionary;
        disableHeartRate();
    }

    function primeEventLog(eventLog as Array<Dictionary>?) as Void {
        _exportedEventStatuses = {} as Dictionary;
        if (eventLog == null) {
            return;
        }
        for (var i = 0; i < eventLog.size(); i += 1) {
            var event = eventLog[i] as Dictionary;
            _exportedEventStatuses[eventKey(event)] = eventStatus(event);
        }
    }

    function initializeFitEventFields() as Boolean {
        clearFitEventFields();
        if (_session == null || !(_session has :createField)) {
            _eventExportState = RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED;
            return false;
        }
        try {
            _eventField = _session.createField("rugbyEvent", RUGBY_FIT_FIELD_EVENT, FitContributor.DATA_TYPE_STRING, {
                :count => 32,
                :mesgType => FitContributor.MESG_TYPE_LAP,
                :units => ""
            });
            _matchTimeField = _session.createField("rugbyTime", RUGBY_FIT_FIELD_MATCH_TIME, FitContributor.DATA_TYPE_UINT32, {
                :mesgType => FitContributor.MESG_TYPE_LAP,
                :units => "s"
            });
            _periodField = _session.createField("rugbyPeriod", RUGBY_FIT_FIELD_PERIOD, FitContributor.DATA_TYPE_UINT8, {
                :mesgType => FitContributor.MESG_TYPE_LAP,
                :units => ""
            });
            _homeScoreField = _session.createField("homeScore", RUGBY_FIT_FIELD_HOME_SCORE, FitContributor.DATA_TYPE_UINT16, {
                :mesgType => FitContributor.MESG_TYPE_LAP,
                :units => "pts"
            });
            _awayScoreField = _session.createField("awayScore", RUGBY_FIT_FIELD_AWAY_SCORE, FitContributor.DATA_TYPE_UINT16, {
                :mesgType => FitContributor.MESG_TYPE_LAP,
                :units => "pts"
            });
            _eventExportState = RUGBY_RECORDER_EVENT_EXPORT_READY;
            return true;
        } catch (fieldError) {
            clearFitEventFields();
            _eventExportState = RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED;
            return false;
        }
    }

    function syncEventLog(eventLog as Array<Dictionary>?, snapshot as Dictionary?) as Void {
        if (!_state.equals(RUGBY_RECORDER_STATE_RECORDING) || eventLog == null) {
            return;
        }
        if (_eventField == null && !initializeFitEventFields()) {
            return;
        }
        for (var i = 0; i < eventLog.size(); i += 1) {
            var event = eventLog[i] as Dictionary;
            var key = eventKey(event) as String;
            var status = eventStatus(event) as String;
            var previousStatus = _exportedEventStatuses[key];
            if (previousStatus == null) {
                if (writeFitEvent(event, snapshot, status.equals("corrected"))) {
                    _exportedEventStatuses[key] = status;
                }
            } else if (!("" + previousStatus).equals(status)) {
                if (writeFitEvent(event, snapshot, status.equals("corrected"))) {
                    _exportedEventStatuses[key] = status;
                }
            }
        }
    }

    function writeFitEvent(event as Dictionary, snapshot as Dictionary?, corrected as Boolean) as Boolean {
        try {
            _eventField.setData(eventLabel(event, corrected));
            _matchTimeField.setData(numberValue(event["matchElapsedSeconds"] as Number?));
            _periodField.setData(numberValue(event["periodIndex"] as Number?));
            _homeScoreField.setData(scoreValue(snapshot, "home"));
            _awayScoreField.setData(scoreValue(snapshot, "away"));
            if (_session.addLap()) {
                _eventExportState = RUGBY_RECORDER_EVENT_EXPORT_EXPORTED;
                return true;
            }
        } catch (eventError) {
            _eventExportState = RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED;
        }
        return false;
    }

    function eventLabel(event as Dictionary, corrected as Boolean) as String {
        var team = ("" + event["teamId"]).equals(RUGBY_TEAM_AWAY) ? "Away" : "Home";
        var action = "" + event["action"];
        var name = action;
        if (action.equals(RUGBY_SCORE_TRY)) {
            name = "Try";
        } else if (action.equals(RUGBY_EVENT_CONVERSION_MADE)) {
            name = "Conversion";
        } else if (action.equals(RUGBY_SCORE_PENALTY_GOAL)) {
            name = "Penalty Goal";
        } else if (action.equals(RUGBY_SCORE_DROP_GOAL)) {
            name = "Drop Goal";
        } else if (action.equals("yellowCard")) {
            name = "Yellow Card";
        } else if (action.equals("redCard")) {
            name = "Red Card";
        }
        return (corrected ? "Undo " : "") + team + " " + name;
    }

    function scoreSnapshotFromEvents(eventLog as Array<Dictionary>?) as Dictionary {
        var homeScore = 0;
        var awayScore = 0;
        if (eventLog != null) {
            for (var i = 0; i < eventLog.size(); i += 1) {
                var event = eventLog[i] as Dictionary;
                if (!eventStatus(event).equals("active")) {
                    continue;
                }
                var points = pointsForAction("" + event["action"]) as Number;
                if (("" + event["teamId"]).equals(RUGBY_TEAM_AWAY)) {
                    awayScore += points;
                } else {
                    homeScore += points;
                }
            }
        }
        return {
            "home" => { "score" => homeScore },
            "away" => { "score" => awayScore }
        } as Dictionary;
    }

    function pointsForAction(action as String) as Number {
        if (action.equals(RUGBY_SCORE_TRY)) { return 5; }
        if (action.equals(RUGBY_EVENT_CONVERSION_MADE)) { return 2; }
        if (action.equals(RUGBY_SCORE_PENALTY_GOAL) || action.equals(RUGBY_SCORE_DROP_GOAL)) { return 3; }
        return 0;
    }

    function eventKey(event as Dictionary) as String {
        return "" + event["id"];
    }

    function eventStatus(event as Dictionary) as String {
        return event["status"] == null ? "active" : ("" + event["status"]);
    }

    function scoreValue(snapshot as Dictionary?, teamKey as String) as Number {
        if (snapshot == null || snapshot[teamKey] == null) {
            return 0;
        }
        var team = snapshot[teamKey] as Dictionary;
        return numberValue(team["score"] as Number?);
    }

    function numberValue(value as Number?) as Number {
        return value == null ? 0 : value;
    }

    function clearFitEventFields() as Void {
        _eventField = null;
        _matchTimeField = null;
        _periodField = null;
        _homeScoreField = null;
        _awayScoreField = null;
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
            "heartRateState" => _heartRateState,
            "distanceMeters" => distance
        } as Dictionary;
    }

    function markUnsupported(reason as String) as Void {
        _state = RUGBY_RECORDER_STATE_UNSUPPORTED;
        _fallbackReason = reason;
    }
}
