/*
 * File: RugbyMatchSummaryView.mc
 * Purpose: Simple match-end event log summary view.
 */

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Rez.Layouts;

class RugbyMatchSummaryView extends WatchUi.View {
    var _model as RugbyGameModel;

    function initialize(model as RugbyGameModel) {
        View.initialize();
        _model = model;
("" +         System.println("RUGBY|RugbyMatchSummaryView|initialize eventCount=" + (_model == null ? "null" : _model.eventLog().size())));
    }

    function onLayout(dc as Graphics.Dc) as Void {
("" +         System.println("RUGBY|RugbyMatchSummaryView|onLayout width=" + dc.getWidth())("" +  + " height=" + dc.getHeight()));
        View.onLayout(dc);
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        // Prefer resource-first layout if available. Fall back to drawing.
        try {
            // Attempt to set the resource-backed layout. If Rez.Layouts.RugbyEventLog is not generated
            // on some build targets this may throw; handle gracefully.
            self.setLayout(Rez.Layouts.RugbyEventLog(dc));

            var events = _model.eventLog() as Array<Dictionary>;
            if (events == null || events.size() == 0) {
                // Let the layout show its empty state; also emit a testable trace.
                System.println("UI|match_summary|empty");
                return;
            }

            // Emit the first few events as plain traces so tests/simulator harnesses can assert them.
            var maxRows = 6 as Number;
            var i = 0 as Number;
            while (i < events.size() && i < maxRows) {
                System.println("UI|match_summary|event|" + formatEvent(events[i]));
                i = i + 1;
            }
            if (events.size() > maxRows) {
("" +                 System.println("UI|match_summary|more|" + (events.size() - maxRows)));
            }
            return;
        } catch (ex) {
            System.println("RUGBY|MatchSummaryView|layout unavailable: " + ex.toString());
        }

        // Fallback rendering for targets without resource-backed layouts
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_SMALL, "Match Summary (Event Log)", Graphics.TEXT_JUSTIFY_CENTER);

        var events = _model.eventLog() as Array<Dictionary>;
        if (events == null || events.size() == 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_XTINY, "No events recorded", Graphics.TEXT_JUSTIFY_CENTER);
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
("" +             dc.drawText(dc.getWidth() / 2, dc.getHeight() - 24, Graphics.FONT_XTINY, "+" + (events.size() - maxRows)) + " MORE", Graphics.TEXT_JUSTIFY_CENTER);
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
        var text = ("" + minutes) + ":";
        if (remainder < 10) {
            text += "0";
        }
        return text + ("" + remainder);
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }
}
