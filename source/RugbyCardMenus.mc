import Toybox.System;
import Toybox.WatchUi;
/* Detect whether the selected menu item corresponds to the HOME team card option. */

function rugbyIsCardTeamHome(item) {
    var itemId = item.getId();
    return itemId == :card_team_home || itemId == "card_team_home";
}

function rugbyIsYellowCard(item) {
    var itemId = item.getId();
    return itemId == :card_yellow || itemId == "card_yellow";
}

class RugbyCardTeamDelegate extends WatchUi.Menu2InputDelegate {
    var _model;

    function initialize(model) {
        Menu2InputDelegate.initialize();
        _model = model;
    }
/* Navigate into card type menus and forward selection to model; pop back to main view after selection. */

    function onSelect(item) {
        var teamId = rugbyIsCardTeamHome(item) ? RUGBY_TEAM_HOME : RUGBY_TEAM_AWAY;
        if (teamId == RUGBY_TEAM_HOME) {
            WatchUi.pushView(new Rez.Menus.HomeCardTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "card"), WatchUi.SLIDE_UP);
        } else {
            WatchUi.pushView(new Rez.Menus.AwayCardTypeMenu(), new TeamActionTypeDelegate(_model, teamId, "card"), WatchUi.SLIDE_UP);
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class RugbyCardTypeDelegate extends WatchUi.Menu2InputDelegate {
    var _model;
    var _teamId;

    function initialize(model, teamId) {
        Menu2InputDelegate.initialize();
        _model = model;
        _teamId = teamId;
    }
/* Navigate into card type menus and forward selection to model; pop back to main view after selection. */

    function onSelect(item) {
        if (rugbyIsYellowCard(item)) {
            _model.startYellowCard(_teamId, System.getTimer());
        } else {
            _model.recordRedCard(_teamId, System.getTimer());
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}