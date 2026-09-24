import Toybox.Application;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;

class RugbyTimerApp extends Application.AppBase {
    var _model;
    var _recorder;
    var _controller;
/* Create the shared RugbyGameModel and RugbyActivityRecorder for the app lifecycle. */

    function initialize() {
        AppBase.initialize();
        _model = new RugbyGameModel(RugbyVariantConfig.loadPreferences());
        _recorder = new RugbyActivityRecorder();
        RugbyPersistence.restoreMatchWithRecorder(_model, System.getTimer(), _recorder);
        _recorder.primeEventLog(_model.eventLog());
        _controller = new RugbyMatchController(_model, _recorder);
    }

    function onStart(state) {
        _recorder.enableGps();
    }
/* Save preferences and a recovery checkpoint before app shutdown. */

    function onStop(state) {
        if (_model != null) {
            _model.savePreferences();
            if (_recorder != null && _recorder.state().equals(RUGBY_RECORDER_STATE_RECORDING)) {
                _recorder.stopAndSaveWithEvents(_model.eventLog());
            }
            RugbyPersistence.saveMatchWithRecorder(_model, System.getTimer(), _recorder);
        }
        if (_recorder != null) {
            _recorder.disableGps();
            _recorder.disableHeartRate();
        }
    }
/* Return the primary view and its behavior delegate for the watch UI. */

    function getInitialView() {
        var view = new RugbyTimerView(_model);
        view.setRecorder(_recorder);
        view.setController(_controller);
        var delegate = new RugbyTimerDelegate(_model, _recorder);
        delegate.setController(_controller);

        return [ view, delegate ];
    }

    function getModel() {
        return _model;
    }

    function getRecorder() {
        return _recorder;
    }
}


