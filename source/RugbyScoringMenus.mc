import Toybox.System;
import Toybox.WatchUi;
/* Detect whether the selected menu item corresponds to HOME team. */

function rugbyIsTeamHome(item) {
    var itemId = item.getId();
    return itemId == :team_home || itemId == "team_home";
}

function rugbyIsScoreTry(item) {
    var itemId = item.getId();
    return itemId == :score_try || itemId == "score_try";
}

function rugbyIsPenaltyGoal(item) {
    var itemId = item.getId();
    return itemId == :score_penalty_goal || itemId == "score_penalty_goal";
}

function rugbyIsDropGoal(item) {
    var itemId = item.getId();
    return itemId == :score_drop_goal || itemId == "score_drop_goal";
}

class RugbyScoreTeamDelegate extends WatchUi.Menu2InputDelegate {
    var _model;

    function initialize(model) {
        Menu2InputDelegate.initialize();
        _model = model;
    }
/* Apply selected score type and manage navigation/pop/update as needed. */

    function onSelect(item) {
        var teamId = rugbyIsTeamHome(item) ? RUGBY_TEAM_HOME : RUGBY_TEAM_AWAY;
        if (teamId == RUGBY_TEAM_HOME) {
            WatchUi.pushView(new Rez.Menus.HomeScoreTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "score"), WatchUi.SLIDE_UP);
        } else {
            WatchUi.pushView(new Rez.Menus.AwayScoreTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "score"), WatchUi.SLIDE_UP);
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

// Removed legacy RugbyScoreTypeDelegate; use TeamActionTypeDelegate.
