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
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_SMALL, WatchUi.loadResource(Rez.Strings.MatchSummary_Title), Graphics.TEXT_JUSTIFY_CENTER);

        var events = _model.eventLog() as Array<Dictionary>;
        if (events.size() == 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_XTINY, WatchUi.loadResource(Rez.Strings.MatchSummary_Empty), Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var y = 34 as Number;
        var rowHeight = 20 as Number;
        var maxRows = ((dc.getHeight() - y - 20) / rowHeight) as Number;
        if (maxRows < 1) {
            maxRows = 1;
        }
        if (maxRows > 8) {
            maxRows = 8;
        }
        var firstRow = events.size() > maxRows ? events.size() - maxRows : 0;
        for (var i = firstRow; i < events.size(); i += 1) {
            var event = events[i] as Dictionary;
            var text = formatEvent(event) as String;
            dc.setColor(teamColor(event["teamId"], dc), Graphics.COLOR_BLACK);
            dc.drawText(12, y, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);
            y += rowHeight;
        }

        if (events.size() > maxRows) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() - 24, Graphics.FONT_XTINY, "+" + (events.size() - maxRows).format("%d") + " EARLIER", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function formatEvent(event as Dictionary) as String {
        var text = formatClock(event["matchElapsedSeconds"]) + " " + teamText(event["teamId"]) + " " + actionText(event["action"]);
        if (valueEquals(event["status"], "corrected")) {
            text += " " + WatchUi.loadResource(Rez.Strings.Event_Corrected);
        }
        return text;
    }

    function teamText(teamId) as String {
        return valueEquals(teamId, RUGBY_TEAM_HOME) ? "H" : "A";
    }

    function teamColor(teamId, dc as Graphics.Dc) as Number {
        if (dc.getWidth() == dc.getHeight() && dc.getWidth() <= 180) {
            return Graphics.COLOR_WHITE;
        }
        return valueEquals(teamId, RUGBY_TEAM_HOME) ? Graphics.COLOR_BLUE : Graphics.COLOR_ORANGE;
    }

    function actionText(action) as String {
        if (valueEquals(action, RUGBY_SCORE_TRY)) {
            return WatchUi.loadResource(Rez.Strings.Event_Try);
        }
        if (valueEquals(action, RUGBY_EVENT_CONVERSION_MADE)) {
            return WatchUi.loadResource(Rez.Strings.Event_ConversionMade);
        }
        if (valueEquals(action, RUGBY_SCORE_PENALTY_GOAL)) {
            return WatchUi.loadResource(Rez.Strings.Event_PenaltyGoal);
        }
        if (valueEquals(action, RUGBY_SCORE_DROP_GOAL)) {
            return WatchUi.loadResource(Rez.Strings.Event_DropGoal);
        }
        if (valueEquals(action, "yellowCard")) {
            return WatchUi.loadResource(Rez.Strings.Event_YellowCard);
        }
        if (valueEquals(action, "redCard")) {
            return WatchUi.loadResource(Rez.Strings.Event_RedCard);
        }
        return "" + action;
    }

    function formatClock(totalSeconds) as String {
        return RugbyTime.formatClock(totalSeconds);
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }
}
