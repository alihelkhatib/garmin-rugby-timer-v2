import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Lang;

const RUGBY_RECORDER_STATE_NOT_STARTED = "notStarted";
const RUGBY_RECORDER_STATE_RECORDING = "recording";
const RUGBY_RECORDER_STATE_STOPPED = "stopped";
const RUGBY_RECORDER_STATE_SAVED = "saved";
const RUGBY_RECORDER_STATE_UNSUPPORTED = "unsupported";

class RugbyActivityRecorder {

    var _session;
    var _state;
    var _fallbackReason;

    function initialize() {
        _session = null;
        _state = RUGBY_RECORDER_STATE_NOT_STARTED;
        _fallbackReason = null;
    }

    function start() {
        if (!(ActivityRecording has :createSession)) {
            _state = RUGBY_RECORDER_STATE_UNSUPPORTED;
            _fallbackReason = "ActivityRecording unavailable";
            return false;
        }

        try {
            _session = ActivityRecording.createSession({
                :sport => Activity.SPORT_RUGBY,
                :subSport => Activity.SUB_SPORT_MATCH,
                :name => "Rugby Match"
            });
            _session.start();
            _state = RUGBY_RECORDER_STATE_RECORDING;
            _fallbackReason = null;
            return true;
        } catch (ex) {
            _session = null;
            _state = RUGBY_RECORDER_STATE_UNSUPPORTED;
            _fallbackReason = "Recording failed";
            return false;
        }
    }

    function stopAndSave() {
        if (_session == null) {
            return false;
        }
        try {
            _session.stop();
            _state = RUGBY_RECORDER_STATE_STOPPED;
            _session.save();
            _state = RUGBY_RECORDER_STATE_SAVED;
            _session = null;
            return true;
        } catch (ex) {
            _fallbackReason = "Recording failed";
            return false;
        }
    }

    function state() {
        return _state;
    }

    function fallbackReason() {
        return _fallbackReason;
    }

    function snapshot() {
        return {
            "state" => _state,
            "sport" => "Activity.SPORT_RUGBY",
            "subSport" => "Activity.SUB_SPORT_MATCH",
            "fallbackReason" => _fallbackReason
        };
    }
}



