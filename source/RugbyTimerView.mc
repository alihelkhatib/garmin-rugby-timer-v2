/*
 * File: RugbyTimerView.mc
 * Purpose: Render the main timer UI by binding a RugbyGameModel snapshot into layout drawables.
 * Public API: RugbyTimerView(View) class; onLayout, onUpdate managed by WatchUi
 * Key state: _model, _haptics, _layoutReady, _drawableCache
 * Interactions: RugbyLayoutSupport, RugbyHaptics, Rez.Layouts, RugbyGameModel
 * Example usage: new RugbyTimerView(model) shown by RugbyTimerApp.getInitialView()
 * TODOs/notes: Keep drawing code minimal; consider moving formatting helpers to shared util
 */

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

const RUGBY_COLOR_DIM = 0x9A9A9A;

class RugbyTimerView extends WatchUi.View {
    var _model as RugbyGameModel;
    var _haptics as RugbyHaptics;
    var _layoutReady as Boolean;
    var _drawableCache as Dictionary;
    var _refreshTimer as Timer.Timer?;
    var _refreshActive as Boolean;
    var _pauseReminderTimer as Timer.Timer?;
    var _pauseReminderActive as Boolean;
    var _recorder;
    var _autoMatchSummaryShown as Boolean;
/* Prepare view state and create a RugbyHaptics helper instance. */

    function initialize(model as RugbyGameModel) {
        View.initialize();
        _model = model;
        _haptics = new RugbyHaptics();
        _layoutReady = false;
        _drawableCache = {} as Dictionary;
        _refreshTimer = null;
        _refreshActive = false;
        _pauseReminderTimer = null;
        _pauseReminderActive = false;
        _recorder = null;
        _autoMatchSummaryShown = false;
        System.println("RUGBY|RugbyTimerView|initialize modelPresent=" + (_model != null ? "yes" : "no"));
    }

    function setRecorder(recorder) as Void {
        _recorder = recorder;
    }
/* Apply layout and cache drawable references for fast drawing. */

    function onLayout(dc as Graphics.Dc) as Void {
        System.println("RUGBY|RugbyTimerView|onLayout width=" + dc.getWidth().format("%d") + " height=" + dc.getHeight().format("%d"));
        RugbyLayoutSupport.applyLayout(self, dc, dc.getWidth(), dc.getHeight());
        cacheDrawables();
        _layoutReady = true;
    }
/* Ensure layout is ready, get a model snapshot, handle haptics and bind UI. */

    function onUpdate(dc as Graphics.Dc) as Void {
        if (!_layoutReady) {
            onLayout(dc);
        }
        var now = System.getTimer() as Number;
        var snap = _model.snapshot(now) as Dictionary;
        System.println("RUGBY|RugbyTimerView|onUpdate nowMs=" + now.format("%d")
            + " snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d"))
            + " clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"])
            + " pending=" + (snap["pendingConfirmAction"] == null ? "null" : snap["pendingConfirmAction"]));
        updateRefreshTimer(snap);
        updatePauseReminderTimer(snap);
        handleAutoMatchEnd(snap);
        handleHaptics(snap);
        bindLayout(snap);
        View.onUpdate(dc);
        drawRedCardIndicators(dc, snap);
    }

    function handleAutoMatchEnd(snap as Dictionary) as Void {
        if (!valueEquals(snap["clockState"], RUGBY_STATE_MATCH_ENDED)) {
            _autoMatchSummaryShown = false;
            return;
        }
        if (_autoMatchSummaryShown || !snap["autoMatchEndPendingSave"]) {
            return;
        }
        if (!_model.consumeAutoMatchEndPendingSave()) {
            return;
        }
        if (_recorder != null) {
            if (_recorder has :stopAndSaveWithEvents) {
                _recorder.stopAndSaveWithEvents(_model.eventLog());
            } else if (_recorder has :stopAndSave) {
                _recorder.stopAndSave();
            }
        }
        _autoMatchSummaryShown = true;
        System.println("RUGBY|RugbyTimerView|handleAutoMatchEnd showSummary");
        WatchUi.pushView(new RugbyMatchSummaryView(_model), new RugbyMatchSummaryDelegate(), WatchUi.SLIDE_UP);
    }

    function updateRefreshTimer(snap as Dictionary) as Void {
        var shouldRun = (valueEquals(snap["clockState"], RUGBY_STATE_RUNNING) || valueEquals(snap["clockState"], RUGBY_STATE_HALF_ENDED)) as Boolean;
        if (shouldRun && !_refreshActive) {
            if (_refreshTimer == null) {
                _refreshTimer = new Timer.Timer();
            }
            System.println("RUGBY|RugbyTimerView|updateRefreshTimer start snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")));
            _refreshTimer.start(method(:onRefreshTimer), 1000, true);
            _refreshActive = true;
        } else if (!shouldRun && _refreshActive) {
            System.println("RUGBY|RugbyTimerView|updateRefreshTimer stop snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")) + " clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
            _refreshTimer.stop();
            _refreshActive = false;
        } else {
            System.println("RUGBY|RugbyTimerView|updateRefreshTimer unchanged active=" + (_refreshActive ? "true" : "false") + " shouldRun=" + (shouldRun ? "true" : "false"));
        }
    }

    function onRefreshTimer() as Void {
        System.println("RUGBY|RugbyTimerView|onRefreshTimer requestUpdate");
        WatchUi.requestUpdate();
    }

    function updatePauseReminderTimer(snap as Dictionary) as Void {
        var shouldRun = valueEquals(snap["clockState"], RUGBY_STATE_PAUSED) as Boolean;
        if (shouldRun && !_pauseReminderActive) {
            if (_pauseReminderTimer == null) {
                _pauseReminderTimer = new Timer.Timer();
            }
            var interval = snap["pauseReminderIntervalMs"] == null ? RUGBY_PAUSE_REMINDER_INTERVAL_MS : snap["pauseReminderIntervalMs"];
            System.println("RUGBY|RugbyTimerView|updatePauseReminderTimer start snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")) + " intervalMs=" + interval.format("%d"));
            _pauseReminderTimer.start(method(:onPauseReminderTimer), interval, true);
            _pauseReminderActive = true;
        } else if (!shouldRun && _pauseReminderActive) {
            System.println("RUGBY|RugbyTimerView|updatePauseReminderTimer stop snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")) + " clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
            _pauseReminderTimer.stop();
            _pauseReminderActive = false;
        } else {
            System.println("RUGBY|RugbyTimerView|updatePauseReminderTimer unchanged active=" + (_pauseReminderActive ? "true" : "false") + " shouldRun=" + (shouldRun ? "true" : "false"));
        }
    }

    function onPauseReminderTimer() as Void {
        var now = System.getTimer() as Number;
        var snap = _model.snapshot(now) as Dictionary;
        if (valueEquals(snap["clockState"], RUGBY_STATE_PAUSED)) {
            var haptic = _haptics.firePauseReminder() as Boolean;
            System.println("RUGBY|RugbyTimerView|onPauseReminderTimer fired nowMs=" + now.format("%d") + " haptic=" + (haptic ? "true" : "false"));
        } else {
            System.println("RUGBY|RugbyTimerView|onPauseReminderTimer stopping clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
            if (_pauseReminderTimer != null) {
                _pauseReminderTimer.stop();
            }
            _pauseReminderActive = false;
        }
        WatchUi.requestUpdate();
    }
/* Locate drawables by id; tolerate missing drawables on some device profiles. */

    function cacheDrawables() as Void {
        _drawableCache = {} as Dictionary;
        var ids = [
            "ElapsedTimer",
            "HomeLabel",
            "AwayLabel",
            "HomeScore",
            "AwayScore",
            "HalfText",
            "HomeTries",
            "AwayTries",
            "HomeCardValue",
            "AwayCardValue",
            "Countdown",
            "StatusMessage"
        ] as Array<String>;
        for (var i = 0; i < ids.size(); i += 1) {
            var id = ids[i] as String;
            var drawable = null;
            try {
                drawable = findDrawableById(id);
            } catch (ex) {
                System.println("RUGBY|RugbyTimerView|cacheDrawables missing id=" + id + " ex=" + ex.toString());
                drawable = null;
            }
            _drawableCache[id] = drawable;
        }
    }
/* Map snapshot fields into drawable text/colors/visibility. */

    function bindLayout(snap as Dictionary) as Void {
        var home = snap["home"] as Dictionary;
        var away = snap["away"] as Dictionary;
        bindElapsedTimer(snap);
        setTextDrawable("HomeLabel", "HOME", true, Graphics.COLOR_BLUE);
        setTextDrawable("AwayLabel", "AWAY", true, Graphics.COLOR_ORANGE);
        setTextDrawable("HomeScore", valueText(home["score"]), true, Graphics.COLOR_WHITE);
        setTextDrawable("AwayScore", valueText(away["score"]), true, Graphics.COLOR_WHITE);
        setTextDrawable("HalfText", "Half " + valueText(snap["halfIndex"]), true, Graphics.COLOR_WHITE);
        setTextDrawable("HomeTries", valueText(home["tryCount"]) + "T", true, Graphics.COLOR_WHITE);
        setTextDrawable("AwayTries", valueText(away["tryCount"]) + "T", true, Graphics.COLOR_WHITE);
        bindTeamCard("HomeCardValue", snap["sanctions"] as Array<Dictionary>, RUGBY_TEAM_HOME);
        bindTeamCard("AwayCardValue", snap["sanctions"] as Array<Dictionary>, RUGBY_TEAM_AWAY);
        bindConversion(snap["conversionTimer"] as Dictionary?);
        setTextDrawable("Countdown", formatClock(snap["mainCountdownSeconds"]), true, Graphics.COLOR_WHITE);
        setStatus(snap);
    }

    function bindElapsedTimer(snap as Dictionary) as Void {
        setTextDrawable("ElapsedTimer", elapsedTimerLabel(snap), true, Graphics.COLOR_LT_GRAY);
    }

    function elapsedTimerLabel(snap as Dictionary) as String {
        if (valueEquals(snap["clockState"], RUGBY_STATE_HALF_ENDED)) {
            return "HT " + formatClock(snap["halfTimeSeconds"]);
        }
        return formatClock(snap["countUpSeconds"]);
    }

    function bindTeamCard(id as String, sanctions as Array<Dictionary>, teamId as String) as Void {
        var label = teamYellowCardTimerLabel(sanctions, teamId) as String;
        if (!label.equals("")) {
            System.println("RUGBY|RugbyTimerView|bindTeamCard id=" + id + " teamId=" + teamId + " yellowTimers=" + label + " redPresent=" + (teamHasRedCard(sanctions, teamId) ? "true" : "false"));
            setTextDrawable(id, label, true, Graphics.COLOR_YELLOW);
            return;
        }
        setTextDrawable(id, "", false, Graphics.COLOR_WHITE);
    }

    function teamYellowCardTimerLabel(sanctions as Array<Dictionary>, teamId as String) as String {
        var label = "" as String;
        for (var i = 0; i < sanctions.size(); i += 1) {
            var sanction = sanctions[i] as Dictionary;
            if (valueEquals(sanction["teamId"], teamId) && valueEquals(sanction["cardType"], RUGBY_CARD_YELLOW) && isVisibleYellowCardTimerState(sanction["state"])) {
                if (!label.equals("")) {
                    label += " ";
                }
                label += formatClock(sanction["remainingSeconds"]);
            }
        }
        return label;
    }

    function isVisibleYellowCardTimerState(state) as Boolean {
        return valueEquals(state, "active") || valueEquals(state, "pausedForPeriod");
    }

    function teamHasRedCard(sanctions as Array<Dictionary>, teamId as String) as Boolean {
        for (var i = 0; i < sanctions.size(); i += 1) {
            var sanction = sanctions[i] as Dictionary;
            if (valueEquals(sanction["teamId"], teamId) && valueEquals(sanction["cardType"], RUGBY_CARD_RED) && !valueEquals(sanction["state"], "cleared")) {
                return true;
            }
        }
        return false;
    }

    function drawRedCardIndicators(dc as Graphics.Dc, snap as Dictionary) as Void {
        var sanctions = snap["sanctions"] as Array<Dictionary>;
        var size = (dc.getWidth() / 36) as Number;
        if (size < 5) {
            size = 5;
        }
        if (teamHasRedCard(sanctions, RUGBY_TEAM_HOME)) {
            drawRedCardIndicator(dc, (dc.getWidth() * 35 / 100) as Number, (dc.getHeight() * 16 / 100) as Number, size);
        }
        if (teamHasRedCard(sanctions, RUGBY_TEAM_AWAY)) {
            drawRedCardIndicator(dc, (dc.getWidth() * 62 / 100) as Number, (dc.getHeight() * 16 / 100) as Number, size);
        }
    }

    function drawRedCardIndicator(dc as Graphics.Dc, x as Number, y as Number, size as Number) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.fillRectangle(x, y, size, size);
    }

    function bindConversion(conversion as Dictionary?) as Void {
        if (conversion == null || !conversion["active"]) {
            return;
        }
        var id = (valueEquals(conversion["teamId"], RUGBY_TEAM_HOME) ? "HomeCardValue" : "AwayCardValue") as String;
        setTextDrawable(id, "CONV " + formatClock(conversion["remainingSeconds"]), true, Graphics.COLOR_WHITE);
    }

    function setStatus(snap as Dictionary) as Void {
        if (snap["pendingConfirmAction"] != null) {
            setTextDrawable("StatusMessage", "CONFIRM", true, Graphics.COLOR_YELLOW);
        } else if (valueEquals(snap["clockState"], RUGBY_STATE_PAUSED)) {
            setTextDrawable("StatusMessage", "PAUSED", true, Graphics.COLOR_YELLOW);
        } else if (valueEquals(snap["clockState"], RUGBY_STATE_HALF_ENDED)) {
            setTextDrawable("StatusMessage", "NEXT HALF", true, RUGBY_COLOR_DIM);
        } else if (valueEquals(snap["clockState"], RUGBY_STATE_MATCH_ENDED)) {
            setTextDrawable("StatusMessage", "MATCH END", true, RUGBY_COLOR_DIM);
        } else if (valueEquals(snap["clockState"], RUGBY_STATE_NOT_STARTED)) {
            setTextDrawable("StatusMessage", "" + snap["variantName"], true, RUGBY_COLOR_DIM);
        } else {
            setTextDrawable("StatusMessage", "", false, Graphics.COLOR_WHITE);
        }
    }

    function setTextDrawable(id as String, text as String, visible as Boolean, color as Number) as Void {
        var drawable = _drawableCache[id];
        if (drawable == null) {
            return;
        }
        try {
            drawable.setText(text);
        } catch (ex) {
            System.println("RUGBY|RugbyTimerView|setTextDrawable id=" + id + " op=setText ex=" + ex.toString());
        }
        try {
            drawable.setColor(color);
        } catch (ex2) {
            System.println("RUGBY|RugbyTimerView|setTextDrawable id=" + id + " op=setColor ex=" + ex2.toString());
        }
        try {
            drawable.setVisible(visible == true);
        } catch (ex3) {
            System.println("RUGBY|RugbyTimerView|setTextDrawable id=" + id + " op=setVisible ex=" + ex3.toString());
        }
    }
/* Fire coalesced haptics for events and notify model they were fired. */

    function handleHaptics(snap as Dictionary) as Void {
        var events = snap["hapticEvents"] as Array<Dictionary>?;
        if (events != null && events.size() > 0) {
            _haptics.fireCoalescedForEvents(snap["snapshotId"], events);
            _model.markHapticEventsFired(events);
        }
    }

    function sanctionLabel(sanction as Dictionary) as String {
        if (valueEquals(sanction["cardType"], RUGBY_CARD_RED)) {
            return "RED";
        }
        return formatClock(sanction["remainingSeconds"]);
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }

    function valueText(value as Number?) as String {
        if (value == null) {
            return "0";
        }
        return value.format("%d");
    }
/* Format a seconds value into MM:SS text, clamp negative values to 0. */

    function formatClock(totalSeconds as Number?) as String {
        if (totalSeconds == null) {
            return "--:--";
        }
        var seconds = totalSeconds as Number;
        if (seconds < 0) {
            seconds = 0;
        }
        var minutes = (seconds / 60) as Number;
        var remainder = (seconds % 60) as Number;
        var text = (minutes.format("%d") + ":") as String;
        if (remainder < 10) {
            text = text + "0";
        }
        return text + remainder.format("%d");
    }
}
