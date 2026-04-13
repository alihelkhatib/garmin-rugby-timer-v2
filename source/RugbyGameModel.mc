/*
 * File: RugbyGameModel.mc
 * Purpose: Core match state machine: timers, scoring, sanctions, snapshots and haptic event detection.
 * Public API: RugbyGameModel class with APIs to start/pause/resume match, record scores, manage sanctions and produce snapshot(nowMs)
 * Key state: _setup (variant & timers), _clockState, _teams, _conversionTimer, _sanctions, _nextSanctionId, _snapshotId, _lastHapticEvents, _pendingConfirmAction
 * Interactions: RugbyVariantConfig, RugbyTimerDelegate, RugbyTimerView, RugbyHaptics, RugbyActivityRecorder (via delegate flow); tests/Test_RugbyGameModel.mc
 * Example usage: var m=new RugbyGameModel(RugbyVariantConfig.loadPreferences()); m.startMatch(nowMs); var snap=m.snapshot(nowMs)
 * TODOs/notes: Verify corner-cases around half transitions and simultaneous sanction/conversion expiry; add unit tests where missing
 */

import Toybox.System;

const RUGBY_TEAM_HOME = "home";
const RUGBY_TEAM_AWAY = "away";
const RUGBY_STATE_NOT_STARTED = "notStarted";
const RUGBY_STATE_RUNNING = "running";
const RUGBY_STATE_PAUSED = "paused";
const RUGBY_STATE_HALF_ENDED = "halfEnded";
const RUGBY_STATE_MATCH_ENDED = "matchEnded";
const RUGBY_SCORE_TRY = "try";
const RUGBY_SCORE_CONVERSION = "conversion";
const RUGBY_SCORE_PENALTY_GOAL = "penaltyGoal";
const RUGBY_SCORE_DROP_GOAL = "dropGoal";
const RUGBY_CARD_YELLOW = "yellow";
const RUGBY_CARD_RED = "red";

class RugbyGameModel {

    var _setup;
    var _clockState;
    var _teams;
    var _conversionTimer;
    var _sanctions;
    var _nextSanctionId;
    var _snapshotId;
    var _lastHapticEvents;
    var _pendingConfirmAction;
/* Create teams, default setup and reset timers/snapshots. */

    function initialize(setup) {
        _setup = setup == null ? RugbyVariantConfig.defaultSetup(RUGBY_DEFAULT_VARIANT) : setup;
        _clockState = RUGBY_STATE_NOT_STARTED;
        _teams = {
            RUGBY_TEAM_HOME => newTeam(RUGBY_TEAM_HOME, _setup["homeLabel"]),
            RUGBY_TEAM_AWAY => newTeam(RUGBY_TEAM_AWAY, _setup["awayLabel"])
        };
        _conversionTimer = null;
        _sanctions = [];
        _nextSanctionId = 1;
        _snapshotId = 0;
        _lastHapticEvents = [];
        _pendingConfirmAction = null;
    }

    function setup() {
        return _setup;
    }

    function setVariant(variantId) {
        if (_clockState == RUGBY_STATE_NOT_STARTED || _clockState == RUGBY_STATE_HALF_ENDED) {
            _setup = RugbyVariantConfig.defaultSetup(variantId);
        }
    }

    function adjustHalfMinutes(deltaMinutes) {
        if (_clockState == RUGBY_STATE_NOT_STARTED || _clockState == RUGBY_STATE_HALF_ENDED) {
            _setup = RugbyVariantConfig.adjustHalfMinutes(_setup, deltaMinutes);
        }
    }

    function setSinBinSeconds(seconds) {
        _setup = RugbyVariantConfig.withSinBinSeconds(_setup, seconds);
    }

    function setConversionSeconds(seconds) {
        _setup = RugbyVariantConfig.withConversionSeconds(_setup, seconds);
    }

    function savePreferences() {
        RugbyVariantConfig.savePreferences(_setup);
    }
/* Transition to RUNNING when allowed; set half start time and initialize elapsed counters. */

    function startMatch(nowMs) {
        if (_clockState == RUGBY_STATE_NOT_STARTED || _clockState == RUGBY_STATE_HALF_ENDED) {
            _clockState = RUGBY_STATE_RUNNING;
            _pendingConfirmAction = null;
            if (_setup["halfIndex"] == null) {
                _setup["halfIndex"] = 1;
            }
            _setup["halfStartedAtMs"] = nowMs;
            if (_setup["activeElapsedMs"] == null) {
                _setup["activeElapsedMs"] = 0;
            }
        }
    }
/* If running, persist active elapsed ms and mark PAUSED. */

    function pause(nowMs) {
        if (_clockState == RUGBY_STATE_RUNNING) {
            _setup["activeElapsedMs"] = activeElapsedMs(nowMs);
            _clockState = RUGBY_STATE_PAUSED;
        }
    }
/* If paused, set halfStartedAtMs to now and mark RUNNING. */

    function resume(nowMs) {
        if (_clockState == RUGBY_STATE_PAUSED) {
            _setup["halfStartedAtMs"] = nowMs;
            _clockState = RUGBY_STATE_RUNNING;
        }
    }
/* Mark pending confirmation to end the current half; do not mutate timers yet. */

    function requestEndHalf() {
        if (_clockState == RUGBY_STATE_RUNNING || _clockState == RUGBY_STATE_PAUSED || _clockState == RUGBY_STATE_HALF_ENDED) {
            _pendingConfirmAction = "endHalf";
        }
    }
/* Request confirmation to end match and save; caller handles recorder. */

    function requestEndMatchSave() {
        if (_clockState != RUGBY_STATE_MATCH_ENDED) {
            _pendingConfirmAction = "endMatchSave";
        }
    }

    function cancelPendingAction() {
        _pendingConfirmAction = null;
    }
/* If a pending confirm action exists, perform it (endHalf or endMatch) and return true. */

    function confirmPending(nowMs) {
        if (_pendingConfirmAction == "endHalf") {
            endHalf(nowMs);
            return true;
        }
        if (_pendingConfirmAction == "endMatchSave") {
            endMatch(nowMs);
            return true;
        }
        return false;
    }
/* Finalize half timing; either end match if last half or advance half index and reset active elapsed. */

    function endHalf(nowMs) {
        if (_clockState == RUGBY_STATE_RUNNING) {
            _setup["activeElapsedMs"] = activeElapsedMs(nowMs);
        }
        _pendingConfirmAction = null;
        var halfIndex = currentHalf();
        if (halfIndex >= _setup["halfCount"]) {
            endMatch(nowMs);
        } else {
            _clockState = RUGBY_STATE_HALF_ENDED;
            _setup["halfIndex"] = halfIndex + 1;
            _setup["activeElapsedMs"] = 0;
            _setup["halfStartedAtMs"] = nowMs;
        }
    }
/* Finalize match state, persist elapsed time if running and expire active timers. */

    function endMatch(nowMs) {
        if (_clockState == RUGBY_STATE_RUNNING) {
            _setup["activeElapsedMs"] = activeElapsedMs(nowMs);
        }
        _clockState = RUGBY_STATE_MATCH_ENDED;
        _pendingConfirmAction = null;
        expireActiveTimers(nowMs);
    }
/* Apply try points and start the conversion timer for the scoring team. */

    function recordTry(teamId, nowMs) {
        applyScore(teamId, RUGBY_SCORE_TRY, 5, 1);
        startConversionTimer(teamId, nowMs);
    }
/* Apply conversion points and clear conversion timer. */

    function recordConversion(teamId) {
        var applied = applyScore(teamId, RUGBY_SCORE_CONVERSION, 2, 1);
        clearConversionTimer();
        return applied;
    }

    function missConversion() {
        clearConversionTimer();
        return true;
    }

    function clearConversionTimer() {
        if (_conversionTimer != null) {
            _conversionTimer["active"] = false;
        }
    }

    function recordPenaltyGoal(teamId) {
        applyScore(teamId, RUGBY_SCORE_PENALTY_GOAL, 3, 1);
    }

    function recordDropGoal(teamId) {
        applyScore(teamId, RUGBY_SCORE_DROP_GOAL, 3, 1);
    }

    function correctScore(teamId, scoreType) {
        var team = _teams[teamId];
        if (team == null) {
            return false;
        }
        if (scoreType == RUGBY_SCORE_TRY && team["tryCount"] > 0) {
            team["tryCount"] = team["tryCount"] - 1;
            team["score"] = team["score"] - 5;
            return true;
        }
        if (scoreType == RUGBY_SCORE_CONVERSION && team["conversionCount"] > 0) {
            team["conversionCount"] = team["conversionCount"] - 1;
            team["score"] = team["score"] - 2;
            return true;
        }
        if (scoreType == RUGBY_SCORE_PENALTY_GOAL && team["penaltyGoalCount"] > 0) {
            team["penaltyGoalCount"] = team["penaltyGoalCount"] - 1;
            team["score"] = team["score"] - 3;
            return true;
        }
        if (scoreType == RUGBY_SCORE_DROP_GOAL && team["dropGoalCount"] > 0) {
            team["dropGoalCount"] = team["dropGoalCount"] - 1;
            team["score"] = team["score"] - 3;
            return true;
        }
        return false;
    }

    function startYellowCard(teamId, nowMs) {
        return addSanction(teamId, RUGBY_CARD_YELLOW, _setup["sinBinLengthSeconds"], nowMs);
    }

    function recordRedCard(teamId, nowMs) {
        return addSanction(teamId, RUGBY_CARD_RED, null, nowMs);
    }

    function clearSanction(sanctionId) {
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i];
            if (sanction["id"] == sanctionId) {
                sanction["state"] = "cleared";
                return true;
            }
        }
        return false;
    }

    function snapshot(nowMs) {
        _snapshotId += 1;
        var elapsedMs = activeElapsedMs(nowMs);
        var countdownSeconds = remainingForDuration(_setup["halfLengthSeconds"], elapsedMs);
        var conversion = conversionSnapshot(elapsedMs);
        var sanctions = sanctionSnapshots(elapsedMs);
        var hapticEvents = dueHapticEvents(conversion, sanctions);
        return {
            "snapshotId" => _snapshotId,
            "clockState" => _clockState,
            "pendingConfirmAction" => _pendingConfirmAction,
            "variantId" => _setup["variantId"],
            "variantName" => _setup["variantName"],
            "halfIndex" => currentHalf(),
            "halfCount" => _setup["halfCount"],
            "mainCountdownSeconds" => countdownSeconds,
            "countUpSeconds" => elapsedMs / 1000,
            "home" => _teams[RUGBY_TEAM_HOME],
            "away" => _teams[RUGBY_TEAM_AWAY],
            "conversionTimer" => conversion,
            "sanctions" => sanctions,
            "hapticEvents" => hapticEvents
        };
    }

    function markHapticEventsFired(events) {
        for (var i = 0; i < events.size(); i += 1) {
            var event = events[i];
            if (event["type"] == "conversion" && _conversionTimer != null) {
                _conversionTimer["nearExpiryAlertFired"] = true;
            } else if (event["type"] == "yellow") {
                setSanctionAlertFired(event["id"]);
            }
        }
        _lastHapticEvents = events;
    }

    function activeElapsedMs(nowMs) {
        var base = _setup["activeElapsedMs"] == null ? 0 : _setup["activeElapsedMs"];
        if (_clockState == RUGBY_STATE_RUNNING) {
            return base + (nowMs - _setup["halfStartedAtMs"]);
        }
        return base;
    }

    function currentHalf() {
        return _setup["halfIndex"] == null ? 1 : _setup["halfIndex"];
    }

    function newTeam(teamId, label) {
        return {
            "teamId" => teamId,
            "label" => label,
            "score" => 0,
            "tryCount" => 0,
            "conversionCount" => 0,
            "penaltyGoalCount" => 0,
            "dropGoalCount" => 0
        };
    }
/* Update team score and per-type counters; returns false if teamId invalid. */

    function applyScore(teamId, scoreType, points, countDelta) {
        var team = _teams[teamId];
        if (team == null) {
            return false;
        }
        team["score"] = team["score"] + points;
        if (scoreType == RUGBY_SCORE_TRY) {
            team["tryCount"] = team["tryCount"] + countDelta;
        } else if (scoreType == RUGBY_SCORE_CONVERSION) {
            team["conversionCount"] = team["conversionCount"] + countDelta;
        } else if (scoreType == RUGBY_SCORE_PENALTY_GOAL) {
            team["penaltyGoalCount"] = team["penaltyGoalCount"] + countDelta;
        } else if (scoreType == RUGBY_SCORE_DROP_GOAL) {
            team["dropGoalCount"] = team["dropGoalCount"] + countDelta;
        }
        return true;
    }
/* Create the conversion timer state anchored to current active elapsed ms. */

    function startConversionTimer(teamId, nowMs) {
        _conversionTimer = {
            "active" => true,
            "teamId" => teamId,
            "startedAtActiveMs" => activeElapsedMs(nowMs),
            "durationSeconds" => _setup["conversionLengthSeconds"],
            "nearExpiryAlertFired" => false
        };
    }
/* Insert a sanction (yellow/red) and return its id; yellow includes duration. */

    function addSanction(teamId, cardType, durationSeconds, nowMs) {
        var sanction = {
            "id" => _nextSanctionId,
            "teamId" => teamId,
            "cardType" => cardType,
            "startedAtActiveMs" => activeElapsedMs(nowMs),
            "durationSeconds" => durationSeconds,
            "state" => "active",
            "nearExpiryAlertFired" => false
        };
        _nextSanctionId += 1;
        _sanctions.add(sanction);
        return sanction["id"];
    }
/* Materialize conversion timer view model and deactivate when expired. */

    function conversionSnapshot(elapsedMs) {
        if (_conversionTimer == null || !_conversionTimer["active"]) {
            return null;
        }
        var remaining = remainingForTimer(_conversionTimer, elapsedMs);
        if (remaining <= 0) {
            _conversionTimer["active"] = false;
        }
        return {
            "active" => _conversionTimer["active"],
            "teamId" => _conversionTimer["teamId"],
            "remainingSeconds" => remaining,
            "nearExpiryAlertFired" => _conversionTimer["nearExpiryAlertFired"]
        };
    }
/* Materialize sanctions list for UI, and transition expired yellow cards to expired state. */

    function sanctionSnapshots(elapsedMs) {
        var result = [];
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i];
            var remaining = null;
            if (sanction["cardType"] == RUGBY_CARD_YELLOW) {
                remaining = remainingForTimer(sanction, elapsedMs);
                if (remaining <= 0 && sanction["state"] == "active") {
                    sanction["state"] = "expired";
                }
            }
            if (sanction["state"] != "cleared") {
                result.add({
                    "id" => sanction["id"],
                    "teamId" => sanction["teamId"],
                    "cardType" => sanction["cardType"],
                    "state" => sanction["state"],
                    "remainingSeconds" => remaining,
                    "nearExpiryAlertFired" => sanction["nearExpiryAlertFired"]
                });
            }
        }
        return result;
    }
/* Return haptic events for conversion or yellow sanctions nearing expiry (<= threshold). */

    function dueHapticEvents(conversion, sanctions) {
        var events = [];
        if (conversion != null && conversion["active"] && !conversion["nearExpiryAlertFired"] && conversion["remainingSeconds"] <= RUGBY_ALERT_THRESHOLD_SECONDS) {
            events.add({ "type" => "conversion" });
        }
        for (var i = 0; i < sanctions.size(); i += 1) {
            var sanction = sanctions[i];
            if (sanction["cardType"] == RUGBY_CARD_YELLOW && sanction["state"] == "active" && !sanction["nearExpiryAlertFired"] && sanction["remainingSeconds"] <= RUGBY_ALERT_THRESHOLD_SECONDS) {
                events.add({ "type" => "yellow", "id" => sanction["id"] });
            }
        }
        return events;
    }

    function setSanctionAlertFired(sanctionId) {
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i];
            if (sanction["id"] == sanctionId) {
                sanction["nearExpiryAlertFired"] = true;
            }
        }
    }
/* Compute remaining seconds for a timer, clamped to zero. */

    function remainingForTimer(timer, elapsedMs) {
        var elapsedSeconds = (elapsedMs - timer["startedAtActiveMs"]) / 1000;
        var remaining = timer["durationSeconds"] - elapsedSeconds;
        return remaining < 0 ? 0 : remaining;
    }

    function remainingForDuration(durationSeconds, elapsedMs) {
        var remaining = durationSeconds - (elapsedMs / 1000);
        return remaining < 0 ? 0 : remaining;
    }
/* Force-disable conversion and active yellow timers when match ends. */

    function expireActiveTimers(nowMs) {
        if (_conversionTimer != null) {
            _conversionTimer["active"] = false;
        }
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i];
            if (sanction["cardType"] == RUGBY_CARD_YELLOW && sanction["state"] == "active") {
                sanction["state"] = "expired";
            }
        }
    }
}





