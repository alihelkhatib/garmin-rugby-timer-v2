import Toybox.Application;
import Toybox.System;
import Toybox.WatchUi;

class RugbyTimerApp extends Application.AppBase {
    var _model;
    var _recorder;

    function initialize() {
        AppBase.initialize();
        _model = new RugbyGameModel(RugbyVariantConfig.loadPreferences());
        _recorder = new RugbyActivityRecorder();
    }

    function onStart(state) {
    }

    function onStop(state) {
        if (_model != null) {
            _model.savePreferences();
        }
    }

    function getInitialView() {
        var view = new RugbyTimerView(_model);
        var delegate = new RugbyTimerDelegate(_model, _recorder);
        return [ view, delegate ];
    }

    function getModel() {
        return _model;
    }

    function getRecorder() {
        return _recorder;
    }
}


