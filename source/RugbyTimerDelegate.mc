import Toybox.System;
import Toybox.WatchUi;

class RugbyTimerDelegate extends WatchUi.BehaviorDelegate {
    var _model;
    var _recorder;
/* Store model and recorder references for delegate actions. */

    function initialize(model, recorder) {
        BehaviorDelegate.initialize();
        _model = model;
        _recorder = recorder;
    }
/* Handle primary button: confirm pending actions, start/pause/resume match and start recorder when match first starts. */

    function onSelect() {
        var now = System.getTimer();
        var snap = _model.snapshot(now);
        if (snap["pendingConfirmAction"] != null) {
            var confirmed = _model.confirmPending(now);
            if (confirmed && snap["pendingConfirmAction"] == "endMatchSave") {
                _recorder.stopAndSave();
            }
        } else if (snap["clockState"] == RUGBY_STATE_NOT_STARTED || snap["clockState"] == RUGBY_STATE_HALF_ENDED) {
            _model.startMatch(now);
            if (snap["clockState"] == RUGBY_STATE_NOT_STARTED) {
                _recorder.start();
            }
        } else if (snap["clockState"] == RUGBY_STATE_RUNNING) {
            _model.pause(now);
        } else if (snap["clockState"] == RUGBY_STATE_PAUSED) {
            _model.resume(now);
        }
        WatchUi.requestUpdate();
        return true;
    }
/* Cancel pending confirmation actions. */

    function onBack() {
        _model.cancelPendingAction();
        WatchUi.requestUpdate();
        return true;
    }

    function onMenu() {
        var snap = _model.snapshot(System.getTimer());
        if (snap["clockState"] == RUGBY_STATE_NOT_STARTED) {
            _model.adjustHalfMinutes(1);
            WatchUi.requestUpdate();
            return true;
        }
        return openScoreDialog();
    }

    function onNextPage() {
        var snap = _model.snapshot(System.getTimer());
        if (snap["clockState"] == RUGBY_STATE_NOT_STARTED) {
            _model.adjustHalfMinutes(-1);
            WatchUi.requestUpdate();
            return true;
        }
        if (snap["clockState"] == RUGBY_STATE_RUNNING || snap["clockState"] == RUGBY_STATE_PAUSED || snap["clockState"] == RUGBY_STATE_HALF_ENDED) {
            return openCardDialog();
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        var snap = _model.snapshot(System.getTimer());
        if (snap["clockState"] == RUGBY_STATE_NOT_STARTED) {
            _model.adjustHalfMinutes(1);
            WatchUi.requestUpdate();
            return true;
        }
        return openScoreDialog();
    }
/* Guard against invalid states (not started/match ended) before opening score menus. */

    function openScoreDialog() {
        var snap = _model.snapshot(System.getTimer());
        if (snap["clockState"] == RUGBY_STATE_NOT_STARTED || snap["clockState"] == RUGBY_STATE_MATCH_ENDED) {
            WatchUi.requestUpdate();
            return true;
        }
        WatchUi.pushView(new Rez.Menus.ScoreTeamMenu(), new TeamSelectionDelegate(_model, "score"), WatchUi.SLIDE_UP);
        return true;
    }

    function openCardDialog() {
        var snap = _model.snapshot(System.getTimer());
        if (snap["clockState"] == RUGBY_STATE_NOT_STARTED || snap["clockState"] == RUGBY_STATE_MATCH_ENDED) {
            WatchUi.requestUpdate();
            return true;
        }
        WatchUi.pushView(new Rez.Menus.CardTeamMenu(), new TeamSelectionDelegate(_model, "card"), WatchUi.SLIDE_UP);
        return true;
    }
/* Forward score recording to model and request UI update. */

    function recordScore(teamId, scoreType) {
        if (scoreType == RUGBY_SCORE_TRY) {
            _model.recordTry(teamId, System.getTimer());
        } else if (scoreType == RUGBY_SCORE_CONVERSION) {
            _model.recordConversion(teamId);
        } else if (scoreType == RUGBY_SCORE_PENALTY_GOAL) {
            _model.recordPenaltyGoal(teamId);
        } else if (scoreType == RUGBY_SCORE_DROP_GOAL) {
            _model.recordDropGoal(teamId);
        }
        WatchUi.requestUpdate();
    }

    function correctScore(teamId, scoreType) {
        _model.correctScore(teamId, scoreType);
        WatchUi.requestUpdate();
    }

    function startYellow(teamId) {
        _model.startYellowCard(teamId, System.getTimer());
        WatchUi.requestUpdate();
    }

    function recordRed(teamId) {
        _model.recordRedCard(teamId, System.getTimer());
        WatchUi.requestUpdate();
    }

    function clearSanction(id) {
        _model.clearSanction(id);
        WatchUi.requestUpdate();
    }

    function adjustHalfMinutes(deltaMinutes) {
        _model.adjustHalfMinutes(deltaMinutes);
        WatchUi.requestUpdate();
    }

    function setVariant(variantId) {
        _model.setVariant(variantId);
        WatchUi.requestUpdate();
    }

    function requestEndMatchSave() {
        _model.requestEndMatchSave();
        WatchUi.requestUpdate();
    }
}



