import Toybox.System;
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
        var teamId = (itemId == :team_home || itemId == "team_home" || itemId == :card_team_home || itemId == "card_team_home") ? RUGBY_TEAM_HOME : RUGBY_TEAM_AWAY;
        if (_action == "score") {
            if (teamId == RUGBY_TEAM_HOME) {
                WatchUi.pushView(new Rez.Menus.HomeScoreTypeMenu(), new RugbyScoreTypeDelegate(_model, teamId), WatchUi.SLIDE_UP);
            } else {
                WatchUi.pushView(new Rez.Menus.AwayScoreTypeMenu(), new RugbyScoreTypeDelegate(_model, teamId), WatchUi.SLIDE_UP);
            }
        } else {
            if (teamId == RUGBY_TEAM_HOME) {
                WatchUi.pushView(new Rez.Menus.HomeCardTypeMenu(), new RugbyCardTypeDelegate(_model, teamId), WatchUi.SLIDE_UP);
            } else {
                WatchUi.pushView(new Rez.Menus.AwayCardTypeMenu(), new RugbyCardTypeDelegate(_model, teamId), WatchUi.SLIDE_UP);
            }
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
