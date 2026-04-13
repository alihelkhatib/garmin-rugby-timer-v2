import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

// Generic delegate for team selection that supports both score and card flows.
class TeamSelectionDelegate extends WatchUi.Menu2InputDelegate {
    var _model;
    var _action; // "score" or "card"

    function initialize(model, action) {
        Menu2InputDelegate.initialize();
        _model = model;
        _action = action;
    }

    function onSelect(item) {
        var itemId = item.getId();
        var teamId = (valueEquals(itemId, :team_home) || valueEquals(itemId, "team_home") || valueEquals(itemId, :card_team_home) || valueEquals(itemId, "card_team_home")) ? RUGBY_TEAM_HOME : RUGBY_TEAM_AWAY;
        System.println("RUGBY|TeamSelectionDelegate|onSelect itemId=" + itemId + " action=" + (_action == null ? "null" : _action) + " teamId=" + teamId);
        if (valueEquals(_action, "score")) {
            if (valueEquals(teamId, RUGBY_TEAM_HOME)) {
                System.println("RUGBY|TeamSelectionDelegate|route HomeScoreTypeMenu");
                WatchUi.pushView(new Rez.Menus.HomeScoreTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "score"), WatchUi.SLIDE_UP);
            } else {
                System.println("RUGBY|TeamSelectionDelegate|route AwayScoreTypeMenu");
                WatchUi.pushView(new Rez.Menus.AwayScoreTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "score"), WatchUi.SLIDE_UP);
            }
        } else {
            if (valueEquals(teamId, RUGBY_TEAM_HOME)) {
                System.println("RUGBY|TeamSelectionDelegate|route HomeCardTypeMenu");
                WatchUi.pushView(new Rez.Menus.HomeCardTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "card"), WatchUi.SLIDE_UP);
            } else {
                System.println("RUGBY|TeamSelectionDelegate|route AwayCardTypeMenu");
                WatchUi.pushView(new Rez.Menus.AwayCardTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "card"), WatchUi.SLIDE_UP);
            }
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }
}
