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
    var _topIndex as Number;

    function initialize(model as RugbyGameModel) {
        View.initialize();
        _model = model;
        _topIndex = 0;
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
        } else {
            var y = 34 as Number;
            var maxRows = visibleRows(dc) as Number;
            clampTopIndex(events.size(), maxRows);
            for (var i = 0; i < events.size() && i < maxRows && (_topIndex + i) < events.size(); i += 1) {
                var event = events[events.size() - 1 - (_topIndex + i)] as Dictionary;
                var text = formatEvent(event) as String;
                dc.setColor(teamColor(event["teamId"]), Graphics.COLOR_BLACK);
                dc.drawText(12, y, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);
                y += 22;
            }

            if (events.size() > maxRows) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
                var older = events.size() - (_topIndex + maxRows);
                var label = older > 0 ? (older.format("%d") + " OLDER") : "NEWEST";
                dc.drawText(dc.getWidth() / 2, dc.getHeight() - 34, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

    }

    function visibleRows(dc as Graphics.Dc) as Number {
        var rows = ((dc.getHeight() - 68) / 22) as Number;
        return rows < 1 ? 1 : rows;
    }

    function clampTopIndex(eventCount as Number, maxRows as Number) as Void {
        var maxTop = eventCount - maxRows;
        if (maxTop < 0) {
            maxTop = 0;
        }
        if (_topIndex > maxTop) {
            _topIndex = maxTop;
        }
        if (_topIndex < 0) {
            _topIndex = 0;
        }
    }

    function scrollDown() as Void {
        var events = _model.eventLog() as Array<Dictionary>;
        if (_topIndex < events.size() - 1) {
            _topIndex += 1;
        }
    }

    function scrollUp() as Void {
        if (_topIndex > 0) {
            _topIndex -= 1;
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
