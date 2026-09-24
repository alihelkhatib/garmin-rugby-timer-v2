/*
 * File: RugbyTimerView.mc
 * Purpose: Render the main timer UI by binding a RugbyGameModel snapshot into layout drawables.
 * Public API: RugbyTimerView(View) class; onLayout, onUpdate managed by WatchUi
 * Key state: _model, _haptics, _layoutReady, _drawableCache
 * Interactions: RugbyLayoutSupport, RugbyHaptics, Rez.Layouts, RugbyGameModel
 * Example usage: new RugbyTimerView(model) shown by RugbyTimerApp.getInitialView()
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
    var _controller as RugbyMatchController?;
    var _isInstinctLayout as Boolean;
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
        _controller = null;
        _isInstinctLayout = false;
    }

    function setRecorder(recorder) as Void {
        _recorder = recorder;
    }

    function setController(controller as RugbyMatchController) as Void {
        _controller = controller;
    }
/* Apply layout and cache drawable references for fast drawing. */

    function onLayout(dc as Graphics.Dc) as Void {
        var layoutId = RugbyLayoutSupport.applyLayout(self, dc, dc.getWidth(), dc.getHeight());
        _isInstinctLayout = layoutId.equals("MainLayoutInstinct");
        cacheDrawables();
        _layoutReady = true;
    }
/* Ensure layout is ready, get a model snapshot, handle haptics and bind UI. */

    function onUpdate(dc as Graphics.Dc) as Void {
        if (!_layoutReady) {
            onLayout(dc);
        }
        var now = System.getTimer() as Number;
        var snap;
        if (_controller != null) {
            snap = _controller.tick(now);
        } else {
            _model.advance(now);
            snap = _model.snapshot(now);
        }
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
        if (_autoMatchSummaryShown) {
            return;
        }
        if (_controller != null) {
            if (!_controller.consumeSummaryRequest()) {
                return;
            }
        } else if (!_model.consumeAutoMatchEndPendingSave()) {
            return;
        }
        _autoMatchSummaryShown = true;
        WatchUi.pushView(new RugbyMatchSummaryView(_model), new RugbyMatchSummaryDelegate(), WatchUi.SLIDE_UP);
    }

    function updateRefreshTimer(snap as Dictionary) as Void {
        var shouldRun = (valueEquals(snap["clockState"], RUGBY_STATE_RUNNING) || valueEquals(snap["clockState"], RUGBY_STATE_HALF_ENDED)) as Boolean;
        if (shouldRun && !_refreshActive) {
            if (_refreshTimer == null) {
                _refreshTimer = new Timer.Timer();
            }
            _refreshTimer.start(method(:onRefreshTimer), 1000, true);
            _refreshActive = true;
        } else if (!shouldRun && _refreshActive) {
            _refreshTimer.stop();
            _refreshActive = false;
        } else {
        }
    }

    function onRefreshTimer() as Void {
        WatchUi.requestUpdate();
    }

    function updatePauseReminderTimer(snap as Dictionary) as Void {
        var shouldRun = valueEquals(snap["clockState"], RUGBY_STATE_PAUSED) as Boolean;
        if (shouldRun && !_pauseReminderActive) {
            if (_pauseReminderTimer == null) {
                _pauseReminderTimer = new Timer.Timer();
            }
            var interval = snap["pauseReminderIntervalMs"] == null ? RUGBY_PAUSE_REMINDER_INTERVAL_MS : snap["pauseReminderIntervalMs"];
            _pauseReminderTimer.start(method(:onPauseReminderTimer), interval, true);
            _pauseReminderActive = true;
        } else if (!shouldRun && _pauseReminderActive) {
            _pauseReminderTimer.stop();
            _pauseReminderActive = false;
        } else {
        }
    }

    function onPauseReminderTimer() as Void {
        var now = System.getTimer() as Number;
        var snap = _model.snapshot(now) as Dictionary;
        if (valueEquals(snap["clockState"], RUGBY_STATE_PAUSED)) {
            _haptics.firePauseReminder();
        } else {
            if (_pauseReminderTimer != null) {
                _pauseReminderTimer.stop();
            }
            _pauseReminderActive = false;
        }
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
        }
        if (_pauseReminderTimer != null) {
            _pauseReminderTimer.stop();
        }
        _refreshActive = false;
        _pauseReminderActive = false;
    }
/* Cache the text drawables required by every validated layout. */

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
            _drawableCache[id] = findDrawableById(id);
        }
    }
/* Map snapshot fields into drawable text/colors/visibility. */

    function bindLayout(snap as Dictionary) as Void {
        var home = snap["home"] as Dictionary;
        var away = snap["away"] as Dictionary;
        bindElapsedTimer(snap);
        setTextDrawable("HomeLabel", WatchUi.loadResource(Rez.Strings.Team_Home_Short), true, _isInstinctLayout ? Graphics.COLOR_WHITE : Graphics.COLOR_BLUE);
        setTextDrawable("AwayLabel", WatchUi.loadResource(Rez.Strings.Team_Away_Short), true, _isInstinctLayout ? Graphics.COLOR_WHITE : Graphics.COLOR_ORANGE);
        setTextDrawable("HomeScore", valueText(home["score"]), true, Graphics.COLOR_WHITE);
        setTextDrawable("AwayScore", valueText(away["score"]), true, Graphics.COLOR_WHITE);
        setTextDrawable("HalfText", WatchUi.loadResource(Rez.Strings.HalfPrefix) + valueText(snap["halfIndex"]), true, Graphics.COLOR_WHITE);
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
            setTextDrawable(id, label, true, _isInstinctLayout ? Graphics.COLOR_WHITE : Graphics.COLOR_YELLOW);
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
        if (_isInstinctLayout) {
            if (teamHasRedCard(sanctions, RUGBY_TEAM_HOME)) {
                drawRedCardIndicator(dc, (dc.getWidth() * 82 / 100) as Number, (dc.getHeight() * 30 / 100) as Number, size);
            }
            if (teamHasRedCard(sanctions, RUGBY_TEAM_AWAY)) {
                drawRedCardIndicator(dc, (dc.getWidth() * 82 / 100) as Number, (dc.getHeight() * 45 / 100) as Number, size);
            }
            return;
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
            var pending = snap["pendingConfirmAction"];
            var confirmText = WatchUi.loadResource(Rez.Strings.Confirm_EndHalf) as String;
            if (valueEquals(pending, "endMatchSave")) {
                confirmText = WatchUi.loadResource(Rez.Strings.Confirm_EndMatch);
            } else if (valueEquals(pending, "endMatchExit")) {
                confirmText = WatchUi.loadResource(Rez.Strings.Confirm_EndMatchExit);
            } else if (valueEquals(pending, "resetMatch")) {
                confirmText = WatchUi.loadResource(Rez.Strings.Confirm_Reset);
            }
            setTextDrawable("StatusMessage", confirmText, true, Graphics.COLOR_YELLOW);
        } else if (valueEquals(snap["clockState"], RUGBY_STATE_PAUSED)) {
            setTextDrawable("StatusMessage", WatchUi.loadResource(Rez.Strings.State_Paused), true, Graphics.COLOR_YELLOW);
        } else if (valueEquals(snap["clockState"], RUGBY_STATE_HALF_ENDED)) {
            setTextDrawable("StatusMessage", WatchUi.loadResource(Rez.Strings.State_NextHalf), true, RUGBY_COLOR_DIM);
        } else if (valueEquals(snap["clockState"], RUGBY_STATE_MATCH_ENDED)) {
            setTextDrawable("StatusMessage", WatchUi.loadResource(Rez.Strings.State_GameEnded), true, RUGBY_COLOR_DIM);
        } else if (valueEquals(snap["clockState"], RUGBY_STATE_NOT_STARTED)) {
            setTextDrawable("StatusMessage", "" + snap["variantName"], true, RUGBY_COLOR_DIM);
        } else {
            setTextDrawable("StatusMessage", "", false, Graphics.COLOR_WHITE);
        }
    }

    function setTextDrawable(id as String, text as String, visible as Boolean, color as Number) as Void {
        var drawable = _drawableCache[id] as WatchUi.Text?;
        if (drawable == null) {
            return;
        }
        drawable.setText(text);
        drawable.setColor(color);
        drawable.setVisible(visible == true);
    }
/* Fire coalesced haptics for events and notify model they were fired. */

    function handleHaptics(snap as Dictionary) as Void {
        var events = snap["hapticEvents"] as Array<Dictionary>?;
        if (events != null && events.size() > 0) {
            _haptics.fireCoalesced(snap["snapshotId"]);
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
        return RugbyTime.formatClock(totalSeconds);
    }
}
