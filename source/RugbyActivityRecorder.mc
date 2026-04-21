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
import Toybox.Position;
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
    var _motionPollTimer;
    var _motionPollActive;
    var _motionData;
    var _motionSampleCount;
/* Initialize recorder state; no session active by default. */

    function initialize() {
        _session = null;
        _state = RUGBY_RECORDER_STATE_NOT_STARTED;
        _fallbackReason = null;
        _eventExportState = "skipped";
        _exportRetryTimer = null;
        _exportRetryCount = 0;
        _pendingEventLog = null;
        _motionPollTimer = null;
        _motionPollActive = false;
        _motionData = initialMotionData();
        _motionSampleCount = 0;
    }
/* Try to create and start an ActivityRecording session. Returns false if unsupported or on error. */

    function start() {
        if (!(ActivityRecording has :createSession)) {
            _state = RUGBY_RECORDER_STATE_UNSUPPORTED;
            _fallbackReason = "ActivityRecording unavailable";
            return false;
        }

        // Determine sport mapping with graceful fallback when device lacks SPORT_RUGBY
        var sport = Activity.SPORT_GENERIC;
        var subSport = Activity.SPORT_GENERIC;
        if (Activity has :SPORT_RUGBY) {
            sport = Activity.SPORT_RUGBY;
            _fallbackReason = null;
        } else if (Activity has :SPORT_TEAM_SPORT) {
            sport = Activity.SPORT_TEAM_SPORT;
            _fallbackReason = "SPORT_TEAM_SPORT fallback";
        } else {
            _fallbackReason = "SPORT_GENERIC fallback";
        }
        if (Activity has :SUB_SPORT_MATCH) {
            subSport = Activity.SUB_SPORT_MATCH;
        }

        try {
            _session = ActivityRecording.createSession({
                :sport => sport,
                :subSport => subSport,
                :name => "Rugby Match"
            });
            _session.start();
            _state = RUGBY_RECORDER_STATE_RECORDING;
            _eventExportState = "skipped";
            _motionData = initialMotionData();
            _motionSampleCount = 0;
            startMotionPolling();
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

        captureMotionData();
        stopMotionPolling();

        var attached = false;
        if (eventCount > 0) {
            // No compatible ActivityRecording event attachment API is available on this device.
            // Preserve the event count for diagnostics and continue without blocking match end.
            attached = false;
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
            _pendingEventLog = null;
            _exportRetryCount = 0;
            if (_exportRetryTimer != null) {
                _exportRetryTimer.stop();
                _exportRetryTimer = null;
            }
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
        _pendingEventLog = null;
        if (_exportRetryTimer != null) {
            _exportRetryTimer.stop();
            _exportRetryTimer = null;
        }
        _exportRetryCount = 0;
        stopMotionPolling();
        _motionData = initialMotionData();
        _motionSampleCount = 0;
        return true;
    }

    function state() {
        return _state;
    }

    function fallbackReason() {
        return _fallbackReason;
    }

    function initialMotionData() as Dictionary {
        return {
            "distance" => null,
            "currentSpeed" => null,
            "averageSpeed" => null,
            "routeSamples" => [] as Array<Dictionary>
        } as Dictionary;
    }

    function startMotionPolling() as Void {
        if (_motionPollTimer == null) {
            _motionPollTimer = new Timer.Timer();
        }
        _motionPollTimer.start(method(:_onMotionPollTimer), 1000, true);
        _motionPollActive = true;
        captureMotionData();
    }

    function stopMotionPolling() as Void {
        if (_motionPollTimer != null && _motionPollActive) {
            _motionPollTimer.stop();
        }
        _motionPollActive = false;
    }

    function _onMotionPollTimer() as Void {
        captureMotionData();
    }

    function captureMotionData() as Void {
        var nextData = initialMotionData();
        var activityInfo = null;
        try {
            activityInfo = Activity.getActivityInfo();
        } catch (ex) {
            activityInfo = null;
        }

        if (activityInfo != null) {
            if (activityInfo.elapsedDistance != null) {
                nextData["distance"] = activityInfo.elapsedDistance;
            }
            if (activityInfo.currentSpeed != null) {
                nextData["currentSpeed"] = activityInfo.currentSpeed;
            }
            if (activityInfo.averageSpeed != null) {
                nextData["averageSpeed"] = activityInfo.averageSpeed;
            }
            if (activityInfo.currentLocation != null) {
                appendRouteSample(nextData, activityInfo.currentLocation, "activity");
            }
        }

        var positionInfo = null;
        try {
            positionInfo = Position.getInfo();
        } catch (ex2) {
            positionInfo = null;
        }

        if (positionInfo != null) {
            if (nextData["currentSpeed"] == null && positionInfo.speed != null) {
                nextData["currentSpeed"] = positionInfo.speed;
            }
            if (positionInfo.position != null) {
                appendRouteSample(nextData, positionInfo.position, "position");
            }
        }

        _motionData = nextData;
        _motionSampleCount += 1;
    }

    function appendRouteSample(motion as Dictionary, location, source as String) as Void {
        var samples = motion["routeSamples"] as Array<Dictionary>;
        var coordinates = location.toDegrees();
        samples.add({
            "source" => source,
            "latitude" => coordinates[0],
            "longitude" => coordinates[1]
        } as Dictionary);
        if (samples.size() > 30) {
            var trimmed = [] as Array<Dictionary>;
            for (var i = samples.size() - 30; i < samples.size(); i += 1) {
                trimmed.add(samples[i]);
            }
            motion["routeSamples"] = trimmed;
        }
    }

    function emitActivityExportDiagnostic(payload) {
        var diag = payload.toString();
        System.println("RUGBY_DIAG|activity_export|" + diag);
    }

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
                // Event attachment not supported on this device; proceed with retrying stop/save only.
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
            "sport" => Activity has :SPORT_RUGBY ? "Activity.SPORT_RUGBY" : (Activity has :SPORT_TEAM_SPORT ? "Activity.SPORT_TEAM_SPORT" : "Activity.SPORT_GENERIC"),
            "subSport" => Activity has :SUB_SPORT_MATCH ? "Activity.SUB_SPORT_MATCH" : "Activity.SUB_SPORT_GENERIC",
            "fallbackReason" => _fallbackReason,
            "eventExportState" => _eventExportState,
            "motionData" => _motionData,
            "motionSampleCount" => _motionSampleCount
        };
    }
}


