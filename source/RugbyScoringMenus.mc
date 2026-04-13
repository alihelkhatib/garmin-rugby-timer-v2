import Toybox.System;
import Toybox.WatchUi;

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

    function onSelect(item) {
        var teamId = rugbyIsTeamHome(item) ? RUGBY_TEAM_HOME : RUGBY_TEAM_AWAY;
        if (teamId == RUGBY_TEAM_HOME) {
            WatchUi.pushView(new Rez.Menus.HomeScoreTypeMenu(), new RugbyScoreTypeDelegate(_model, teamId), WatchUi.SLIDE_UP);
        } else {
            WatchUi.pushView(new Rez.Menus.AwayScoreTypeMenu(), new RugbyScoreTypeDelegate(_model, teamId), WatchUi.SLIDE_UP);
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class RugbyScoreTypeDelegate extends WatchUi.Menu2InputDelegate {
    var _model;
    var _teamId;

    function initialize(model, teamId) {
        Menu2InputDelegate.initialize();
        _model = model;
        _teamId = teamId;
    }

    function onSelect(item) {
        var now = System.getTimer();
        if (rugbyIsScoreTry(item)) {
            _model.recordTry(_teamId, now);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.pushView(new RugbyConversionView(_model, _teamId), new RugbyConversionDelegate(_model, _teamId), WatchUi.SLIDE_UP);
        } else {
            if (rugbyIsPenaltyGoal(item)) {
                _model.recordPenaltyGoal(_teamId);
            } else if (rugbyIsDropGoal(item)) {
                _model.recordDropGoal(_teamId);
            }
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.requestUpdate();
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}