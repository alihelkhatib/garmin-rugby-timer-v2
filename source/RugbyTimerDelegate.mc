import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class RugbyTimerDelegate extends WatchUi.BehaviorDelegate {
    var _model as RugbyGameModel;
    var _recorder;
    var _haptics as RugbyHaptics;
    var _controller as RugbyMatchController?;
/* Store model and recorder references for delegate actions. */

    function initialize(model as RugbyGameModel, recorder) {
        BehaviorDelegate.initialize();
        _model = model;
        _recorder = recorder;
        _haptics = new RugbyHaptics();
        _controller = null;
    }

    function setController(controller as RugbyMatchController) as Void {
        _controller = controller;
    }

    function setHaptics(haptics as RugbyHaptics) as Void {
        _haptics = haptics;
    }
/* Handle primary button: confirm pending actions, start/pause/resume match and start recorder when match first starts. */

    function onSelect() as Boolean {
        return selectAction();
    }

    function selectAction() as Boolean {
        var now = System.getTimer() as Number;
        var shouldPersist = true as Boolean;
        var snap = _model.snapshot(now) as Dictionary;
        var cs = snap["clockState"] == null ? "" : ("" + snap["clockState"]);

        if (snap["pendingConfirmAction"] != null) {
            var pending = snap["pendingConfirmAction"];
            var confirmed = _model.confirmPending(now) as Boolean;
            if (confirmed && stateEquals(pending, "endMatchSave")) {
                if (_recorder has :stopAndSaveWithEvents) {
                    _recorder.stopAndSaveWithEvents(_model.eventLog());
                } else {
                    _recorder.stopAndSave();
                }
                showMatchSummary();
            } else if (confirmed && stateEquals(pending, "endMatchExit")) {
                if (_recorder has :stopAndSaveWithEvents) {
                    _recorder.stopAndSaveWithEvents(_model.eventLog());
                } else {
                    _recorder.stopAndSave();
                }
                if (_controller != null) {
                    _controller.clearRecovery();
                } else {
                    RugbyPersistence.clearMatch();
                }
                System.exit();
            } else if (confirmed && stateEquals(pending, "resetMatch")) {
                if (_recorder has :discard) {
                    _recorder.discard();
                }
                if (_recorder has :reset) {
                    _recorder.reset();
                }
                if (_controller != null) {
                    _controller.clearRecovery();
                } else {
                    RugbyPersistence.clearMatch();
                }
                shouldPersist = false;
            }
        } else {
            _model.advance(now);
            snap = _model.snapshot(now);
            cs = snap["clockState"] == null ? "" : ("" + snap["clockState"]);
        }

        if (snap["pendingConfirmAction"] == null && (stateEquals(cs, RUGBY_STATE_NOT_STARTED) || stateEquals(cs, RUGBY_STATE_HALF_ENDED))) {
            _model.startMatch(now);
            if (stateEquals(cs, RUGBY_STATE_NOT_STARTED)) {
                _recorder.start();
                _haptics.fireMatchStart();
            }
        } else if (snap["pendingConfirmAction"] == null && stateEquals(cs, RUGBY_STATE_RUNNING)) {
            _model.pause(now);
            _haptics.firePause();
        } else if (snap["pendingConfirmAction"] == null && stateEquals(cs, RUGBY_STATE_PAUSED)) {
            _recorder.start();
            _model.resume(now);
            _haptics.fireResume();
        }
        if (shouldPersist && _controller != null) {
            _controller.persist(now);
        }
        WatchUi.requestUpdate();
        return true;
    }
/* Cancel pending confirmation actions. */

    function onBack() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (snap["pendingConfirmAction"] != null) {
            _model.cancelPendingAction();
            WatchUi.requestUpdate();
            return true;
        }
        if (allowsSystemExitForState(snap["clockState"])) {
            return false;
        }
        if (canOpenMatchOptionsForState(snap["clockState"])) {
            return openMatchOptions();
        }
        return false;
    }

    function onMenu() as Boolean {
        return menuAction();
    }

    function menuAction() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (canOpenVariantMenuForState(snap["clockState"])) {
            return openVariantMenu();
        }
        if (stateEquals(snap["clockState"], RUGBY_STATE_MATCH_ENDED)) {
            return openMatchOptions();
        }
        return upMenuAction();
    }

    function upMenuAction() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        var isAdjust = isIdleTimerAdjustmentState(snap["clockState"]);
        if (isAdjust) {
            _model.adjustIdleMainTimer(1);
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
        var isAdjust = isIdleTimerAdjustmentState(snap["clockState"]);
        if (isAdjust) {
            _model.adjustIdleMainTimer(-1);
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

    function handleKey(key as Number) as Boolean {
        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            return selectAction();
        }
        if (key == WatchUi.KEY_MENU) {
            return menuAction();
        }
        if (key == WatchUi.KEY_UP || key == WatchUi.KEY_UP_LEFT || key == WatchUi.KEY_UP_RIGHT) {
            return upMenuAction();
        }
        if (key == WatchUi.KEY_DOWN || key == WatchUi.KEY_DOWN_LEFT || key == WatchUi.KEY_DOWN_RIGHT) {
            return downAction();
        }
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

    function allowsSystemExitForState(clockState as String) as Boolean {
        return stateEquals(clockState, RUGBY_STATE_NOT_STARTED)
            || stateEquals(clockState, RUGBY_STATE_MATCH_ENDED);
    }
/* Guard against invalid states before opening score menus. */

    function openScoreDialog() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (!canOpenScoreDialogForState(snap["clockState"])) {
            WatchUi.requestUpdate();
            return true;
        }
        WatchUi.pushView(new Rez.Menus.ScoreTeamMenu(), new TeamSelectionDelegate(_model, "score", _controller), WatchUi.SLIDE_UP);
        return true;
    }

    function openCardDialog() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (!canOpenCardDialogForState(snap["clockState"])) {
            WatchUi.requestUpdate();
            return true;
        }
        WatchUi.pushView(new Rez.Menus.CardTeamMenu(), new TeamSelectionDelegate(_model, "card", _controller), WatchUi.SLIDE_UP);
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
        persistNow();
        WatchUi.requestUpdate();
    }

    function correctScore(teamId as String, scoreType as String) as Void {
        _model.correctScore(teamId, scoreType);
        persistNow();
        WatchUi.requestUpdate();
    }

    function startYellow(teamId as String) as Void {
        _model.startYellowCard(teamId, System.getTimer());
        persistNow();
        WatchUi.requestUpdate();
    }

    function recordRed(teamId as String) as Void {
        _model.recordRedCard(teamId, System.getTimer());
        persistNow();
        WatchUi.requestUpdate();
    }

    function clearSanction(id as Number) as Void {
        _model.clearSanction(id);
        persistNow();
        WatchUi.requestUpdate();
    }

    function adjustHalfMinutes(deltaMinutes as Number) as Void {
        _model.adjustHalfMinutes(deltaMinutes);
        persistNow();
        WatchUi.requestUpdate();
    }

    function setVariant(variantId as String) as Void {
        _model.setVariant(variantId);
        persistNow();
        WatchUi.requestUpdate();
    }

    function requestEndMatchSave() as Void {
        _model.requestEndMatchSave();
        WatchUi.requestUpdate();
    }

    function requestEndMatchExit() as Void {
        _model.requestEndMatchExit();
        WatchUi.requestUpdate();
    }

    function requestEndPeriod() as Void {
        if (_model.isFinalPeriod()) {
            _model.requestEndMatchSave();
        } else {
            _model.requestEndHalf();
        }
        WatchUi.requestUpdate();
    }

    function undoLastEvent() as Void {
        _model.undoLastEvent();
        persistNow();
        WatchUi.requestUpdate();
    }

    function exitApp() as Void {
        var now = System.getTimer() as Number;
        if (_recorder.state().equals(RUGBY_RECORDER_STATE_RECORDING)) {
            _recorder.stopAndSaveWithEvents(_model.eventLog());
        }
        if (_controller != null) {
            _controller.persist(now);
        } else {
            RugbyPersistence.saveMatchWithRecorder(_model, now, _recorder);
        }
        System.exit();
    }

    function requestResetMatch() as Void {
        _model.requestResetMatch();
        WatchUi.requestUpdate();
    }

    function persistNow() as Void {
        if (_controller != null) {
            _controller.persist(System.getTimer());
        }
    }

    function openMatchOptions() as Boolean {
        WatchUi.pushView(new Rez.Menus.MatchOptionsMenu(), new MatchOptionDelegate(self), WatchUi.SLIDE_UP);
        return true;
    }

    function showMatchSummary() as Void {
        WatchUi.pushView(new RugbyMatchSummaryView(_model), new RugbyMatchSummaryDelegate(), WatchUi.SLIDE_UP);
    }

    function openVariantMenu() as Boolean {
        var snap = _model.snapshot(System.getTimer()) as Dictionary;
        if (!canOpenVariantMenuForState(snap["clockState"])) {
            WatchUi.requestUpdate();
            return true;
        }
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
        if (variantId != null) {
            _timerDelegate.setVariant(variantId);
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function onBack() {
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
        if (valueEquals(itemId, :match_option_exit) || valueEquals(itemId, "match_option_exit")) {
            _timerDelegate.exitApp();
            return;
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        if (valueEquals(itemId, :match_option_period) || valueEquals(itemId, "match_option_period")) {
            _timerDelegate.requestEndPeriod();
        } else if (valueEquals(itemId, :match_option_end) || valueEquals(itemId, "match_option_end")) {
            _timerDelegate.requestEndMatchSave();
        } else if (valueEquals(itemId, :match_option_end_exit) || valueEquals(itemId, "match_option_end_exit")) {
            _timerDelegate.requestEndMatchExit();
        } else if (valueEquals(itemId, :match_option_undo) || valueEquals(itemId, "match_option_undo")) {
            _timerDelegate.undoLastEvent();
        } else if (valueEquals(itemId, :match_option_summary) || valueEquals(itemId, "match_option_summary")) {
            _timerDelegate.showMatchSummary();
        } else if (valueEquals(itemId, :match_option_reset) || valueEquals(itemId, "match_option_reset")) {
            _timerDelegate.requestResetMatch();
        }
        WatchUi.requestUpdate();
    }

    function onBack() {
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
