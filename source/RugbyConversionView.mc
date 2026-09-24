/*
 * File: RugbyConversionView.mc
 * Purpose: UI for conversion attempts after a try (shows team, countdown and controls for made/miss).
 * Public API: RugbyConversionView (View) and RugbyConversionDelegate (BehaviorDelegate)
 * Key state: _model, _teamId, _layoutReady, _drawables
 * Interactions: Rez.Layouts.ConversionLayout, RugbyGameModel, WatchUi navigation
 * Example usage: WatchUi.pushView(new RugbyConversionView(model, teamId), new RugbyConversionDelegate(model, teamId), ...)
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
    var _controller as RugbyMatchController?;
    var _isInstinctLayout as Boolean;

    function initialize(model as RugbyGameModel, teamId as String, controller as RugbyMatchController?) {
        View.initialize();
        _model = model;
        _teamId = teamId;
        _layoutReady = false;
        _drawables = {} as Dictionary;
        _refreshTimer = null;
        _refreshActive = false;
        _controller = controller;
        _isInstinctLayout = false;
    }
/* Bind conversion layout and cache drawables. */

    function onLayout(dc as Graphics.Dc) as Void {
        if (dc.getWidth() == dc.getHeight() && dc.getWidth() <= 180) {
            setLayout(Rez.Layouts.ConversionLayoutInstinct(dc));
            _isInstinctLayout = true;
        } else {
            setLayout(Rez.Layouts.ConversionLayout(dc));
            _isInstinctLayout = false;
        }
        cacheDrawables();
        _layoutReady = true;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        if (!_layoutReady) {
            onLayout(dc);
        }
        var now = System.getTimer() as Number;
        var snap = _controller != null ? _controller.tick(now) : null;
        if (snap == null) {
            _model.advance(now);
            snap = _model.snapshot(now);
        }
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
            _refreshTimer.start(method(:onRefreshTimer), 1000, true);
            _refreshActive = true;
        } else if (!shouldRun && _refreshActive) {
            _refreshTimer.stop();
            _refreshActive = false;
        }
    }

    function onRefreshTimer() as Void {
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
        }
        _refreshActive = false;
    }
/* Cache the text drawables required by the conversion layout. */

    function cacheDrawables() as Void {
        _drawables = {} as Dictionary;
        var ids = ["ConversionTitle", "ConversionTeam", "ConversionTimer", "ConversionMadeHint", "ConversionMissHint"] as Array<String>;
        for (var i = 0; i < ids.size(); i += 1) {
            var id = ids[i] as String;
            _drawables[id] = findDrawableById(id);
        }
    }
/* Set texts/colors based on conversion state and remaining seconds. */

    function bindLayout(snap as Dictionary) as Void {
        var conversion = snap["conversionTimer"] as Dictionary?;
        var remaining = (conversion == null ? 0 : conversion["remainingSeconds"]) as Number;
        setText("ConversionTitle", WatchUi.loadResource(Rez.Strings.State_Conversion), Graphics.COLOR_YELLOW);
        var isHome = valueEquals(_teamId, RUGBY_TEAM_HOME) as Boolean;
        var teamColor = _isInstinctLayout ? Graphics.COLOR_WHITE : (isHome ? Graphics.COLOR_BLUE : Graphics.COLOR_ORANGE);
        setText("ConversionTeam", WatchUi.loadResource(isHome ? Rez.Strings.Conversion_HomeTry : Rez.Strings.Conversion_AwayTry), teamColor);
        setText("ConversionTimer", formatClock(remaining), Graphics.COLOR_WHITE);
        setText("ConversionMadeHint", WatchUi.loadResource(Rez.Strings.Conversion_MadeHint), Graphics.COLOR_WHITE);
        setText("ConversionMissHint", WatchUi.loadResource(Rez.Strings.Conversion_MissHint), Graphics.COLOR_LT_GRAY);
    }

    function setText(id as String, text as String, color as Number) as Void {
        var drawable = _drawables[id] as WatchUi.Text?;
        if (drawable == null) {
            return;
        }
        drawable.setText(text);
        drawable.setColor(color);
        drawable.setVisible(true);
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }

    function formatClock(totalSeconds as Number?) as String {
        return RugbyTime.formatClock(totalSeconds);
    }
}

class RugbyConversionDelegate extends WatchUi.BehaviorDelegate {
    var _model as RugbyGameModel;
    var _teamId as String;
    var _controller as RugbyMatchController?;

    function initialize(model as RugbyGameModel, teamId as String, controller as RugbyMatchController?) {
        BehaviorDelegate.initialize();
        _model = model;
        _teamId = teamId;
        _controller = controller;
    }

    function onMenu() as Boolean {
        return conversionMade();
    }

    function onPreviousPage() as Boolean {
        return conversionMade();
    }

    function onNextPage() as Boolean {
        _model.missConversion();
        persist(System.getTimer());
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Boolean {
        _model.missConversion();
        persist(System.getTimer());
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
        return true;
    }
/* Delegate action for marking a conversion as made, closes view and updates UI. */

    function conversionMade() as Boolean {
        var now = System.getTimer() as Number;
        _model.recordConversionAt(_teamId, now);
        persist(now);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
        return true;
    }

    function persist(nowMs as Number) as Void {
        if (_controller != null) {
            _controller.persist(nowMs);
        } else {
            RugbyPersistence.saveMatch(_model, nowMs);
        }
    }
}
