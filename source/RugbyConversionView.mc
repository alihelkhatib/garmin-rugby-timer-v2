import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;

class RugbyConversionView extends WatchUi.View {
    var _model;
    var _teamId;
    var _layoutReady;
    var _drawables;

    function initialize(model, teamId) {
        View.initialize();
        _model = model;
        _teamId = teamId;
        _layoutReady = false;
        _drawables = {};
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.ConversionLayout(dc));
        cacheDrawables();
        _layoutReady = true;
    }

    function onUpdate(dc) {
        if (!_layoutReady) {
            onLayout(dc);
        }
        bindLayout(_model.snapshot(System.getTimer()));
        View.onUpdate(dc);
    }

    function cacheDrawables() {
        _drawables = {};
        var ids = ["ConversionTitle", "ConversionTeam", "ConversionTimer", "ConversionMadeHint", "ConversionMissHint"];
        for (var i = 0; i < ids.size(); i += 1) {
            var id = ids[i];
            var drawable = null;
            try {
                drawable = findDrawableById(id);
            } catch (ex) {
                drawable = null;
            }
            _drawables[id] = drawable;
        }
    }

    function bindLayout(snap) {
        var conversion = snap["conversionTimer"];
        var remaining = conversion == null ? 0 : conversion["remainingSeconds"];
        setText("ConversionTitle", "CONVERSION", Graphics.COLOR_YELLOW);
        setText("ConversionTeam", _teamId == RUGBY_TEAM_HOME ? "HOME TRY" : "AWAY TRY", _teamId == RUGBY_TEAM_HOME ? Graphics.COLOR_BLUE : Graphics.COLOR_ORANGE);
        setText("ConversionTimer", formatClock(remaining), Graphics.COLOR_WHITE);
        setText("ConversionMadeHint", "UP/MENU +2", Graphics.COLOR_WHITE);
        setText("ConversionMissHint", "DOWN MISS", Graphics.COLOR_LT_GRAY);
    }

    function setText(id, text, color) {
        var drawable = _drawables[id];
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
            drawable.setVisible(true);
        } catch (ex3) {
        }
    }

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

class RugbyConversionDelegate extends WatchUi.BehaviorDelegate {
    var _model;
    var _teamId;

    function initialize(model, teamId) {
        BehaviorDelegate.initialize();
        _model = model;
        _teamId = teamId;
    }

    function onMenu() {
        return conversionMade();
    }

    function onPreviousPage() {
        return conversionMade();
    }

    function onNextPage() {
        _model.missConversion();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() {
        _model.missConversion();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
        return true;
    }

    function conversionMade() {
        _model.recordConversion(_teamId);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
        return true;
    }
}