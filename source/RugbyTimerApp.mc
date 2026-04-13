import Toybox.Application;
import Toybox.System;
import Toybox.WatchUi;

class RugbyTimerApp extends Application.AppBase {
    var _model;
    var _recorder;
/* Create the shared RugbyGameModel and RugbyActivityRecorder for the app lifecycle. */

    function initialize() {
        AppBase.initialize();
        _model = new RugbyGameModel(RugbyVariantConfig.loadPreferences());
        _recorder = new RugbyActivityRecorder();
    }

    function onStart(state) {
    }
/* Save model preferences before app stops (preferences persistence is a no-op until store is wired). */

    function onStop(state) {
        if (_model != null) {
            _model.savePreferences();
        }
    }
/* Return the primary view and its behavior delegate for the watch UI. */

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


