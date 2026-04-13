/*
 * File: RugbyMatchSummaryView.mc
 * Purpose: Simple match-end event log summary view.
 */

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class RugbyMatchSummaryView extends WatchUi.View {
    var _model as RugbyGameModel;

    function initialize(model as RugbyGameModel) {
        View.initialize();
        _model = model;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_SMALL, "MATCH EVENTS", Graphics.TEXT_JUSTIFY_CENTER);

        var events = _model.eventLog() as Array<Dictionary>;
        if (events.size() == 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_XTINY, "NO EVENTS", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var y = 34 as Number;
        var maxRows = 6 as Number;
        for (var i = 0; i < events.size() && i < maxRows; i += 1) {
            var event = events[i] as Dictionary;
            var text = formatEvent(event) as String;
            dc.setColor(teamColor(event["teamId"]), Graphics.COLOR_BLACK);
            dc.drawText(12, y, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);
            y += 22;
        }

        if (events.size() > maxRows) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() - 24, Graphics.FONT_XTINY, "+" + (events.size() - maxRows).format("%d") + " MORE", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function formatEvent(event as Dictionary) as String {
        return formatClock(event["matchElapsedSeconds"]) + " " + teamText(event["teamId"]) + " " + actionText(event["action"]);
    }

    function teamText(teamId) as String {
        return valueEquals(teamId, RUGBY_TEAM_HOME) ? "H" : "A";
    }

    function teamColor(teamId) as Number {
        return valueEquals(teamId, RUGBY_TEAM_HOME) ? Graphics.COLOR_BLUE : Graphics.COLOR_ORANGE;
    }

    function actionText(action) as String {
        if (valueEquals(action, RUGBY_SCORE_TRY)) {
            return "TRY";
        }
        if (valueEquals(action, RUGBY_EVENT_CONVERSION_MADE)) {
            return "CONV";
        }
        if (valueEquals(action, RUGBY_SCORE_PENALTY_GOAL)) {
            return "PEN";
        }
        if (valueEquals(action, RUGBY_SCORE_DROP_GOAL)) {
            return "DROP";
        }
        if (valueEquals(action, "yellowCard")) {
            return "YELLOW";
        }
        if (valueEquals(action, "redCard")) {
            return "RED";
        }
        return "" + action;
    }

    function formatClock(totalSeconds) as String {
        if (totalSeconds == null) {
            return "--:--";
        }
        var seconds = totalSeconds as Number;
        if (seconds < 0) {
            seconds = 0;
        }
        var minutes = (seconds / 60) as Number;
        var remainder = (seconds % 60) as Number;
        var text = minutes.format("%d") + ":";
        if (remainder < 10) {
            text += "0";
        }
        return text + remainder.format("%d");
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }
}
