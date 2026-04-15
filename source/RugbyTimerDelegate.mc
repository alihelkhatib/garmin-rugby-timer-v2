import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class RugbyTimerDelegate extends WatchUi.BehaviorDelegate {
    var _model as RugbyGameModel;
    var _recorder;
    var _haptics as RugbyHaptics;
/* Store model and recorder references for delegate actions. */

    function initialize(model as RugbyGameModel, recorder) {
        BehaviorDelegate.initialize();
        _model = model;
        _recorder = recorder;
        _haptics = new RugbyHaptics();
    }
/* Handle primary button: confirm pending actions, start/pause/resume match and start recorder when match first starts. */

    function onSelect() as Boolean {
        return selectAction();
    }

    function selectAction() as Boolean {
        var now = System.getTimer() as Number;
        var snap = _model.snapshot(now) as Dictionary;
        var cs = snap["clockState"] == null ? "" : ("" + snap["clockState"]);
        System.println("RUGBY|RugbyTimerDelegate|selectAction csRaw=<" + (snap["clockState"] == null ? "null" : snap["clockState"]) + "> csCoerced=<" + cs + ">");
        System.println("RUGBY|RugbyTimerDelegate|selectAction nowMs=" + now.format("%d")
            + " snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d"))
            + " clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"])
            + " pending=" + (snap["pendingConfirmAction"] == null ? "null" : snap["pendingConfirmAction"]));

        if (snap["pendingConfirmAction"] != null) {
            var pending = snap["pendingConfirmAction"];
            var confirmed = _model.confirmPending(now) as Boolean;
            System.println("RUGBY|RugbyTimerDelegate|selectAction confirmPending result=" + (confirmed ? "true" : "false"));
            if (confirmed && stateEquals(pending, "endMatchSave")) {
                System.println("RUGBY|RugbyTimerDelegate|selectAction confirmed endMatchSave -> _recorder.stopAndSaveWithEvents");
                if (_recorder has :stopAndSaveWithEvents) {
                    _recorder.stopAndSaveWithEvents(_model.eventLog());
                } else {
                    _recorder.stopAndSave();
                }
                showMatchSummary();
            } else if (confirmed && stateEquals(pending, "resetMatch")) {
                System.println("RUGBY|RugbyTimerDelegate|selectAction confirmed resetMatch -> recorder discard");
                if (_recorder has :discard) {
                    _recorder.discard();
                }
            }
        } else if (stateEquals(cs, RUGBY_STATE_NOT_STARTED) || stateEquals(cs, RUGBY_STATE_HALF_ENDED)) {
            System.println("RUGBY|RugbyTimerDelegate|selectAction calling _model.startMatch");
            _model.startMatch(now);
            var afterStart = _model.snapshot(now) as Dictionary;
            System.println("RUGBY|RugbyTimerDelegate|selectAction afterStart snapshotId=" + (afterStart["snapshotId"] == null ? "null" : afterStart["snapshotId"].format("%d")) + " clockState=" + (afterStart["clockState"] == null ? "null" : afterStart["clockState"]) + " mainCountdownSeconds=" + (afterStart["mainCountdownSeconds"] == null ? "null" : afterStart["mainCountdownSeconds"].format("%d")) + " countUpSeconds=" + (afterStart["countUpSeconds"] == null ? "null" : afterStart["countUpSeconds"].format("%d")));
            if (stateEquals(cs, RUGBY_STATE_NOT_STARTED)) {
                System.println("RUGBY|RugbyTimerDelegate|selectAction calling _recorder.start");
                _recorder.start();
                var haptic = _haptics.fireMatchStart() as Boolean;
                System.println("RUGBY|RugbyTimerDelegate|selectAction matchStartHaptic=" + (haptic ? "true" : "false"));
            }
        } else if (stateEquals(cs, RUGBY_STATE_RUNNING)) {
            System.println("RUGBY|RugbyTimerDelegate|selectAction calling _model.pause");
            _model.pause(now);
            var pauseHaptic = _haptics.firePause() as Boolean;
            var afterPause = _model.snapshot(now) as Dictionary;
            System.println("RUGBY|RugbyTimerDelegate|selectAction afterPause snapshotId=" + (afterPause["snapshotId"] == null ? "null" : afterPause["snapshotId"].format("%d")) + " clockState=" + (afterPause["clockState"] == null ? "null" : afterPause["clockState"]) + " countUpSeconds=" + (afterPause["countUpSeconds"] == null ? "null" : afterPause["countUpSeconds"].format("%d")) + " pauseHaptic=" + (pauseHaptic ? "true" : "false"));
        } else if (stateEquals(cs, RUGBY_STATE_PAUSED)) {
            System.println("RUGBY|RugbyTimerDelegate|selectAction calling _model.resume");
            _model.resume(now);
            var afterResume = _model.snapshot(now) as Dictionary;
            System.println("RUGBY|RugbyTimerDelegate|selectAction afterResume snapshotId=" + (afterResume["snapshotId"] == null ? "null" : afterResume["snapshotId"].format("%d")) + " clockState=" + (afterResume["clockState"] == null ? "null" : afterResume["clockState"]) + " countUpSeconds=" + (afterResume["countUpSeconds"] == null ? "null" : afterResume["countUpSeconds"].format("%d")));
        }
        System.println("RUGBY|RugbyTimerDelegate|selectAction requestUpdate");
        WatchUi.requestUpdate();
        return true;
    }
/* Cancel pending confirmation actions. */

    function onBack() as Boolean {
        System.println("RUGBY|RugbyTimerDelegate|onBack");
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (snap["pendingConfirmAction"] != null) {
            System.println("RUGBY|RugbyTimerDelegate|onBack cancelPending pending=" + snap["pendingConfirmAction"]);
            _model.cancelPendingAction();
            WatchUi.requestUpdate();
            return true;
        }
        if (canOpenMatchOptionsForState(snap["clockState"])) {
            return openMatchOptions();
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onMenu() as Boolean {
        return menuAction();
    }

    function menuAction() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (canOpenVariantMenuForState(snap["clockState"])) {
            return openVariantMenu();
        }
        System.println("RUGBY|RugbyTimerDelegate|menuAction variantMenuBlocked clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
        return upMenuAction();
    }

    function upMenuAction() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        System.println("RUGBY|RugbyTimerDelegate|upMenuAction snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")) + " clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
        System.println("RUGBY|RugbyTimerDelegate|upMenuAction rawClockState=<" + (snap["clockState"] == null ? "null" : snap["clockState"]) + "> coerced=<" + (snap["clockState"] == null ? "null" : ("" + snap["clockState"])) + ">");
        var isAdjust = isIdleTimerAdjustmentState(snap["clockState"]);
        System.println("RUGBY|RugbyTimerDelegate|upMenuAction isIdleAdjustment=" + (isAdjust ? "true" : "false"));
        if (isAdjust) {
            System.println("RUGBY|RugbyTimerDelegate|upMenuAction calling _model.adjustIdleMainTimer(1)");
            _model.adjustIdleMainTimer(1);
            System.println("RUGBY|RugbyTimerDelegate|upMenuAction called _model.adjustIdleMainTimer(1)");
            WatchUi.requestUpdate();
            return true;
        }
        return openScoreDialog();
    }

    function onNextPage() as Boolean {
        return downAction();
    }

    function downAction() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        System.println("RUGBY|RugbyTimerDelegate|downAction snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")) + " clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
        System.println("RUGBY|RugbyTimerDelegate|downAction rawClockState=<" + (snap["clockState"] == null ? "null" : snap["clockState"]) + "> coerced=<" + (snap["clockState"] == null ? "null" : ("" + snap["clockState"])) + ">");
        var isAdjust = isIdleTimerAdjustmentState(snap["clockState"]);
        System.println("RUGBY|RugbyTimerDelegate|downAction isIdleAdjustment=" + (isAdjust ? "true" : "false"));
        if (isAdjust) {
            System.println("RUGBY|RugbyTimerDelegate|downAction calling _model.adjustIdleMainTimer(-1)");
            _model.adjustIdleMainTimer(-1);
            System.println("RUGBY|RugbyTimerDelegate|downAction called _model.adjustIdleMainTimer(-1)");
            WatchUi.requestUpdate();
            return true;
        }
        if (canOpenCardDialogForState(snap["clockState"])) {
            return openCardDialog();
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        return upMenuAction();
    }

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var keyNum;
        try {
            keyNum = evt.getKey() as Number;
            System.println("RUGBY|RugbyTimerDelegate|onKey(KeyEvent) key=" + keyNum.format("%d"));
        } catch (ex) {
            System.println("RUGBY|RugbyTimerDelegate|onKey EX getKey: " + ex.toString());
            try {
                keyNum = evt as Number;
                System.println("RUGBY|RugbyTimerDelegate|onKey cast evt as Number key=" + keyNum.format("%d"));
            } catch (ex2) {
                System.println("RUGBY|RugbyTimerDelegate|onKey unable to extract key; evt=" + evt);
                return false;
            }
        }
        return handleKey(keyNum);
    }

    function handleKey(key as Number) as Boolean {
        System.println("RUGBY|RugbyTimerDelegate|handleKey key=" + key.format("%d"));
        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            System.println("RUGBY|RugbyTimerDelegate|handleKey -> selectAction");
            return selectAction();
        }
        if (key == WatchUi.KEY_MENU) {
            System.println("RUGBY|RugbyTimerDelegate|handleKey -> menuAction");
            return menuAction();
        }
        if (key == WatchUi.KEY_UP || key == WatchUi.KEY_UP_LEFT || key == WatchUi.KEY_UP_RIGHT) {
            System.println("RUGBY|RugbyTimerDelegate|handleKey -> upMenuAction");
            return upMenuAction();
        }
        if (key == WatchUi.KEY_DOWN || key == WatchUi.KEY_DOWN_LEFT || key == WatchUi.KEY_DOWN_RIGHT) {
            System.println("RUGBY|RugbyTimerDelegate|handleKey -> downAction");
            return downAction();
        }
        System.println("RUGBY|RugbyTimerDelegate|handleKey UNHANDLED key=" + key.format("%d"));
        return false;
    }

    function isIdleTimerAdjustmentState(clockState as String) as Boolean {
        return stateEquals(clockState, RUGBY_STATE_NOT_STARTED);
    }

    function isActiveMatchState(clockState as String) as Boolean {
        return stateEquals(clockState, RUGBY_STATE_RUNNING)
            || stateEquals(clockState, RUGBY_STATE_PAUSED)
            || stateEquals(clockState, RUGBY_STATE_HALF_ENDED);
    }

    function stateEquals(value, expected as String) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals(expected);
    }

    function canOpenScoreDialogForState(clockState as String) as Boolean {
        return isActiveMatchState(clockState);
    }

    function canOpenCardDialogForState(clockState as String) as Boolean {
        return isActiveMatchState(clockState);
    }

    function canOpenMatchOptionsForState(clockState as String) as Boolean {
        return isActiveMatchState(clockState) || stateEquals(clockState, RUGBY_STATE_MATCH_ENDED);
    }

    function canOpenVariantMenuForState(clockState as String) as Boolean {
        return stateEquals(clockState, RUGBY_STATE_NOT_STARTED);
    }
/* Guard against invalid states before opening score menus. */

    function openScoreDialog() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (!canOpenScoreDialogForState(snap["clockState"])) {
            WatchUi.requestUpdate();
            return true;
        }
        System.println("RUGBY|RugbyTimerDelegate|openScoreDialog push ScoreTeamMenu snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")) + " clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
        WatchUi.pushView(new Rez.Menus.ScoreTeamMenu(), new TeamSelectionDelegate(_model, "score"), WatchUi.SLIDE_UP);
        return true;
    }

    function openCardDialog() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (!canOpenCardDialogForState(snap["clockState"])) {
            WatchUi.requestUpdate();
            return true;
        }
        System.println("RUGBY|RugbyTimerDelegate|openCardDialog push CardTeamMenu snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")) + " clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
        WatchUi.pushView(new Rez.Menus.CardTeamMenu(), new TeamSelectionDelegate(_model, "card"), WatchUi.SLIDE_UP);
        return true;
    }
/* Forward score recording to model and request UI update. */

    function recordScore(teamId as String, scoreType as String) as Void {
        var now = System.getTimer() as Number;
        if (stateEquals(scoreType, RUGBY_SCORE_TRY)) {
            _model.recordTry(teamId, now);
        } else if (stateEquals(scoreType, RUGBY_SCORE_CONVERSION)) {
            _model.recordConversionAt(teamId, now);
        } else if (stateEquals(scoreType, RUGBY_SCORE_PENALTY_GOAL)) {
            _model.recordPenaltyGoalAt(teamId, now);
        } else if (stateEquals(scoreType, RUGBY_SCORE_DROP_GOAL)) {
            _model.recordDropGoalAt(teamId, now);
        }
        WatchUi.requestUpdate();
    }

    function correctScore(teamId as String, scoreType as String) as Void {
        _model.correctScore(teamId, scoreType);
        WatchUi.requestUpdate();
    }

    function startYellow(teamId as String) as Void {
        _model.startYellowCard(teamId, System.getTimer());
        WatchUi.requestUpdate();
    }

    function recordRed(teamId as String) as Void {
        _model.recordRedCard(teamId, System.getTimer());
        WatchUi.requestUpdate();
    }

    function clearSanction(id as Number) as Void {
        _model.clearSanction(id);
        WatchUi.requestUpdate();
    }

    function adjustHalfMinutes(deltaMinutes as Number) as Void {
        _model.adjustHalfMinutes(deltaMinutes);
        WatchUi.requestUpdate();
    }

    function setVariant(variantId as String) as Void {
        System.println("RUGBY|RugbyTimerDelegate|setVariant variantId=" + variantId);
        _model.setVariant(variantId);
        WatchUi.requestUpdate();
    }

    function requestEndMatchSave() as Void {
        _model.requestEndMatchSave();
        WatchUi.requestUpdate();
    }

    function requestResetMatch() as Void {
        _model.requestResetMatch();
        WatchUi.requestUpdate();
    }

    function openMatchOptions() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        System.println("RUGBY|RugbyTimerDelegate|openMatchOptions snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")) + " clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
        WatchUi.pushView(new Rez.Menus.MatchOptionsMenu(), new MatchOptionDelegate(self), WatchUi.SLIDE_UP);
        return true;
    }

    function showMatchSummary() as Void {
        System.println("RUGBY|RugbyTimerDelegate|showMatchSummary eventCount=" + _model.eventLog().size().format("%d"));
        WatchUi.pushView(new RugbyMatchSummaryView(_model), new RugbyMatchSummaryDelegate(), WatchUi.SLIDE_UP);
    }

    function openVariantMenu() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (!canOpenVariantMenuForState(snap["clockState"])) {
            System.println("RUGBY|RugbyTimerDelegate|openVariantMenu blocked clockState=" + (snap["clockState"] == null ? "null" : snap["clockState"]));
            WatchUi.requestUpdate();
            return true;
        }
        System.println("RUGBY|RugbyTimerDelegate|openVariantMenu snapshotId=" + (snap["snapshotId"] == null ? "null" : snap["snapshotId"].format("%d")) + " currentVariant=" + (snap["variantId"] == null ? "null" : snap["variantId"]));
        WatchUi.pushView(new Rez.Menus.VariantMenu(), new RugbyVariantMenuDelegate(self), WatchUi.SLIDE_UP);
        return true;
    }
}

class RugbyVariantMenuDelegate extends WatchUi.Menu2InputDelegate {
    var _timerDelegate as RugbyTimerDelegate;

    function initialize(timerDelegate as RugbyTimerDelegate) {
        Menu2InputDelegate.initialize();
        _timerDelegate = timerDelegate;
    }

    function onSelect(item) {
        var itemId = item.getId();
        var variantId = variantIdForItem(itemId) as String?;
        System.println("RUGBY|RugbyVariantMenuDelegate|onSelect itemId=" + itemId + " variantId=" + (variantId == null ? "null" : variantId));
        if (variantId != null) {
            _timerDelegate.setVariant(variantId);
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function onBack() {
        System.println("RUGBY|RugbyVariantMenuDelegate|onBack cancel");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function variantIdForItem(itemId) as String? {
        if (valueEquals(itemId, :variant_fifteens) || valueEquals(itemId, "variant_fifteens")) {
            return RUGBY_VARIANT_FIFTEENS;
        }
        if (valueEquals(itemId, :variant_sevens) || valueEquals(itemId, "variant_sevens")) {
            return RUGBY_VARIANT_SEVENS;
        }
        if (valueEquals(itemId, :variant_tens) || valueEquals(itemId, "variant_tens")) {
            return RUGBY_VARIANT_TENS;
        }
        if (valueEquals(itemId, :variant_u19) || valueEquals(itemId, "variant_u19")) {
            return RUGBY_VARIANT_U19;
        }
        return null;
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }
}

class MatchOptionDelegate extends WatchUi.Menu2InputDelegate {
    var _timerDelegate as RugbyTimerDelegate;

    function initialize(timerDelegate as RugbyTimerDelegate) {
        Menu2InputDelegate.initialize();
        _timerDelegate = timerDelegate;
    }

    function onSelect(item) {
        var itemId = item.getId();
        System.println("RUGBY|MatchOptionDelegate|onSelect itemId=" + itemId);
        if (valueEquals(itemId, :match_option_end) || valueEquals(itemId, "match_option_end")) {
            _timerDelegate.requestEndMatchSave();
        } else if (valueEquals(itemId, :match_option_summary) || valueEquals(itemId, "match_option_summary")) {
            _timerDelegate.showMatchSummary();
        } else if (valueEquals(itemId, :match_option_reset) || valueEquals(itemId, "match_option_reset")) {
            _timerDelegate.requestResetMatch();
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function onBack() {
        System.println("RUGBY|MatchOptionDelegate|onBack cancel");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function valueEquals(value, expected) as Boolean {
        if (value == null || expected == null) {
            return false;
        }
        return ("" + value).equals("" + expected);
    }
}

class RugbyMatchSummaryDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
