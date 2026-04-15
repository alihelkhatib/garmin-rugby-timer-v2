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
import Toybox.Timer;

const RUGBY_RECORDER_STATE_NOT_STARTED = "notStarted";
const RUGBY_RECORDER_STATE_RECORDING = "recording";
const RUGBY_RECORDER_STATE_STOPPED = "stopped";
const RUGBY_RECORDER_STATE_SAVED = "saved";
const RUGBY_RECORDER_STATE_UNSUPPORTED = "unsupported";
const RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED = "eventExportUnsupported";
const RUGBY_RECORDER_MAX_EXPORT_RETRIES = 3;
const RUGBY_RECORDER_EXPORT_BACKOFFS = [2000, 5000, 10000];

class RugbyActivityRecorder {

    var _session;
    var _state;
    var _fallbackReason;
    var _eventExportState;
    var _exportRetryTimer;
    var _exportRetryCount;
    var _pendingEventLog;
    var _lastExportDiagnostic;
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

        // Attempt to stop/save with non-blocking retries; do not block match end
        try {
            _session.stop();
            _state = RUGBY_RECORDER_STATE_STOPPED;
            _session.save();
            _state = RUGBY_RECORDER_STATE_SAVED;
            _session = null;
            System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents saved exportState=" + _eventExportState + " attempts=1");
            emitActivityExportDiagnostic({"status" => "exported", "attempts" => 1, "exportState" => _eventExportState});
            return true;
        } catch (ex) {
            System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents initial attempt failed ex=" + ex.toString());
            // Schedule non-blocking retries using Timer with configured backoffs
            _startExportRetries(eventLog);
            emitActivityExportDiagnostic({"status" => "initial_failed", "error" => ex.toString(), "exportState" => _eventExportState});
            // Do not block match end; retries will occur asynchronously.
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
function emitActivityExportDiagnostic(payload) {
        try {
            _lastExportDiagnostic = payload;
            var diag = Json.toString(payload);
            System.println("RUGBY_DIAG|activity_export|" + diag);
        } catch (e) {
            System.println("RUGBY|RugbyActivityRecorder|emitActivityExportDiagnostic failed ex=" + e.toString());
        }
    }

    /* Test helpers */
    function setSessionForTest(session) {
        _session = session;
    }

    function getLastExportDiagnosticForTest() {
        return _lastExportDiagnostic;
    }

    function _startExportRetries(eventLog) {

    function _startExportRetries(eventLog) {
        _pendingEventLog = eventLog;
        _exportRetryCount = 0;
        if (RUGBY_RECORDER_MAX_EXPORT_RETRIES > 0) {
            var delay = RUGBY_RECORDER_EXPORT_BACKOFFS[0];
            if (_exportRetryTimer == null) {
                _exportRetryTimer = new Timer.Timer();
            }
            _exportRetryTimer.start(method(:_onExportRetryTimer), delay, false);
            System.println("RUGBY|RugbyActivityRecorder|scheduled export retry #1 in " + delay.format("%d") + "ms");
        } else {
            _fallbackReason = "Recording failed and no retries configured";
            emitActivityExportDiagnostic({"status" => "failed", "attempts" => 0, "exportState" => _eventExportState});
        }
    }

    function _onExportRetryTimer() {
        _exportRetryCount = _exportRetryCount + 1;
        var attemptNumber = _exportRetryCount + 1; // initial attempt + retries
        try {
            if (_pendingEventLog != null && _session != null) {
                var evCount = _pendingEventLog.size();
                if (_session has :appendRecords) {
                    var recs = [];
                    var idx = 0;
                    while (idx < evCount) {
                        var ev = _pendingEventLog[idx];
                        var s = ev["type"] + "|" + (ev["timestamp"] == null ? "" : ev["timestamp"].format("%d")) + "|" + (ev["actor"] == null ? "" : ev["actor"]) + "|" + (ev["value"] == null ? "" : ev["value"].format("%d")) + "|" + (ev["details"] == null ? "" : ev["details"]);
                        recs.add(s);
                        idx = idx + 1;
                    }
                    _session.appendRecords(recs);
                } else if (_session has :addEvent) {
                    var idx2 = 0;
                    while (idx2 < evCount) {
                        var ev2 = _pendingEventLog[idx2];
                        _session.addEvent(ev2["type"], ev2["timestamp"], ev2["actor"], ev2["value"], ev2["details"]);
                        idx2 = idx2 + 1;
                    }
                }
            }
            _session.stop();
            _state = RUGBY_RECORDER_STATE_STOPPED;
            _session.save();
            _state = RUGBY_RECORDER_STATE_SAVED;
            _session = null;
            System.println("RUGBY|RugbyActivityRecorder|exportRetry saved exportState=" + _eventExportState + " attempts=" + attemptNumber.format("%d"));
            emitActivityExportDiagnostic({"status" => "exported", "attempts" => attemptNumber, "exportState" => _eventExportState});
            // cleanup
            _pendingEventLog = null;
            if (_exportRetryTimer != null) {
                _exportRetryTimer.stop();
                _exportRetryTimer = null;
            }
            _exportRetryCount = 0;
            return;
        } catch (ex2) {
            System.println("RUGBY|RugbyActivityRecorder|exportRetry attempt " + attemptNumber.format("%d") + " failed ex=" + ex2.toString());
            emitActivityExportDiagnostic({"status" => "retry_failed", "attempts" => attemptNumber, "error" => ex2.toString()});
            if (_exportRetryCount < RUGBY_RECORDER_MAX_EXPORT_RETRIES) {
                var nextDelay = RUGBY_RECORDER_EXPORT_BACKOFFS[_exportRetryCount];
                if (_exportRetryTimer == null) {
                    _exportRetryTimer = new Timer.Timer();
                }
                _exportRetryTimer.start(method(:_onExportRetryTimer), nextDelay, false);
                System.println("RUGBY|RugbyActivityRecorder|scheduled next export retry #" + (_exportRetryCount+1).format("%d") + " in " + nextDelay.format("%d") + "ms");
            } else {
                System.println("RUGBY|RugbyActivityRecorder|exportRetry exhausted attempts=" + attemptNumber.format("%d"));
                emitActivityExportDiagnostic({"status" => "failed", "attempts" => attemptNumber});
                _fallbackReason = "Recording failed after retries";
                _pendingEventLog = null;
                if (_exportRetryTimer != null) {
                    _exportRetryTimer.stop();
                    _exportRetryTimer = null;
                }
                _exportRetryCount = 0;
            }
        }
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


