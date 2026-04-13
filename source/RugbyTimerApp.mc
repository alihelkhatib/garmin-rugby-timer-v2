import Toybox.Application;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;

// Minimal fallback delegate used if the primary delegate fails to initialize.
class FallbackDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        System.println("RUGBY|FallbackDelegate|onSelect");
        return false;
    }

    function onBack() as Boolean {
        System.println("RUGBY|FallbackDelegate|onBack");
        return false;
    }

    function onMenu() as Boolean {
        System.println("RUGBY|FallbackDelegate|onMenu");
        return false;
    }

    function onNextPage() as Boolean {
        System.println("RUGBY|FallbackDelegate|onNextPage");
        return false;
    }

    function onPreviousPage() as Boolean {
        System.println("RUGBY|FallbackDelegate|onPreviousPage");
        return false;
    }

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        try {
            var k = evt.getKey() as Number;
            System.println("RUGBY|FallbackDelegate|onKey key=" + k.format("%d"));
        } catch (ex) {
            System.println("RUGBY|FallbackDelegate|onKey ex=" + ex.toString());
        }
        return false;
    }
}

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
        var view;
        var delegate;
        try {
            view = new RugbyTimerView(_model);
        } catch (ex) {
            System.println("RUGBY|RugbyTimerApp|getInitialView view init failed: " + ex.toString());
            view = new WatchUi.View();
        }

        try {
            delegate = new RugbyTimerDelegate(_model, _recorder);
        } catch (ex) {
            System.println("RUGBY|RugbyTimerApp|getInitialView delegate init failed: " + ex.toString());
            delegate = new FallbackDelegate();
        }

        System.println("RUGBY|RugbyTimerApp|getInitialView modelPresent=" + (_model != null ? "yes" : "no") + " recorderPresent=" + (_recorder != null ? "yes" : "no") + " delegatePresent=" + (delegate == null ? "no" : "yes"));
        return [ view, delegate ];
    }

    function getModel() {
        return _model;
    }

    function getRecorder() {
        return _recorder;
    }
}


