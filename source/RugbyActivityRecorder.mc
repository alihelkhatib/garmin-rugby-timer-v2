/*
 * File: RugbyActivityRecorder.mc
 * Purpose: Wrap the Connect IQ ActivityRecording API to create/start/stop/save a rugby activity session.
 * Public API: RugbyActivityRecorder class with start(), stopAndSave(), state(), fallbackReason(), snapshot()
 * Key state: _session, _state, _fallbackReason
 * Interactions: Toybox.ActivityRecording, Activity constants; tests/Test_RugbyActivityRecorder.mc
 * Example usage: var r=new RugbyActivityRecorder(); r.start(); ... r.stopAndSave();
 * TODOs/notes: Surface richer errors to caller; ensure compatibility across SDK versions
 */

import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Lang;
import Toybox.System;

const RUGBY_RECORDER_STATE_NOT_STARTED = "notStarted";
const RUGBY_RECORDER_STATE_RECORDING = "recording";
const RUGBY_RECORDER_STATE_STOPPED = "stopped";
const RUGBY_RECORDER_STATE_SAVED = "saved";
const RUGBY_RECORDER_STATE_UNSUPPORTED = "unsupported";
const RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED = "eventExportUnsupported";

class RugbyActivityRecorder {

    var _session;
    var _state;
    var _fallbackReason;
    var _eventExportState;
/* Initialize recorder state; no session active by default. */

    function initialize() {
        _session = null;
        _state = RUGBY_RECORDER_STATE_NOT_STARTED;
        _fallbackReason = null;
        _eventExportState = "skipped";
    }
/* Try to create and start an ActivityRecording session. Returns false if unsupported or on error. */

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
            _eventExportState = "skipped";
            return true;
        } catch (ex) {
            _session = null;
            _state = RUGBY_RECORDER_STATE_UNSUPPORTED;
            _fallbackReason = "Recording failed";
            return false;
        }
    }
/* Stop and save the current session if present; sets fallbackReason on failure. */

    function stopAndSave() {
        return stopAndSaveWithEvents(null);
    }

    function stopAndSaveWithEvents(eventLog) {
        var eventCount = eventLog == null ? 0 : eventLog.size();
        _eventExportState = eventCount > 0 ? RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED : "skipped";
        System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents eventCount=" + eventCount.format("%d") + " exportState=" + _eventExportState);
        if (_session == null) {
            return false;
        }
        try {
            _session.stop();
            _state = RUGBY_RECORDER_STATE_STOPPED;
            _session.save();
            _state = RUGBY_RECORDER_STATE_SAVED;
            _session = null;
            System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents saved exportState=" + _eventExportState);
            return true;
        } catch (ex) {
            _fallbackReason = "Recording failed";
            System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents failed ex=" + ex.toString());
            return false;
        }
    }

    function discard() {
        System.println("RUGBY|RugbyActivityRecorder|discard state=" + _state);
        if (_session != null) {
            try {
                _session.stop();
            } catch (ex) {
                System.println("RUGBY|RugbyActivityRecorder|discard stop failed ex=" + ex.toString());
            }
        }
        _session = null;
        _state = RUGBY_RECORDER_STATE_NOT_STARTED;
        _fallbackReason = null;
        _eventExportState = "skipped";
        return true;
    }

    function state() {
        return _state;
    }

    function fallbackReason() {
        return _fallbackReason;
    }
/* Return small serializable snapshot useful for debugging or persistence. */

    function snapshot() {
        return {
            "state" => _state,
            "sport" => "Activity.SPORT_RUGBY",
            "subSport" => "Activity.SUB_SPORT_MATCH",
            "fallbackReason" => _fallbackReason,
            "eventExportState" => _eventExportState
        };
    }
}


