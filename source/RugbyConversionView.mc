/*
 * File: RugbyConversionView.mc
 * Purpose: UI for conversion attempts after a try (shows team, countdown and controls for made/miss).
 * Public API: RugbyConversionView (View) and RugbyConversionDelegate (BehaviorDelegate)
 * Key state: _model, _teamId, _layoutReady, _drawables
 * Interactions: Rez.Layouts.ConversionLayout, RugbyGameModel, WatchUi navigation
 * Example usage: WatchUi.pushView(new RugbyConversionView(model, teamId), new RugbyConversionDelegate(model, teamId), ...)
 * TODOs/notes: Graceful handling if layout drawables are missing on some watch profiles
 */

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class RugbyConversionView extends WatchUi.View {
    var _model as RugbyGameModel;
    var _teamId as String;
    var _layoutReady as Boolean;
    var _drawables as Dictionary;
    var _refreshTimer as Timer.Timer?;
    var _refreshActive as Boolean;

    function initialize(model as RugbyGameModel, teamId as String) {
        View.initialize();
        _model = model;
        _teamId = teamId;
        _layoutReady = false;
        _drawables = {} as Dictionary;
        _refreshTimer = null;
        _refreshActive = false;
    }
/* Bind conversion layout and cache drawables. */

    function onLayout(dc as Graphics.Dc) as Void {
        setLayout(Rez.Layouts.ConversionLayout(dc));
        cacheDrawables();
        _layoutReady = true;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        if (!_layoutReady) {
            onLayout(dc);
        }
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        updateRefreshTimer(snap);
        bindLayout(snap);
        View.onUpdate(dc);
    }

    function updateRefreshTimer(snap as Dictionary) as Void {
        var conversion = snap["conversionTimer"] as Dictionary?;
        var shouldRun = conversion != null && conversion["active"];
        if (shouldRun && !_refreshActive) {
            if (_refreshTimer == null) {
                _refreshTimer = new Timer.Timer();
            }
            System.println("RUGBY|RugbyConversionView|updateRefreshTimer start snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")));
            _refreshTimer.start(method(:onRefreshTimer), 1000, true);
            _refreshActive = true;
        } else if (!shouldRun && _refreshActive) {
            System.println("RUGBY|RugbyConversionView|updateRefreshTimer stop snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")));
            _refreshTimer.stop();
            _refreshActive = false;
        }
    }

    function onRefreshTimer() as Void {
        System.println("RUGBY|RugbyConversionView|onRefreshTimer requestUpdate");
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
        }
        _refreshActive = false;
        System.println("RUGBY|RugbyConversionView|onHide stopRefreshTimer");
    }
/* Attempt to resolve expected drawables and tolerate missing ones. */

    function cacheDrawables() as Void {
        _drawables = {} as Dictionary;
        var ids = ["MatchCountdown", "ConversionTitle", "ConversionTeam", "ConversionTimer", "ConversionMadeHint", "ConversionMissHint"] as Array<String>;
        for (var i = 0; i < ids.size(); i += 1) {
            var id = ids[i] as String;
            var drawable = null;
            try {
                drawable = findDrawableById(id);
            } catch (ex) {
                drawable = null;
            }
            _drawables[id] = drawable;
        }
    }
/* Set texts/colors based on conversion state and remaining seconds. */

    function bindLayout(snap as Dictionary) as Void {
        var conversion = snap["conversionTimer"] as Dictionary?;
        var remaining = (conversion == null ? 0 : conversion["remainingSeconds"]) as Number;
        setText("MatchCountdown", formatClock(snap["mainCountdownSeconds"]), Graphics.COLOR_LT_GRAY);
        setText("ConversionTitle", "CONVERSION", Graphics.COLOR_YELLOW);
        var isHome = valueEquals(_teamId, RUGBY_TEAM_HOME) as Boolean;
        System.println("RUGBY|RugbyConversionView|bindLayout teamId=" + (_teamId == null ? "null" : _teamId) + " isHome=" + (isHome ? "true" : "false") + " remainingSeconds=" + remaining.format("%d"));
        setText("ConversionTeam", isHome ? "HOME TRY" : "AWAY TRY", isHome ? Graphics.COLOR_BLUE : Graphics.COLOR_ORANGE);
        setText("ConversionTimer", formatClock(remaining), Graphics.COLOR_WHITE);
        setText("ConversionMadeHint", "UP/MENU +2", Graphics.COLOR_WHITE);
        setText("ConversionMissHint", "DOWN MISS", Graphics.COLOR_LT_GRAY);
    }

    function setText(id as String, text as String, color as Number) as Void {
        var drawable = _drawables[id];
        if (drawable == null) {
            System.println("RUGBY|RugbyConversionView|setText missing id=" + id + " text=" + text);
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
            drawable.setVisible(true);
        } catch (ex3) {
        }
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }

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

class RugbyConversionDelegate extends WatchUi.BehaviorDelegate {
    var _model as RugbyGameModel;
    var _teamId as String;

    function initialize(model as RugbyGameModel, teamId as String) {
        BehaviorDelegate.initialize();
        _model = model;
        _teamId = teamId;
    }

    function onMenu() as Boolean {
        return conversionMade();
    }

    function onPreviousPage() as Boolean {
        return conversionMade();
    }

    function onNextPage() as Boolean {
        _model.missConversion();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Boolean {
        _model.missConversion();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
        return true;
    }
/* Delegate action for marking a conversion as made, closes view and updates UI. */

    function conversionMade() as Boolean {
        _model.recordConversionAt(_teamId, System.getTimer());
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
        return true;
    }
}
