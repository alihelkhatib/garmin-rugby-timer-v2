/*
 * File: RugbyGameModel.mc
 * Purpose: Core match state machine: timers, scoring, sanctions, snapshots and haptic event detection.
 * Public API: RugbyGameModel class with APIs to start/pause/resume match, record scores, manage sanctions and produce snapshot(nowMs)
 * Key state: _setup (variant & timers), _clockState, _teams, _conversionTimer, _sanctions, _nextSanctionId, _snapshotId, _lastHapticEvents, _pendingConfirmAction
 * Interactions: RugbyVariantConfig, RugbyTimerDelegate, RugbyTimerView, RugbyHaptics, RugbyActivityRecorder (via delegate flow); tests/Test_RugbyGameModel.mc
 * Example usage: var m=new RugbyGameModel(RugbyVariantConfig.loadPreferences()); m.startMatch(nowMs); var snap=m.snapshot(nowMs)
 * TODOs/notes: Verify corner-cases around half transitions and simultaneous sanction/conversion expiry; add unit tests where missing
 */

import Toybox.Lang;
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
const RUGBY_EVENT_CONVERSION_MADE = "conversionMade";
const RUGBY_PAUSE_REMINDER_INTERVAL_MS = 10000;

class RugbyGameModel {

    var _setup as Dictionary;
    var _clockState as String;
    var _teams as Dictionary;
    var _conversionTimer as Dictionary?;
    var _sanctions as Array<Dictionary>;
    var _nextSanctionId as Number;
    var _snapshotId as Number;
    var _lastHapticEvents as Array<Dictionary>;
    var _pendingConfirmAction as String?;
    var _eventLog as Array<Dictionary>;
    var _nextEventId as Number;
    var _summaryVisible as Boolean;
/* Create teams, default setup and reset timers/snapshots. */

    function initialize(setup as Dictionary?) {
        _setup = setup == null ? RugbyVariantConfig.defaultSetup(RUGBY_DEFAULT_VARIANT) : setup;
        _clockState = RUGBY_STATE_NOT_STARTED;
        _teams = {
            RUGBY_TEAM_HOME => newTeam(RUGBY_TEAM_HOME, _setup["homeLabel"]),
            RUGBY_TEAM_AWAY => newTeam(RUGBY_TEAM_AWAY, _setup["awayLabel"])
        } as Dictionary;
        _conversionTimer = null;
        _sanctions = [] as Array<Dictionary>;
        _nextSanctionId = 1;
        _snapshotId = 0;
        _lastHapticEvents = [] as Array<Dictionary>;
        _pendingConfirmAction = null;
        _eventLog = [] as Array<Dictionary>;
        _nextEventId = 1;
        _summaryVisible = false;
    }

    function setup() as Dictionary {
        return _setup;
    }

    function setVariant(variantId as String) as Void {
        System.println("RUGBY|RugbyGameModel|setVariant requested variantId=" + variantId + " clockState=" + _clockState);
        if (isClockState(RUGBY_STATE_NOT_STARTED)) {
            _setup = RugbyVariantConfig.defaultSetup(variantId);
            System.println("RUGBY|RugbyGameModel|setVariant applied variantId=" + _setup["variantId"] + " variantName=" + _setup["variantName"] + " halfLengthSeconds=" + _setup["halfLengthSeconds"].format("%d") + " sinBinLengthSeconds=" + _setup["sinBinLengthSeconds"].format("%d") + " conversionLengthSeconds=" + _setup["conversionLengthSeconds"].format("%d"));
        } else {
            System.println("RUGBY|RugbyGameModel|setVariant blocked clockState=" + _clockState);
        }
    }

    function adjustHalfMinutes(deltaMinutes as Number) as Void {
        adjustIdleMainTimer(deltaMinutes);
    }

    function adjustIdleMainTimer(deltaMinutes as Number) as Void {
        if (isClockState(RUGBY_STATE_NOT_STARTED)) {
            var oldHalf = _setup["halfLengthSeconds"] as Number;
            _setup = RugbyVariantConfig.adjustHalfMinutes(_setup, deltaMinutes);
            var newHalf = _setup["halfLengthSeconds"] as Number;
            System.println("RUGBY|RugbyGameModel|adjustIdleMainTimer deltaMinutes=" + (deltaMinutes == null ? "null" : deltaMinutes.format("%d")) + " oldHalf=" + (oldHalf == null ? "null" : oldHalf.format("%d")) + " newHalf=" + (newHalf == null ? "null" : newHalf.format("%d")));
        }
    }

    function setSinBinSeconds(seconds as Number) as Void {
        _setup = RugbyVariantConfig.withSinBinSeconds(_setup, seconds);
    }

    function setConversionSeconds(seconds as Number) as Void {
        _setup = RugbyVariantConfig.withConversionSeconds(_setup, seconds);
    }

    function savePreferences() as Void {
        RugbyVariantConfig.savePreferences(_setup);
    }
/* Transition to RUNNING when allowed; set half start time and initialize elapsed counters. */

    function startMatch(nowMs as Number) as Void {
        System.println("RUGBY|RugbyGameModel|startMatch requested nowMs=" + nowMs.format("%d") + " clockState=" + _clockState + " halfIndex=" + (currentHalf()).format("%d") + " activeElapsedMs=" + (_setup["activeElapsedMs"] == null ? "null" : _setup["activeElapsedMs"].format("%d")));
        if (isClockState(RUGBY_STATE_NOT_STARTED) || isClockState(RUGBY_STATE_HALF_ENDED)) {
            if (isClockState(RUGBY_STATE_NOT_STARTED)) {
                clearEventLog("newMatchStart");
                _summaryVisible = false;
            }
            _clockState = RUGBY_STATE_RUNNING;
            _pendingConfirmAction = null;
            if (_setup["halfIndex"] == null) {
                _setup["halfIndex"] = 1;
            }
            _setup["halfStartedAtMs"] = nowMs;
            if (_setup["activeElapsedMs"] == null) {
                _setup["activeElapsedMs"] = 0;
            }
            System.println("RUGBY|RugbyGameModel|startMatch applied clockState=" + _clockState + " halfStartedAtMs=" + (_setup["halfStartedAtMs"] == null ? "null" : _setup["halfStartedAtMs"].format("%d")) + " activeElapsedMs=" + (_setup["activeElapsedMs"] == null ? "null" : _setup["activeElapsedMs"].format("%d")));
        } else {
            System.println("RUGBY|RugbyGameModel|startMatch ignored clockState=" + _clockState);
        }
    }
/* If running, persist active elapsed ms and mark PAUSED. */

    function pause(nowMs as Number) as Void {
        System.println("RUGBY|RugbyGameModel|pause requested nowMs=" + nowMs.format("%d") + " clockState=" + _clockState);
        if (isClockState(RUGBY_STATE_RUNNING)) {
            _setup["activeElapsedMs"] = activeElapsedMs(nowMs);
            _clockState = RUGBY_STATE_PAUSED;
            System.println("RUGBY|RugbyGameModel|pause applied activeElapsedMs=" + (_setup["activeElapsedMs"] == null ? "null" : _setup["activeElapsedMs"].format("%d")) + " clockState=" + _clockState + " pauseReminderIntervalMs=" + RUGBY_PAUSE_REMINDER_INTERVAL_MS.format("%d"));
        } else {
            System.println("RUGBY|RugbyGameModel|pause ignored clockState=" + _clockState);
        }
    }
/* If paused, set halfStartedAtMs to now and mark RUNNING. */

    function resume(nowMs as Number) as Void {
        System.println("RUGBY|RugbyGameModel|resume requested nowMs=" + nowMs.format("%d") + " clockState=" + _clockState);
        if (isClockState(RUGBY_STATE_PAUSED)) {
            _setup["halfStartedAtMs"] = nowMs;
            _clockState = RUGBY_STATE_RUNNING;
            System.println("RUGBY|RugbyGameModel|resume applied halfStartedAtMs=" + (_setup["halfStartedAtMs"] == null ? "null" : _setup["halfStartedAtMs"].format("%d")) + " activeElapsedMs=" + (_setup["activeElapsedMs"] == null ? "null" : _setup["activeElapsedMs"].format("%d")) + " clockState=" + _clockState);
        } else {
            System.println("RUGBY|RugbyGameModel|resume ignored clockState=" + _clockState);
        }
    }
/* Mark pending confirmation to end the current half; do not mutate timers yet. */

    function requestEndHalf() as Void {
        if (isClockState(RUGBY_STATE_RUNNING) || isClockState(RUGBY_STATE_PAUSED) || isClockState(RUGBY_STATE_HALF_ENDED)) {
            _pendingConfirmAction = "endHalf";
        }
    }
/* Request confirmation to end match and save; caller handles recorder. */

    function requestEndMatchSave() as Void {
        if (!isClockState(RUGBY_STATE_MATCH_ENDED)) {
            _pendingConfirmAction = "endMatchSave";
        }
    }

    function requestResetMatch() as Void {
        _pendingConfirmAction = "resetMatch";
    }

    function cancelPendingAction() as Void {
        _pendingConfirmAction = null;
    }
/* If a pending confirm action exists, perform it (endHalf or endMatch) and return true. */

    function confirmPending(nowMs as Number) as Boolean {
        if (valueEquals(_pendingConfirmAction, "endHalf")) {
            endHalf(nowMs);
            return true;
        }
        if (valueEquals(_pendingConfirmAction, "endMatchSave")) {
            endMatch(nowMs);
            return true;
        }
        if (valueEquals(_pendingConfirmAction, "resetMatch")) {
            resetMatch();
            return true;
        }
        return false;
    }
/* Finalize half timing; either end match if last half or advance half index and reset active elapsed. */

    function endHalf(nowMs as Number) as Void {
        if (isClockState(RUGBY_STATE_RUNNING)) {
            _setup["activeElapsedMs"] = activeElapsedMs(nowMs);
        }
        _pendingConfirmAction = null;
        var halfIndex = currentHalf() as Number;
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

    function endMatch(nowMs as Number) as Void {
        if (isClockState(RUGBY_STATE_RUNNING)) {
            _setup["activeElapsedMs"] = activeElapsedMs(nowMs);
        }
        _clockState = RUGBY_STATE_MATCH_ENDED;
        _pendingConfirmAction = null;
        _summaryVisible = true;
        expireActiveTimers(nowMs);
        System.println("RUGBY|RugbyGameModel|endMatch applied nowMs=" + nowMs.format("%d") + " eventCount=" + _eventLog.size().format("%d") + " summaryVisible=" + (_summaryVisible ? "true" : "false"));
    }

    function resetMatch() as Void {
        System.println("RUGBY|RugbyGameModel|resetMatch requested eventCount=" + _eventLog.size().format("%d"));
        var variantId = _setup["variantId"] as String;
        _setup = RugbyVariantConfig.defaultSetup(variantId);
        _clockState = RUGBY_STATE_NOT_STARTED;
        _teams = {
            RUGBY_TEAM_HOME => newTeam(RUGBY_TEAM_HOME, _setup["homeLabel"]),
            RUGBY_TEAM_AWAY => newTeam(RUGBY_TEAM_AWAY, _setup["awayLabel"])
        } as Dictionary;
        _conversionTimer = null;
        _sanctions = [] as Array<Dictionary>;
        _nextSanctionId = 1;
        _pendingConfirmAction = null;
        _lastHapticEvents = [] as Array<Dictionary>;
        clearEventLog("resetMatch");
        _summaryVisible = false;
        System.println("RUGBY|RugbyGameModel|resetMatch applied clockState=" + _clockState + " eventCount=" + _eventLog.size().format("%d"));
    }
/* Apply try points and start the conversion timer for the scoring team. */

    function recordTry(teamId as String, nowMs as Number) as Void {
        var applied = applyScore(teamId, RUGBY_SCORE_TRY, 5, 1) as Boolean;
        if (applied) {
            addEvent(teamId, RUGBY_SCORE_TRY, nowMs);
        }
        startConversionTimer(teamId, nowMs);
    }
/* Apply conversion points and clear conversion timer. */

    function recordConversion(teamId as String) as Boolean {
        return recordConversionAt(teamId, System.getTimer());
    }

    function recordConversionAt(teamId as String, nowMs as Number) as Boolean {
        var applied = applyScore(teamId, RUGBY_SCORE_CONVERSION, 2, 1) as Boolean;
        if (applied) {
            addEvent(teamId, RUGBY_EVENT_CONVERSION_MADE, nowMs);
        }
        clearConversionTimer();
        return applied;
    }

    function missConversion() as Boolean {
        clearConversionTimer();
        return true;
    }

    function clearConversionTimer() as Void {
        if (_conversionTimer != null) {
            _conversionTimer["active"] = false;
        }
    }

    function recordPenaltyGoal(teamId as String) as Void {
        recordPenaltyGoalAt(teamId, System.getTimer());
    }

    function recordPenaltyGoalAt(teamId as String, nowMs as Number) as Void {
        var applied = applyScore(teamId, RUGBY_SCORE_PENALTY_GOAL, 3, 1) as Boolean;
        if (applied) {
            addEvent(teamId, RUGBY_SCORE_PENALTY_GOAL, nowMs);
        }
    }

    function recordDropGoal(teamId as String) as Void {
        recordDropGoalAt(teamId, System.getTimer());
    }

    function recordDropGoalAt(teamId as String, nowMs as Number) as Void {
        var applied = applyScore(teamId, RUGBY_SCORE_DROP_GOAL, 3, 1) as Boolean;
        if (applied) {
            addEvent(teamId, RUGBY_SCORE_DROP_GOAL, nowMs);
        }
    }

    function correctScore(teamId as String, scoreType as String) as Boolean {
        var team = _teams[teamId] as Dictionary?;
        if (team == null) {
            return false;
        }
        if (valueEquals(scoreType, RUGBY_SCORE_TRY) && team["tryCount"] > 0) {
            team["tryCount"] = team["tryCount"] - 1;
            team["score"] = team["score"] - 5;
            return true;
        }
        if (valueEquals(scoreType, RUGBY_SCORE_CONVERSION) && team["conversionCount"] > 0) {
            team["conversionCount"] = team["conversionCount"] - 1;
            team["score"] = team["score"] - 2;
            return true;
        }
        if (valueEquals(scoreType, RUGBY_SCORE_PENALTY_GOAL) && team["penaltyGoalCount"] > 0) {
            team["penaltyGoalCount"] = team["penaltyGoalCount"] - 1;
            team["score"] = team["score"] - 3;
            return true;
        }
        if (valueEquals(scoreType, RUGBY_SCORE_DROP_GOAL) && team["dropGoalCount"] > 0) {
            team["dropGoalCount"] = team["dropGoalCount"] - 1;
            team["score"] = team["score"] - 3;
            return true;
        }
        return false;
    }

    function startYellowCard(teamId as String, nowMs as Number) as Number {
        pauseForCardIfRunning(nowMs, RUGBY_CARD_YELLOW);
        var id = addSanction(teamId, RUGBY_CARD_YELLOW, _setup["sinBinLengthSeconds"], nowMs) as Number;
        addEvent(teamId, "yellowCard", nowMs);
        System.println("RUGBY|RugbyGameModel|startYellowCard teamId=" + teamId + " nowMs=" + nowMs.format("%d") + " sanctionId=" + id.format("%d") + " sinBinSeconds=" + (_setup["sinBinLengthSeconds"] == null ? "null" : _setup["sinBinLengthSeconds"].format("%d")));
        return id;
    }

    function recordRedCard(teamId as String, nowMs as Number) as Number {
        pauseForCardIfRunning(nowMs, RUGBY_CARD_RED);
        var id = addSanction(teamId, RUGBY_CARD_RED, null, nowMs) as Number;
        addEvent(teamId, "redCard", nowMs);
        System.println("RUGBY|RugbyGameModel|recordRedCard teamId=" + teamId + " nowMs=" + nowMs.format("%d") + " sanctionId=" + id.format("%d"));
        return id;
    }

    function clearSanction(sanctionId as Number) as Boolean {
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i] as Dictionary;
            if (sanction["id"] == sanctionId) {
                sanction["state"] = "cleared";
                return true;
            }
        }
        return false;
    }

    function snapshot(nowMs as Number) as Dictionary {
        _snapshotId += 1;
        System.println("RUGBY|RugbyGameModel|snapshot nowMs=" + nowMs.format("%d") + " snapshotId=" + _snapshotId.format("%d") + " clockState=" + _clockState + " pending=" + (_pendingConfirmAction == null ? "null" : _pendingConfirmAction));
        var elapsedMs = activeElapsedMs(nowMs) as Number;
        var countdownSeconds = remainingForDuration(_setup["halfLengthSeconds"], elapsedMs) as Number;
        var conversion = conversionSnapshot(elapsedMs, nowMs) as Dictionary?;
        var sanctions = sanctionSnapshots(elapsedMs) as Array<Dictionary>;
        var hapticEvents = dueHapticEvents(conversion, sanctions) as Array<Dictionary>;
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
            "hapticEvents" => hapticEvents,
            "eventLog" => eventLogSnapshot(),
            "matchSummaryVisible" => _summaryVisible,
            "pauseReminderIntervalMs" => RUGBY_PAUSE_REMINDER_INTERVAL_MS
        } as Dictionary;
    }

    function eventLogSnapshot() as Array<Dictionary> {
        var result = [] as Array<Dictionary>;
        for (var i = 0; i < _eventLog.size(); i += 1) {
            result.add(_eventLog[i]);
        }
        return result;
    }

    function eventLog() as Array<Dictionary> {
        return eventLogSnapshot();
    }

    function currentMatchElapsedSeconds(nowMs as Number) as Number {
        return activeElapsedMs(nowMs) / 1000;
    }

    function markHapticEventsFired(events as Array<Dictionary>) as Void {
        for (var i = 0; i < events.size(); i += 1) {
            var event = events[i] as Dictionary;
            if (valueEquals(event["type"], "conversion") && _conversionTimer != null) {
                _conversionTimer["nearExpiryAlertFired"] = true;
            } else if (valueEquals(event["type"], "yellow")) {
                setSanctionAlertFired(event["id"]);
            }
        }
        _lastHapticEvents = events;
    }

    function activeElapsedMs(nowMs as Number) as Number {
        var base = (_setup["activeElapsedMs"] == null ? 0 : _setup["activeElapsedMs"]) as Number;
        if (isClockState(RUGBY_STATE_RUNNING)) {
            return base + (nowMs - _setup["halfStartedAtMs"]);
        }
        return base;
    }

    function currentHalf() as Number {
        return _setup["halfIndex"] == null ? 1 : _setup["halfIndex"];
    }

    function newTeam(teamId as String, label as String) as Dictionary {
        return {
            "teamId" => teamId,
            "label" => label,
            "score" => 0,
            "tryCount" => 0,
            "conversionCount" => 0,
            "penaltyGoalCount" => 0,
            "dropGoalCount" => 0
        } as Dictionary;
    }
/* Update team score and per-type counters; returns false if teamId invalid. */

    function applyScore(teamId as String, scoreType as String, points as Number, countDelta as Number) as Boolean {
        var team = _teams[teamId] as Dictionary?;
        if (team == null) {
            return false;
        }
        team["score"] = team["score"] + points;
        if (valueEquals(scoreType, RUGBY_SCORE_TRY)) {
            team["tryCount"] = team["tryCount"] + countDelta;
        } else if (valueEquals(scoreType, RUGBY_SCORE_CONVERSION)) {
            team["conversionCount"] = team["conversionCount"] + countDelta;
        } else if (valueEquals(scoreType, RUGBY_SCORE_PENALTY_GOAL)) {
            team["penaltyGoalCount"] = team["penaltyGoalCount"] + countDelta;
        } else if (valueEquals(scoreType, RUGBY_SCORE_DROP_GOAL)) {
            team["dropGoalCount"] = team["dropGoalCount"] + countDelta;
        }
        return true;
    }
/* Create the conversion timer state anchored to current active elapsed ms. */

    function startConversionTimer(teamId as String, nowMs as Number) as Void {
        _conversionTimer = {
            "active" => true,
            "teamId" => teamId,
            "startedAtActiveMs" => activeElapsedMs(nowMs),
            "startedAtMs" => nowMs,
            "durationSeconds" => _setup["conversionLengthSeconds"],
            "nearExpiryAlertFired" => false
        } as Dictionary;
        System.println("RUGBY|RugbyGameModel|startConversionTimer teamId=" + teamId + " nowMs=" + nowMs.format("%d") + " startedAtActiveMs=" + _conversionTimer["startedAtActiveMs"].format("%d") + " startedAtMs=" + _conversionTimer["startedAtMs"].format("%d") + " durationSeconds=" + _conversionTimer["durationSeconds"].format("%d") + " clockState=" + _clockState);
    }
/* Insert a sanction (yellow/red) and return its id; yellow includes duration. */

    function addSanction(teamId as String, cardType as String, durationSeconds as Number?, nowMs as Number) as Number {
        var sanction = {
            "id" => _nextSanctionId,
            "teamId" => teamId,
            "cardType" => cardType,
            "startedAtActiveMs" => activeElapsedMs(nowMs),
            "durationSeconds" => durationSeconds,
            "state" => "active",
            "nearExpiryAlertFired" => false
        } as Dictionary;
        _nextSanctionId += 1;
        _sanctions.add(sanction);
        System.println("RUGBY|RugbyGameModel|addSanction id=" + sanction["id"].format("%d") + " teamId=" + teamId + " cardType=" + cardType + " startedAtActiveMs=" + sanction["startedAtActiveMs"].format("%d") + " durationSeconds=" + (durationSeconds == null ? "null" : durationSeconds.format("%d")) + " count=" + _sanctions.size().format("%d"));
        return sanction["id"];
    }
/* Materialize conversion timer view model and deactivate when expired. */

    function conversionSnapshot(elapsedMs as Number, nowMs as Number) as Dictionary? {
        if (_conversionTimer == null || !_conversionTimer["active"]) {
            return null;
        }
        var remaining = remainingForWallTimer(_conversionTimer, nowMs) as Number;
        if (remaining <= 0) {
            _conversionTimer["active"] = false;
        }
        return {
            "active" => _conversionTimer["active"],
            "teamId" => _conversionTimer["teamId"],
            "remainingSeconds" => remaining,
            "nearExpiryAlertFired" => _conversionTimer["nearExpiryAlertFired"]
        } as Dictionary;
    }
/* Materialize sanctions list for UI, and transition expired yellow cards to expired state. */

    function sanctionSnapshots(elapsedMs as Number) as Array<Dictionary> {
        var result = [] as Array<Dictionary>;
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i] as Dictionary;
            var remaining = null as Number?;
            if (valueEquals(sanction["cardType"], RUGBY_CARD_YELLOW)) {
                remaining = remainingForTimer(sanction, elapsedMs);
                if (remaining <= 0 && valueEquals(sanction["state"], "active")) {
                    sanction["state"] = "expired";
                }
            }
            if (!valueEquals(sanction["state"], "cleared")) {
                result.add({
                    "id" => sanction["id"],
                    "teamId" => sanction["teamId"],
                    "cardType" => sanction["cardType"],
                    "state" => sanction["state"],
                    "remainingSeconds" => remaining,
                    "nearExpiryAlertFired" => sanction["nearExpiryAlertFired"]
                } as Dictionary);
            }
        }
        return result;
    }
/* Return haptic events for conversion or yellow sanctions nearing expiry (<= threshold). */

    function dueHapticEvents(conversion as Dictionary?, sanctions as Array<Dictionary>) as Array<Dictionary> {
        var events = [] as Array<Dictionary>;
        if (conversion != null && conversion["active"] && !conversion["nearExpiryAlertFired"] && conversion["remainingSeconds"] <= RUGBY_ALERT_THRESHOLD_SECONDS) {
            events.add({ "type" => "conversion" } as Dictionary);
        }
        for (var i = 0; i < sanctions.size(); i += 1) {
            var sanction = sanctions[i] as Dictionary;
            if (valueEquals(sanction["cardType"], RUGBY_CARD_YELLOW) && valueEquals(sanction["state"], "active") && !sanction["nearExpiryAlertFired"] && sanction["remainingSeconds"] <= RUGBY_ALERT_THRESHOLD_SECONDS) {
                events.add({ "type" => "yellow", "id" => sanction["id"] } as Dictionary);
            }
        }
        return events;
    }

    function setSanctionAlertFired(sanctionId as Number) as Void {
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i] as Dictionary;
            if (sanction["id"] == sanctionId) {
                sanction["nearExpiryAlertFired"] = true;
            }
        }
    }
/* Compute remaining seconds for a timer, clamped to zero. */

    function remainingForTimer(timer as Dictionary, elapsedMs as Number) as Number {
        var elapsedSeconds = ((elapsedMs - timer["startedAtActiveMs"]) / 1000) as Number;
        var remaining = (timer["durationSeconds"] - elapsedSeconds) as Number;
        return remaining < 0 ? 0 : remaining;
    }

    function remainingForWallTimer(timer as Dictionary, nowMs as Number) as Number {
        var elapsedSeconds = ((nowMs - timer["startedAtMs"]) / 1000) as Number;
        var remaining = (timer["durationSeconds"] - elapsedSeconds) as Number;
        return remaining < 0 ? 0 : remaining;
    }

    function remainingForDuration(durationSeconds as Number, elapsedMs as Number) as Number {
        var remaining = (durationSeconds - (elapsedMs / 1000)) as Number;
        return remaining < 0 ? 0 : remaining;
    }
/* Force-disable conversion and active yellow timers when match ends. */

    function expireActiveTimers(nowMs as Number) as Void {
        if (_conversionTimer != null) {
            _conversionTimer["active"] = false;
        }
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i] as Dictionary;
            if (valueEquals(sanction["cardType"], RUGBY_CARD_YELLOW) && valueEquals(sanction["state"], "active")) {
                sanction["state"] = "expired";
            }
        }
    }

    function pauseForCardIfRunning(nowMs as Number, cardType as String) as Boolean {
        if (isClockState(RUGBY_STATE_RUNNING)) {
            System.println("RUGBY|RugbyGameModel|pauseForCardIfRunning cardType=" + cardType + " nowMs=" + nowMs.format("%d"));
            pause(nowMs);
            return true;
        }
        System.println("RUGBY|RugbyGameModel|pauseForCardIfRunning no-op cardType=" + cardType + " clockState=" + _clockState);
        return false;
    }

    function addEvent(teamId as String, action as String, nowMs as Number) as Void {
        var matchSeconds = currentMatchElapsedSeconds(nowMs) as Number;
        var entry = {
            "id" => _nextEventId,
            "teamId" => teamId,
            "action" => action,
            "matchElapsedSeconds" => matchSeconds,
            "createdAtSnapshotId" => _snapshotId
        } as Dictionary;
        _nextEventId += 1;
        _eventLog.add(entry);
        System.println("RUGBY|RugbyGameModel|addEvent id=" + entry["id"].format("%d") + " teamId=" + teamId + " action=" + action + " matchElapsedSeconds=" + matchSeconds.format("%d") + " eventCount=" + _eventLog.size().format("%d"));
    }

    function clearEventLog(reason as String) as Void {
        System.println("RUGBY|RugbyGameModel|clearEventLog reason=" + reason + " oldCount=" + _eventLog.size().format("%d"));
        _eventLog = [] as Array<Dictionary>;
        _nextEventId = 1;
    }

    function isClockState(expected as String) as Boolean {
        return valueEquals(_clockState, expected);
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }
}
