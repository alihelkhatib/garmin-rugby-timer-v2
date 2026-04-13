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
import Toybox.System;
import Toybox.WatchUi;

const RUGBY_COLOR_DIM = 0x9A9A9A;

class RugbyTimerView extends WatchUi.View {
    var _model;
    var _haptics;
    var _layoutReady;
    var _drawableCache;
/* Prepare view state and create a RugbyHaptics helper instance. */

    function initialize(model) {
        View.initialize();
        _model = model;
        _haptics = new RugbyHaptics();
        _layoutReady = false;
        _drawableCache = {};
    }
/* Apply layout and cache drawable references for fast drawing. */

    function onLayout(dc) {
        RugbyLayoutSupport.applyLayout(self, dc, dc.getWidth(), dc.getHeight());
        cacheDrawables();
        _layoutReady = true;
    }
/* Ensure layout is ready, get a model snapshot, handle haptics and bind UI. */

    function onUpdate(dc) {
        if (!_layoutReady) {
            onLayout(dc);
        }

        var snap = _model.snapshot(System.getTimer());
        handleHaptics(snap);
        bindLayout(snap);
        View.onUpdate(dc);
    }
/* Locate drawables by id; tolerate missing drawables on some device profiles. */

    function cacheDrawables() {
        _drawableCache = {};
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
        ];
        for (var i = 0; i < ids.size(); i += 1) {
            var id = ids[i];
            var drawable = null;
            try {
                drawable = findDrawableById(id);
            } catch (ex) {
                drawable = null;
            }
            _drawableCache[id] = drawable;
        }
    }
/* Map snapshot fields into drawable text/colors/visibility. */

    function bindLayout(snap) {
        var home = snap["home"];
        var away = snap["away"];
        setTextDrawable("ElapsedTimer", formatClock(snap["countUpSeconds"]), true, Graphics.COLOR_LT_GRAY);
        setTextDrawable("HomeLabel", "HOME", true, Graphics.COLOR_BLUE);
        setTextDrawable("AwayLabel", "AWAY", true, Graphics.COLOR_ORANGE);
        setTextDrawable("HomeScore", valueText(home["score"]), true, Graphics.COLOR_WHITE);
        setTextDrawable("AwayScore", valueText(away["score"]), true, Graphics.COLOR_WHITE);
        setTextDrawable("HalfText", "Half " + valueText(snap["halfIndex"]), true, Graphics.COLOR_WHITE);
        setTextDrawable("HomeTries", valueText(home["tryCount"]) + "T", true, Graphics.COLOR_WHITE);
        setTextDrawable("AwayTries", valueText(away["tryCount"]) + "T", true, Graphics.COLOR_WHITE);
        bindTeamCard("HomeCardValue", snap["sanctions"], RUGBY_TEAM_HOME);
        bindTeamCard("AwayCardValue", snap["sanctions"], RUGBY_TEAM_AWAY);
        bindConversion(snap["conversionTimer"]);
        setTextDrawable("Countdown", formatClock(snap["mainCountdownSeconds"]), true, Graphics.COLOR_WHITE);
        setStatus(snap);
    }

    function bindTeamCard(id, sanctions, teamId) {
        for (var i = 0; i < sanctions.size(); i += 1) {
            var sanction = sanctions[i];
            if (sanction["teamId"] == teamId) {
                var color = sanction["cardType"] == RUGBY_CARD_RED ? Graphics.COLOR_RED : Graphics.COLOR_YELLOW;
                setTextDrawable(id, sanctionLabel(sanction), true, color);
                return;
            }
        }
        setTextDrawable(id, "", false, Graphics.COLOR_WHITE);
    }

    function bindConversion(conversion) {
        if (conversion == null || !conversion["active"]) {
            return;
        }
        var id = conversion["teamId"] == RUGBY_TEAM_HOME ? "HomeCardValue" : "AwayCardValue";
        setTextDrawable(id, "CONV " + formatClock(conversion["remainingSeconds"]), true, Graphics.COLOR_WHITE);
    }

    function setStatus(snap) {
        if (snap["pendingConfirmAction"] != null) {
            setTextDrawable("StatusMessage", "CONFIRM", true, Graphics.COLOR_YELLOW);
        } else if (snap["clockState"] == RUGBY_STATE_PAUSED) {
            setTextDrawable("StatusMessage", "PAUSED", true, Graphics.COLOR_YELLOW);
        } else if (snap["clockState"] != RUGBY_STATE_RUNNING) {
            setTextDrawable("StatusMessage", snap["clockState"], true, RUGBY_COLOR_DIM);
        } else {
            setTextDrawable("StatusMessage", "", false, Graphics.COLOR_WHITE);
        }
    }

    function setTextDrawable(id, text, visible, color) {
        var drawable = _drawableCache[id];
        if (drawable == null) {
            return;
        }
        try {
            drawable.setText(text);
        } catch (ex) {
        }
        try {
            drawable.setColor(color);
        } catch (ex2) {
        }
        try {
            drawable.setVisible(visible == true);
        } catch (ex3) {
        }
    }
/* Fire coalesced haptics for events and notify model they were fired. */

    function handleHaptics(snap) {
        var events = snap["hapticEvents"];
        if (events != null && events.size() > 0) {
            _haptics.fireCoalesced(snap["snapshotId"]);
            _model.markHapticEventsFired(events);
        }
    }

    function sanctionLabel(sanction) {
        if (sanction["cardType"] == RUGBY_CARD_RED) {
            return "RED";
        }
        return "Y " + formatClock(sanction["remainingSeconds"]);
    }

    function valueText(value) {
        if (value == null) {
            return "0";
        }
        return value.format("%d");
    }
/* Format a seconds value into MM:SS text, clamp negative values to 0. */

    function formatClock(totalSeconds) {
        if (totalSeconds == null) {
            return "--:--";
        }
        var seconds = totalSeconds;
        if (seconds < 0) {
            seconds = 0;
        }
        var minutes = seconds / 60;
        var remainder = seconds % 60;
        var text = minutes.format("%d") + ":";
        if (remainder < 10) {
            text = text + "0";
        }
        return text + remainder.format("%d");
    }
}
