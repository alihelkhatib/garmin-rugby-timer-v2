/*
 * File: RugbyGameModel.mc
 * Purpose: Core match state machine: timers, scoring, sanctions, snapshots and haptic event detection.
 * Public API: RugbyGameModel class with APIs to start/pause/resume match, record scores, manage sanctions and produce snapshot(nowMs)
 * Key state: _setup (variant & timers), _clockState, _teams, _conversionTimer, _sanctions, _nextSanctionId, _snapshotId, _lastHapticEvents, _pendingConfirmAction
 * Interactions: RugbyVariantConfig, RugbyTimerDelegate, RugbyTimerView, RugbyHaptics, RugbyActivityRecorder (via delegate flow); tests/Test_RugbyGameModel.mc
 * Example usage: var m=new RugbyGameModel(RugbyVariantConfig.loadPreferences()); m.startMatch(nowMs); var snap=m.snapshot(nowMs)
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
    var _autoMatchEndPendingSave as Boolean;
    var _completedMatchMs as Number;
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
        _autoMatchEndPendingSave = false;
        _completedMatchMs = 0;
    }

    function setup() as Dictionary {
        return _setup;
    }

    function setVariant(variantId as String) as Void {
        if (isClockState(RUGBY_STATE_NOT_STARTED)) {
            _setup = RugbyVariantConfig.defaultSetup(variantId);
        } else {
        }
    }

    function adjustHalfMinutes(deltaMinutes as Number) as Void {
        adjustIdleMainTimer(deltaMinutes);
    }

    function adjustIdleMainTimer(deltaMinutes as Number) as Void {
        if (isClockState(RUGBY_STATE_NOT_STARTED)) {
            _setup = RugbyVariantConfig.adjustHalfMinutes(_setup, deltaMinutes);
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
            resumeCarriedYellowCardsForPeriodStart(nowMs);
        } else {
        }
    }
/* If running, persist active elapsed ms and mark PAUSED. */

    function pause(nowMs as Number) as Void {
        if (isClockState(RUGBY_STATE_RUNNING)) {
            _setup["activeElapsedMs"] = activeElapsedMs(nowMs);
            _clockState = RUGBY_STATE_PAUSED;
        } else {
        }
    }
/* If paused, set halfStartedAtMs to now and mark RUNNING. */

    function resume(nowMs as Number) as Void {
        if (isClockState(RUGBY_STATE_PAUSED)) {
            _setup["halfStartedAtMs"] = nowMs;
            _clockState = RUGBY_STATE_RUNNING;
        } else {
        }
    }
/* Mark pending confirmation to end the current half; do not mutate timers yet. */

    function requestEndHalf() as Void {
        if (isClockState(RUGBY_STATE_RUNNING) || isClockState(RUGBY_STATE_PAUSED)) {
            _pendingConfirmAction = "endHalf";
        }
    }
/* Request confirmation to end match and save; caller handles recorder. */

    function requestEndMatchSave() as Void {
        if (canRecordMatchEvent()) {
            _pendingConfirmAction = "endMatchSave";
        }
    }

    function requestEndMatchExit() as Void {
        if (canRecordMatchEvent()) {
            _pendingConfirmAction = "endMatchExit";
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
        if (valueEquals(_pendingConfirmAction, "endMatchExit")) {
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
        if (!isClockState(RUGBY_STATE_RUNNING) && !isClockState(RUGBY_STATE_PAUSED)) {
            return;
        }
        if (isClockState(RUGBY_STATE_RUNNING)) {
            _setup["activeElapsedMs"] = activeElapsedMs(nowMs);
        }
        _pendingConfirmAction = null;
        var halfIndex = currentHalf() as Number;
        if (halfIndex >= _setup["halfCount"]) {
            endMatch(nowMs);
        } else {
            preserveYellowCardsForPeriodEnd(_setup["activeElapsedMs"]);
            _completedMatchMs += _setup["activeElapsedMs"];
            _clockState = RUGBY_STATE_HALF_ENDED;
            _setup["halfIndex"] = halfIndex + 1;
            _setup["activeElapsedMs"] = 0;
            _setup["halfStartedAtMs"] = nowMs;
        }
    }
/* Finalize match state, persist elapsed time if running and expire active timers. */

    function endMatch(nowMs as Number) as Void {
        if (!canRecordMatchEvent()) {
            return;
        }
        if (isClockState(RUGBY_STATE_RUNNING)) {
            _setup["activeElapsedMs"] = activeElapsedMs(nowMs);
        }
        _clockState = RUGBY_STATE_MATCH_ENDED;
        _pendingConfirmAction = null;
        _summaryVisible = true;
        expireActiveTimers(nowMs);
    }

    function resetMatch() as Void {
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
        _autoMatchEndPendingSave = false;
        _completedMatchMs = 0;
    }
/* Apply try points and start the conversion timer for the scoring team. */

    function recordTry(teamId as String, nowMs as Number) as Void {
        var applied = applyScore(teamId, RUGBY_SCORE_TRY, 5, 1) as Boolean;
        if (applied) {
            addEvent(teamId, RUGBY_SCORE_TRY, nowMs);
            startConversionTimer(teamId, nowMs);
        }
    }
/* Apply conversion points and clear conversion timer. */

    function recordConversion(teamId as String) as Boolean {
        return recordConversionAt(teamId, System.getTimer());
    }

    function recordConversionAt(teamId as String, nowMs as Number) as Boolean {
        if (_conversionTimer == null || !_conversionTimer["active"] || !valueEquals(_conversionTimer["teamId"], teamId)) {
            return false;
        }
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
        if (!canRecordMatchEvent()) {
            return false;
        }
        var team = _teams[teamId] as Dictionary?;
        if (team == null) {
            return false;
        }
        if (valueEquals(scoreType, RUGBY_SCORE_TRY) && team["tryCount"] > 0) {
            team["tryCount"] = team["tryCount"] - 1;
            team["score"] = team["score"] - 5;
            markLatestEventCorrected(teamId, RUGBY_SCORE_TRY);
            return true;
        }
        if (valueEquals(scoreType, RUGBY_SCORE_CONVERSION) && team["conversionCount"] > 0) {
            team["conversionCount"] = team["conversionCount"] - 1;
            team["score"] = team["score"] - 2;
            markLatestEventCorrected(teamId, RUGBY_EVENT_CONVERSION_MADE);
            return true;
        }
        if (valueEquals(scoreType, RUGBY_SCORE_PENALTY_GOAL) && team["penaltyGoalCount"] > 0) {
            team["penaltyGoalCount"] = team["penaltyGoalCount"] - 1;
            team["score"] = team["score"] - 3;
            markLatestEventCorrected(teamId, RUGBY_SCORE_PENALTY_GOAL);
            return true;
        }
        if (valueEquals(scoreType, RUGBY_SCORE_DROP_GOAL) && team["dropGoalCount"] > 0) {
            team["dropGoalCount"] = team["dropGoalCount"] - 1;
            team["score"] = team["score"] - 3;
            markLatestEventCorrected(teamId, RUGBY_SCORE_DROP_GOAL);
            return true;
        }
        return false;
    }

    function startYellowCard(teamId as String, nowMs as Number) as Number {
        if (!canRecordMatchEvent() || _teams[teamId] == null) {
            return -1;
        }
        pauseForCardIfRunning(nowMs, RUGBY_CARD_YELLOW);
        var id = addSanction(teamId, RUGBY_CARD_YELLOW, _setup["sinBinLengthSeconds"], nowMs) as Number;
        addEvent(teamId, "yellowCard", nowMs);
        return id;
    }

    function recordRedCard(teamId as String, nowMs as Number) as Number {
        if (!canRecordMatchEvent() || _teams[teamId] == null) {
            return -1;
        }
        pauseForCardIfRunning(nowMs, RUGBY_CARD_RED);
        var id = addSanction(teamId, RUGBY_CARD_RED, null, nowMs) as Number;
        addEvent(teamId, "redCard", nowMs);
        return id;
    }

    function clearSanction(sanctionId as Number) as Boolean {
        if (!canRecordMatchEvent()) {
            return false;
        }
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i] as Dictionary;
            if (sanction["id"] == sanctionId) {
                sanction["state"] = "cleared";
                return true;
            }
        }
        return false;
    }

    function undoLastEvent() as Boolean {
        if (!canRecordMatchEvent()) {
            return false;
        }
        for (var i = _eventLog.size() - 1; i >= 0; i -= 1) {
            var event = _eventLog[i] as Dictionary;
            if (!valueEquals(event["status"], "active")) {
                continue;
            }
            var teamId = "" + event["teamId"];
            var action = "" + event["action"];
            if (valueEquals(action, RUGBY_SCORE_TRY)) {
                return correctScore(teamId, RUGBY_SCORE_TRY);
            }
            if (valueEquals(action, RUGBY_EVENT_CONVERSION_MADE)) {
                return correctScore(teamId, RUGBY_SCORE_CONVERSION);
            }
            if (valueEquals(action, RUGBY_SCORE_PENALTY_GOAL)) {
                return correctScore(teamId, RUGBY_SCORE_PENALTY_GOAL);
            }
            if (valueEquals(action, RUGBY_SCORE_DROP_GOAL)) {
                return correctScore(teamId, RUGBY_SCORE_DROP_GOAL);
            }
            if (valueEquals(action, "yellowCard") || valueEquals(action, "redCard")) {
                var cardType = valueEquals(action, "yellowCard") ? RUGBY_CARD_YELLOW : RUGBY_CARD_RED;
                for (var j = _sanctions.size() - 1; j >= 0; j -= 1) {
                    var sanction = _sanctions[j] as Dictionary;
                    if (valueEquals(sanction["teamId"], teamId)
                            && valueEquals(sanction["cardType"], cardType)
                            && !valueEquals(sanction["state"], "cleared")) {
                        sanction["state"] = "cleared";
                        event["status"] = "corrected";
                        return true;
                    }
                }
                return false;
            }
        }
        return false;
    }

    function advance(nowMs as Number) as Boolean {
        var before = _clockState as String;
        var timersChanged = applyTimerExpiry(nowMs) as Boolean;
        applyAutomaticCountdownExpiry(nowMs);
        return timersChanged || !before.equals(_clockState);
    }

    function snapshot(nowMs as Number) as Dictionary {
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
            "halfTimeSeconds" => halfTimeElapsedSeconds(nowMs),
            "home" => _teams[RUGBY_TEAM_HOME],
            "away" => _teams[RUGBY_TEAM_AWAY],
            "conversionTimer" => conversion,
            "sanctions" => sanctions,
            "hapticEvents" => hapticEvents,
            "eventLog" => eventLogSnapshot(),
            "matchSummaryVisible" => _summaryVisible,
            "autoMatchEndPendingSave" => _autoMatchEndPendingSave,
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
        return (_completedMatchMs + activeElapsedMs(nowMs)) / 1000;
    }

    function hasRecoverableMatch() as Boolean {
        return isClockState(RUGBY_STATE_RUNNING)
            || isClockState(RUGBY_STATE_PAUSED)
            || isClockState(RUGBY_STATE_HALF_ENDED);
    }

    function consumeAutoMatchEndPendingSave() as Boolean {
        if (_autoMatchEndPendingSave) {
            _autoMatchEndPendingSave = false;
            return true;
        }
        return false;
    }

    function markHapticEventsFired(events as Array<Dictionary>) as Void {
        for (var i = 0; i < events.size(); i += 1) {
            var event = events[i] as Dictionary;
            if (valueEquals(event["type"], "conversion") && _conversionTimer != null) {
                _conversionTimer["nearExpiryAlertFired"] = true;
            } else if (valueEquals(event["type"], "yellowWarning")) {
                setSanctionAlertFired(event["id"], "nearExpiryAlertFired");
            } else if (valueEquals(event["type"], "yellowExpired")) {
                setSanctionAlertFired(event["id"], "expiryAlertFired");
            }
        }
        _lastHapticEvents = events;
    }

    function activeElapsedMs(nowMs as Number) as Number {
        var base = (_setup["activeElapsedMs"] == null ? 0 : _setup["activeElapsedMs"]) as Number;
        if (isClockState(RUGBY_STATE_RUNNING)) {
            return base + RugbyTime.elapsedMs(_setup["halfStartedAtMs"], nowMs);
        }
        return base;
    }

    function halfTimeElapsedSeconds(nowMs as Number) as Number? {
        if (!isClockState(RUGBY_STATE_HALF_ENDED) || _setup["halfStartedAtMs"] == null) {
            return null;
        }
        var elapsedMs = RugbyTime.elapsedMs(_setup["halfStartedAtMs"], nowMs) as Number;
        return elapsedMs / 1000;
    }

    function currentHalf() as Number {
        return _setup["halfIndex"] == null ? 1 : _setup["halfIndex"];
    }

    function isFinalPeriod() as Boolean {
        return currentHalf() >= _setup["halfCount"];
    }

    function isRunningCountdownExpired(nowMs as Number) as Boolean {
        return isClockState(RUGBY_STATE_RUNNING) && activeElapsedMs(nowMs) >= ((_setup["halfLengthSeconds"] as Number) * 1000);
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
        if (!canRecordMatchEvent() || team == null) {
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

    function canRecordMatchEvent() as Boolean {
        return isClockState(RUGBY_STATE_RUNNING)
            || isClockState(RUGBY_STATE_PAUSED)
            || isClockState(RUGBY_STATE_HALF_ENDED);
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
            "nearExpiryAlertFired" => false,
            "expiryAlertFired" => false
        } as Dictionary;
        _nextSanctionId += 1;
        _sanctions.add(sanction);
        return sanction["id"];
    }
/* Materialize conversion timer view model and deactivate when expired. */

    function conversionSnapshot(elapsedMs as Number, nowMs as Number) as Dictionary? {
        if (_conversionTimer == null || !_conversionTimer["active"]) {
            return null;
        }
        var remaining = remainingForWallTimer(_conversionTimer, nowMs) as Number;
        return {
            "active" => remaining > 0,
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
                remaining = valueEquals(sanction["state"], "expired") ? 0 : remainingForTimer(sanction, elapsedMs);
            }
            if (!valueEquals(sanction["state"], "cleared")) {
                var projectedState = sanction["state"];
                if (remaining != null && remaining <= 0 && valueEquals(projectedState, "active")) {
                    projectedState = "expired";
                }
                result.add({
                    "id" => sanction["id"],
                    "teamId" => sanction["teamId"],
                    "cardType" => sanction["cardType"],
                    "state" => projectedState,
                    "remainingSeconds" => remaining,
                    "nearExpiryAlertFired" => sanction["nearExpiryAlertFired"] == true,
                    "expiryAlertFired" => sanction["expiryAlertFired"] == true
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
            if (!valueEquals(sanction["cardType"], RUGBY_CARD_YELLOW)) {
                continue;
            }
            if (valueEquals(sanction["state"], "active")
                    && !sanction["nearExpiryAlertFired"]
                    && sanction["remainingSeconds"] <= RUGBY_ALERT_THRESHOLD_SECONDS
                    && sanction["remainingSeconds"] > 0) {
                events.add({ "type" => "yellowWarning", "id" => sanction["id"] } as Dictionary);
            }
            if (valueEquals(sanction["state"], "expired") && !sanction["expiryAlertFired"]) {
                events.add({ "type" => "yellowExpired", "id" => sanction["id"] } as Dictionary);
            }
        }
        return events;
    }

    function setSanctionAlertFired(sanctionId as Number, fieldName as String) as Void {
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i] as Dictionary;
            if (sanction["id"] == sanctionId) {
                sanction[fieldName] = true;
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
        var elapsedSeconds = (RugbyTime.elapsedMs(timer["startedAtMs"], nowMs) / 1000) as Number;
        var remaining = (timer["durationSeconds"] - elapsedSeconds) as Number;
        return remaining < 0 ? 0 : remaining;
    }

    function remainingForDuration(durationSeconds as Number, elapsedMs as Number) as Number {
        var remaining = (durationSeconds - (elapsedMs / 1000)) as Number;
        return remaining < 0 ? 0 : remaining;
    }

    function applyAutomaticCountdownExpiry(nowMs as Number) as Void {
        if (!isRunningCountdownExpired(nowMs)) {
            return;
        }
        if (isFinalPeriod()) {
            endMatch(nowMs);
            _autoMatchEndPendingSave = true;
        } else {
            endHalf(nowMs);
        }
    }

    function applyTimerExpiry(nowMs as Number) as Boolean {
        var changed = false;
        if (_conversionTimer != null && _conversionTimer["active"] && remainingForWallTimer(_conversionTimer, nowMs) <= 0) {
            _conversionTimer["active"] = false;
            changed = true;
        }
        var elapsedMs = activeElapsedMs(nowMs) as Number;
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i] as Dictionary;
            if (valueEquals(sanction["cardType"], RUGBY_CARD_YELLOW)
                    && valueEquals(sanction["state"], "active")
                    && remainingForTimer(sanction, elapsedMs) <= 0) {
                sanction["state"] = "expired";
                changed = true;
            }
        }
        return changed;
    }

    function preserveYellowCardsForPeriodEnd(elapsedMs as Number) as Void {
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i] as Dictionary;
            if (valueEquals(sanction["cardType"], RUGBY_CARD_YELLOW) && valueEquals(sanction["state"], "active")) {
                var remaining = remainingForTimer(sanction, elapsedMs) as Number;
                if (remaining <= 0) {
                    sanction["state"] = "expired";
                } else {
                    sanction["durationSeconds"] = remaining;
                    sanction["startedAtActiveMs"] = 0;
                    sanction["state"] = "pausedForPeriod";
                }
            }
        }
    }

    function resumeCarriedYellowCardsForPeriodStart(nowMs as Number) as Void {
        var elapsedMs = activeElapsedMs(nowMs) as Number;
        for (var i = 0; i < _sanctions.size(); i += 1) {
            var sanction = _sanctions[i] as Dictionary;
            if (valueEquals(sanction["cardType"], RUGBY_CARD_YELLOW) && valueEquals(sanction["state"], "pausedForPeriod")) {
                sanction["startedAtActiveMs"] = elapsedMs;
                sanction["state"] = "active";
            }
        }
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
                // Match completion is not a natural card expiry and should not
                // trigger a misleading expiry vibration on the summary screen.
                sanction["expiryAlertFired"] = true;
            }
        }
    }

    function pauseForCardIfRunning(nowMs as Number, cardType as String) as Boolean {
        if (isClockState(RUGBY_STATE_RUNNING)) {
            pause(nowMs);
            return true;
        }
        return false;
    }

    function addEvent(teamId as String, action as String, nowMs as Number) as Void {
        var matchSeconds = currentMatchElapsedSeconds(nowMs) as Number;
        _snapshotId += 1;
        var entry = {
            "id" => _nextEventId,
            "teamId" => teamId,
            "action" => action,
            "periodIndex" => currentHalf(),
            "matchElapsedSeconds" => matchSeconds,
            "createdAtSnapshotId" => _snapshotId,
            "status" => "active"
        } as Dictionary;
        _nextEventId += 1;
        _eventLog.add(entry);
    }

    function clearEventLog(reason as String) as Void {
        _eventLog = [] as Array<Dictionary>;
        _nextEventId = 1;
    }

    function recoverySnapshot(nowMs as Number) as Dictionary {
        var storedSetup = RugbyVariantConfig.cloneSetup(_setup) as Dictionary;
        storedSetup["halfIndex"] = currentHalf();
        storedSetup["activeElapsedMs"] = activeElapsedMs(nowMs);

        var storedState = _clockState as String;
        if (isClockState(RUGBY_STATE_RUNNING)) {
            storedState = RUGBY_STATE_PAUSED;
        }

        var storedConversion = null as Dictionary?;
        var conversion = conversionSnapshot(activeElapsedMs(nowMs), nowMs) as Dictionary?;
        if (conversion != null && conversion["active"]) {
            storedConversion = {
                "teamId" => conversion["teamId"],
                "remainingSeconds" => conversion["remainingSeconds"],
                "nearExpiryAlertFired" => conversion["nearExpiryAlertFired"]
            } as Dictionary;
        }

        return {
            "schemaVersion" => 1,
            "clockState" => storedState,
            "setup" => storedSetup,
            "teams" => _teams,
            "sanctions" => _sanctions,
            "nextSanctionId" => _nextSanctionId,
            "eventLog" => _eventLog,
            "nextEventId" => _nextEventId,
            "completedMatchMs" => _completedMatchMs,
            "conversion" => storedConversion
        } as Dictionary;
    }

    function restoreRecovery(saved as Dictionary, nowMs as Number) as Boolean {
        if (saved["schemaVersion"] != 1 || saved["setup"] == null || saved["teams"] == null || saved["clockState"] == null) {
            return false;
        }
        var savedState = "" + saved["clockState"];
        if (!isSupportedRecoveryState(savedState)) {
            return false;
        }

        _setup = saved["setup"] as Dictionary;
        _teams = saved["teams"] as Dictionary;
        _sanctions = saved["sanctions"] == null ? [] as Array<Dictionary> : saved["sanctions"] as Array<Dictionary>;
        _eventLog = saved["eventLog"] == null ? [] as Array<Dictionary> : saved["eventLog"] as Array<Dictionary>;
        _nextSanctionId = saved["nextSanctionId"] == null ? 1 : saved["nextSanctionId"];
        _nextEventId = saved["nextEventId"] == null ? 1 : saved["nextEventId"];
        _completedMatchMs = saved["completedMatchMs"] == null ? 0 : saved["completedMatchMs"];
        _clockState = savedState.equals(RUGBY_STATE_RUNNING) ? RUGBY_STATE_PAUSED : savedState;
        _pendingConfirmAction = null;
        _summaryVisible = _clockState.equals(RUGBY_STATE_MATCH_ENDED);
        _autoMatchEndPendingSave = false;
        _setup["halfStartedAtMs"] = nowMs;

        var conversion = saved["conversion"] as Dictionary?;
        if (conversion != null && conversion["remainingSeconds"] > 0) {
            _conversionTimer = {
                "active" => true,
                "teamId" => conversion["teamId"],
                "startedAtActiveMs" => activeElapsedMs(nowMs),
                "startedAtMs" => nowMs,
                "durationSeconds" => conversion["remainingSeconds"],
                "nearExpiryAlertFired" => conversion["nearExpiryAlertFired"] == true
            } as Dictionary;
        } else {
            _conversionTimer = null;
        }
        return true;
    }

    function isSupportedRecoveryState(state as String) as Boolean {
        return state.equals(RUGBY_STATE_NOT_STARTED)
            || state.equals(RUGBY_STATE_RUNNING)
            || state.equals(RUGBY_STATE_PAUSED)
            || state.equals(RUGBY_STATE_HALF_ENDED)
            || state.equals(RUGBY_STATE_MATCH_ENDED);
    }

    function markLatestEventCorrected(teamId as String, action as String) as Void {
        for (var i = _eventLog.size() - 1; i >= 0; i -= 1) {
            var event = _eventLog[i] as Dictionary;
            if (valueEquals(event["teamId"], teamId) && valueEquals(event["action"], action) && !valueEquals(event["status"], "corrected")) {
                event["status"] = "corrected";
                return;
            }
        }
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
