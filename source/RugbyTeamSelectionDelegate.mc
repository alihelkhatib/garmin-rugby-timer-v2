import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

// Generic delegate for team selection that supports both score and card flows.
class TeamSelectionDelegate extends WatchUi.Menu2InputDelegate {
    var _model;
    var _action; // "score" or "card"
    var _controller as RugbyMatchController?;

    function initialize(model, action, controller as RugbyMatchController?) {
        Menu2InputDelegate.initialize();
        _model = model;
        _action = action;
        _controller = controller;
    }

    function onSelect(item) {
        var itemId = item.getId();
        var teamId = teamIdForItem(itemId) as String?;
        if (teamId == null) {
            return;
        }
        if (valueEquals(_action, "score")) {
            if (valueEquals(teamId, RUGBY_TEAM_HOME)) {
                WatchUi.pushView(new Rez.Menus.HomeScoreTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "score", _controller), WatchUi.SLIDE_UP);
            } else {
                WatchUi.pushView(new Rez.Menus.AwayScoreTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "score", _controller), WatchUi.SLIDE_UP);
            }
        } else {
            if (valueEquals(teamId, RUGBY_TEAM_HOME)) {
                WatchUi.pushView(new Rez.Menus.HomeCardTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "card", _controller), WatchUi.SLIDE_UP);
            } else {
                WatchUi.pushView(new Rez.Menus.AwayCardTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "card", _controller), WatchUi.SLIDE_UP);
            }
        }
    }

    function teamIdForItem(itemId) as String? {
        if (valueEquals(itemId, :team_home) || valueEquals(itemId, "team_home") || valueEquals(itemId, :card_team_home) || valueEquals(itemId, "card_team_home")) {
            return RUGBY_TEAM_HOME;
        }
        if (valueEquals(itemId, :team_away) || valueEquals(itemId, "team_away") || valueEquals(itemId, :card_team_away) || valueEquals(itemId, "card_team_away")) {
            return RUGBY_TEAM_AWAY;
        }
        return null;
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
