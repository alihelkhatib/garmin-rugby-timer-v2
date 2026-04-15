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
    var _exportRetryCount as Number;
    var _pendingEventLog as Array<Dictionary>?;
    var _lastExportDiagnostic as Dictionary?;
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

    function stopAndSaveWithEvents(eventLog as Array<Dictionary>?) {
        var eventCount = eventLog == null ? 0 : eventLog.size();
        // Default export state; update if we successfully attach/export events
        _eventExportState = eventCount > 0 ? RUGBY_RECORDER_EVENT_EXPORT_UNSUPPORTED : "skipped";
        System.println("RUGBY|RugbyActivityRecorder|stopAndSaveWithEvents eventCount=" + ("" + eventCount) + " exportState=" + _eventExportState);

        if (_session == null) {
            return false;
        }

        var attached = false;
        if (eventCount > 0) {
            try {
                // Prefer addEvent for maximum compatibility
                if (_session has :addEvent) {
                    var idx = 0;
                    while (idx < eventCount) {
                        var ev = eventLog[idx];
                        _session.addEvent(ev["type"], ev["timestamp"], ev["actor"], ev["value"], ev["details"]);
                        idx = idx + 1;
                    }
                    attached = true;
                } else {
                    attached = false;
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
function emitActivityExportDiagnostic(payload as Dictionary) {
        try {
            _lastExportDiagnostic = payload;
            var status = payload["status"] == null ? "" : payload["status"];
            var attempts = payload["attempts"] == null ? "null" : ("" + payload["attempts"]);
            var exportState = payload["exportState"] == null ? "" : payload["exportState"];
            var error = payload["error"] == null ? null : payload["error"];
            var diag = "{\"status\":\"" + status + "\",\"attempts\":" + attempts + ",\"exportState\":\"" + exportState + "\"" + (error != null ? (",\"error\":\"" + error + "\"") : "") + "}";
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

    function _startExportRetries(eventLog as Array<Dictionary>?) {
        _pendingEventLog = eventLog;
        _exportRetryCount = 0;
        if (RUGBY_RECORDER_MAX_EXPORT_RETRIES > 0) {
            var delay = RUGBY_RECORDER_EXPORT_BACKOFFS[0];
            if (_exportRetryTimer == null) {
                _exportRetryTimer = new Timer.Timer();
            }
            _exportRetryTimer.start(method(:_onExportRetryTimer), delay, false);
            System.println("RUGBY|RugbyActivityRecorder|scheduled export retry #1 in " + ("" + delay) + "ms");
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
                if (_session has :addEvent) {
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
            System.println("RUGBY|RugbyActivityRecorder|exportRetry saved exportState=" + _eventExportState + " attempts=" + ("" + attemptNumber));
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
            System.println("RUGBY|RugbyActivityRecorder|exportRetry attempt " + ("" + attemptNumber) + " failed ex=" + ex2.toString());
            emitActivityExportDiagnostic({"status" => "retry_failed", "attempts" => attemptNumber, "error" => ex2.toString()});
            if (_exportRetryCount < RUGBY_RECORDER_MAX_EXPORT_RETRIES) {
                var nextDelay = RUGBY_RECORDER_EXPORT_BACKOFFS[_exportRetryCount];
                if (_exportRetryTimer == null) {
                    _exportRetryTimer = new Timer.Timer();
                }
                _exportRetryTimer.start(method(:_onExportRetryTimer), nextDelay, false);
                System.println("RUGBY|RugbyActivityRecorder|scheduled next export retry #" + ("" + (_exportRetryCount+1)) + " in " + ("" + nextDelay) + "ms");
            } else {
                System.println("RUGBY|RugbyActivityRecorder|exportRetry exhausted attempts=" + ("" + attemptNumber));
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


