import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

// Unified delegate handling both score-type and card-type selections for a team
class TeamActionTypeDelegate extends WatchUi.Menu2InputDelegate {
    var _model;
    var _teamId;
    var _action; // "score" or "card"
    var _haptics as RugbyHaptics;
    var _controller as RugbyMatchController?;

    function initialize(model, teamId, action, controller as RugbyMatchController?) {
        Menu2InputDelegate.initialize();
        _model = model;
        _teamId = teamId;
        _action = action;
        _haptics = new RugbyHaptics();
        _controller = controller;
    }

    function onSelect(item) {
        var now = System.getTimer();
        var itemId = item.getId();

        if (valueEquals(_action, "score")) {
            if (valueEquals(itemId, :score_try) || valueEquals(itemId, "score_try")) {
                _model.recordTry(_teamId, now);
                persist(now);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.pushView(new RugbyConversionView(_model, _teamId, _controller), new RugbyConversionDelegate(_model, _teamId, _controller), WatchUi.SLIDE_UP);
            } else if (valueEquals(itemId, :score_penalty_goal) || valueEquals(itemId, "score_penalty_goal") || valueEquals(itemId, :score_drop_goal) || valueEquals(itemId, "score_drop_goal")) {
                if (valueEquals(itemId, :score_penalty_goal) || valueEquals(itemId, "score_penalty_goal")) {
                    _model.recordPenaltyGoalAt(_teamId, now);
                } else if (valueEquals(itemId, :score_drop_goal) || valueEquals(itemId, "score_drop_goal")) {
                    _model.recordDropGoalAt(_teamId, now);
                }
                persist(now);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.requestUpdate();
            }
        } else if (valueEquals(_action, "card") && (valueEquals(itemId, :card_yellow) || valueEquals(itemId, "card_yellow") || valueEquals(itemId, :card_red) || valueEquals(itemId, "card_red"))) {
            var beforeSnap = _model.snapshot(now) as Dictionary;
            var wasRunning = valueEquals(beforeSnap["clockState"], RUGBY_STATE_RUNNING) as Boolean;
            if (valueEquals(itemId, :card_yellow) || valueEquals(itemId, "card_yellow")) {
                _model.startYellowCard(_teamId, now);
            } else if (valueEquals(itemId, :card_red) || valueEquals(itemId, "card_red")) {
                _model.recordRedCard(_teamId, now);
            }
            if (wasRunning) {
                _haptics.firePause();
            }
            persist(now);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.requestUpdate();
        }
    }

    function persist(nowMs as Number) as Void {
        if (_controller != null) {
            _controller.persist(nowMs);
        } else {
            RugbyPersistence.saveMatch(_model, nowMs);
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
