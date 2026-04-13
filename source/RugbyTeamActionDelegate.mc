import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

// Unified delegate handling both score-type and card-type selections for a team
class TeamActionTypeDelegate extends WatchUi.Menu2InputDelegate {
    var _model;
    var _teamId;
    var _action; // "score" or "card"
    var _haptics as RugbyHaptics;

    function initialize(model, teamId, action) {
        Menu2InputDelegate.initialize();
        _model = model;
        _teamId = teamId;
        _action = action;
        _haptics = new RugbyHaptics();
    }

    function onSelect(item) {
        var now = System.getTimer();
        var itemId = item.getId();
        System.println("RUGBY|TeamActionTypeDelegate|onSelect itemId=" + itemId + " action=" + (_action == null ? "null" : _action) + " teamId=" + (_teamId == null ? "null" : _teamId) + " nowMs=" + now.format("%d"));

        if (valueEquals(_action, "score")) {
            if (valueEquals(itemId, :score_try) || valueEquals(itemId, "score_try")) {
                System.println("RUGBY|TeamActionTypeDelegate|score try teamId=" + _teamId);
                _model.recordTry(_teamId, now);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.pushView(new RugbyConversionView(_model, _teamId), new RugbyConversionDelegate(_model, _teamId), WatchUi.SLIDE_UP);
            } else {
                if (valueEquals(itemId, :score_penalty_goal) || valueEquals(itemId, "score_penalty_goal")) {
                    System.println("RUGBY|TeamActionTypeDelegate|score penaltyGoal teamId=" + _teamId);
                    _model.recordPenaltyGoalAt(_teamId, now);
                } else if (valueEquals(itemId, :score_drop_goal) || valueEquals(itemId, "score_drop_goal")) {
                    System.println("RUGBY|TeamActionTypeDelegate|score dropGoal teamId=" + _teamId);
                    _model.recordDropGoalAt(_teamId, now);
                } else {
                    System.println("RUGBY|TeamActionTypeDelegate|score unknown itemId=" + itemId);
                }
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.requestUpdate();
            }
        } else {
            var beforeSnap = _model.snapshot(now) as Dictionary;
            var wasRunning = valueEquals(beforeSnap["clockState"], RUGBY_STATE_RUNNING) as Boolean;
            if (valueEquals(itemId, :card_yellow) || valueEquals(itemId, "card_yellow")) {
                var yellowId = _model.startYellowCard(_teamId, now) as Number;
                System.println("RUGBY|TeamActionTypeDelegate|card yellow teamId=" + _teamId + " sanctionId=" + yellowId.format("%d"));
            } else {
                var redId = _model.recordRedCard(_teamId, now) as Number;
                System.println("RUGBY|TeamActionTypeDelegate|card red teamId=" + _teamId + " sanctionId=" + redId.format("%d"));
            }
            if (wasRunning) {
                var haptic = _haptics.firePause() as Boolean;
                System.println("RUGBY|TeamActionTypeDelegate|cardPauseHaptic teamId=" + _teamId + " haptic=" + (haptic ? "true" : "false"));
            }
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.requestUpdate();
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
