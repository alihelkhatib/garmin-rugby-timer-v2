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

        // Determine sport mapping with graceful fallback when device lacks SPORT_RUGBY
        var sport = Activity has :SPORT_RUGBY ? Activity.SPORT_RUGBY : (Activity has :SPORT_OTHER ? Activity.SPORT_OTHER : 0);
        var subSport = Activity has :SUB_SPORT_MATCH ? Activity.SUB_SPORT_MATCH : null;

        try {
            _session = ActivityRecording.createSession({
                :sport => sport,
                :subSport => subSport,
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
        // Default export state; update if we successfully attach/export events
        _eventExportState = eventCount > 0 ? RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED : "skipped";
        System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents eventCount=" + eventCount.format("%d") + " exportState=" + _eventExportState);

        if (_session == null) {
            return false;
        }

        var attached = false;
        if (eventCount > 0) {
            try {
                // Best-effort: try multiple session APIs to attach events
                if (_session has :appendRecords) {
                    var recs = [];
                    var i = 0;
                    while (i < eventCount) {
                        var e = eventLog[i];
                        var ts = e["timestamp"];
                        var t = e["type"];
                        var a = e["actor"];
                        var v = e["value"];
                        var d = e["details"];
                        var s = t + "|" + (ts == null ? "" : ts.format("%d")) + "|" + (a == null ? "" : a) + "|" + (v == null ? "" : v.format("%d")) + "|" + (d == null ? "" : d);
                        recs.add(s);
                        i = i + 1;
                    }
                    _session.appendRecords(recs);
                    attached = true;
                } else if (_session has :addEvent) {
                    var i2 = 0;
                    while (i2 < eventCount) {
                        var e2 = eventLog[i2];
                        _session.addEvent(e2["type"], e2["timestamp"], e2["actor"], e2["value"], e2["details"]);
                        i2 = i2 + 1;
                    }
                    attached = true;
                } else if (_session has :addComment) {
                    var j = 0;
                    while (j < eventCount) {
                        var ej = eventLog[j];
                        var s2 = ej["type"] + "|" + (ej["timestamp"] == null ? "" : ej["timestamp"].format("%d")) + "|" + (ej["actor"] == null ? "" : ej["actor"]) + "|" + (ej["value"] == null ? "" : ej["value"].format("%d")) + "|" + (ej["details"] == null ? "" : ej["details"]);
                        _session.addComment(s2);
                        j = j + 1;
                    }
                    attached = true;
                } else if (_session has :addMarker) {
                    var k = 0;
                    while (k < eventCount) {
                        var ek = eventLog[k];
                        var s3 = ek["type"] + "|" + (ek["timestamp"] == null ? "" : ek["timestamp"].format("%d")) + "|" + (ek["actor"] == null ? "" : ek["actor"]) + "|" + (ek["value"] == null ? "" : ek["value"].format("%d")) + "|" + (ek["details"] == null ? "" : ek["details"]);
                        _session.addMarker(s3);
                        k = k + 1;
                    }
                    attached = true;
                }
            } catch (ex2) {
                System.println("RUGBY|RugbyActivityRecorder|attachEvents failed ex=" + ex2.toString());
            }
        }

        if (attached) {
            _eventExportState = "exported";
        } else if (eventCount > 0) {
            _eventExportState = RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED;
        } else {
            _eventExportState = "skipped";
        }

        // Attempt to stop/save with up to 3 retries; do not throw — ensure match end can proceed
        var attempts = 0;
        var saved = false;
        while (attempts < 3 && !saved) {
            attempts = attempts + 1;
            try {
                _session.stop();
                _state = RUGBY_RECORDER_STATE_STOPPED;
                _session.save();
                _state = RUGBY_RECORDER_STATE_SAVED;
                _session = null;
                System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents saved exportState=" + _eventExportState + " attempts=" + attempts.format("%d"));
                saved = true;
                return true;
            } catch (ex) {
                System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents attempt " + attempts.format("%d") + " failed ex=" + ex.toString());
                // quick retry; do not block long
            }
        }

        // If we reach here, save failed after retries; record fallback but do not throw
        _fallbackReason = "Recording failed after retries";
        System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents failed after " + attempts.format("%d") + " attempts, exportState=" + _eventExportState);
        return false;
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


