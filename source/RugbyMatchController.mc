import Toybox.Lang;

class RugbyMatchController {
    var _model as RugbyGameModel;
    var _recorder;
    var _summaryPending as Boolean;

    function initialize(model as RugbyGameModel, recorder) {
        _model = model;
        _recorder = recorder;
        _summaryPending = false;
    }

    function tick(nowMs as Number) as Dictionary {
        if (_model.advance(nowMs)) {
            persist(nowMs);
        }
        if (_model.consumeAutoMatchEndPendingSave()) {
            if (_recorder has :stopAndSaveWithEvents) {
                _recorder.stopAndSaveWithEvents(_model.eventLog());
            } else if (_recorder has :stopAndSave) {
                _recorder.stopAndSave();
            }
            _summaryPending = true;
            persist(nowMs);
        }
        return _model.snapshot(nowMs);
    }

    function persist(nowMs as Number) as Void {
        if (_recorder has :syncEventLog) {
            _recorder.syncEventLog(_model.eventLog(), _model.snapshot(nowMs));
        }
        _model.savePreferences();
        RugbyPersistence.saveMatchWithRecorder(_model, nowMs, _recorder);
    }

    function clearRecovery() as Void {
        RugbyPersistence.clearMatch();
    }

    function consumeSummaryRequest() as Boolean {
        if (!_summaryPending) {
            return false;
        }
        _summaryPending = false;
        return true;
    }
}
