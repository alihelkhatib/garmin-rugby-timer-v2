import Toybox.System;
import Toybox.WatchUi;

// Unified delegate handling both score-type and card-type selections for a team
class TeamActionTypeDelegate extends WatchUi.Menu2InputDelegate {
    var _model;
    var _teamId;
    var _action; // "score" or "card"

    function initialize(model, teamId, action) {
        Menu2InputDelegate.initialize();
        _model = model;
        _teamId = teamId;
        _action = action;
    }

    function onSelect(item) {
        var now = System.getTimer();
        var itemId = item.getId();

        if (_action == "score") {
            if (itemId == :score_try || itemId == "score_try") {
                _model.recordTry(_teamId, now);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.pushView(new RugbyConversionView(_model, _teamId), new RugbyConversionDelegate(_model, _teamId), WatchUi.SLIDE_UP);
            } else {
                if (itemId == :score_penalty_goal || itemId == "score_penalty_goal") {
                    _model.recordPenaltyGoal(_teamId);
                } else if (itemId == :score_drop_goal || itemId == "score_drop_goal") {
                    _model.recordDropGoal(_teamId);
                }
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.requestUpdate();
            }
        } else {
            // card flow
            if (itemId == :card_yellow || itemId == "card_yellow") {
                _model.startYellowCard(_teamId, now);
            } else {
                _model.recordRedCard(_teamId, now);
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
