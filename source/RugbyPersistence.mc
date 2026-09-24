import Toybox.Application;
import Toybox.Lang;

const RUGBY_MATCH_STORAGE_KEY = "rugby.activeMatch.v1";

class RugbyPersistence {
    static function saveMatch(model as RugbyGameModel, nowMs as Number) as Void {
        saveMatchWithRecorder(model, nowMs, null);
    }

    static function saveMatchWithRecorder(model as RugbyGameModel, nowMs as Number, recorder) as Void {
        if (!model.hasRecoverableMatch()) {
            clearMatch();
            return;
        }
        try {
            var saved = model.recoverySnapshot(nowMs) as Dictionary;
            if (recorder != null && recorder has :snapshot) {
                var activity = recorder.snapshot() as Dictionary;
                saved["activityDistanceMeters"] = activity["distanceMeters"];
            }
            Application.Storage.setValue(RUGBY_MATCH_STORAGE_KEY, saved);
        } catch (storageError) {
        }
    }

    static function restoreMatch(model as RugbyGameModel, nowMs as Number) as Boolean {
        return restoreMatchWithRecorder(model, nowMs, null);
    }

    static function restoreMatchWithRecorder(model as RugbyGameModel, nowMs as Number, recorder) as Boolean {
        try {
            var saved = Application.Storage.getValue(RUGBY_MATCH_STORAGE_KEY) as Dictionary?;
            if (saved == null || !model.restoreRecovery(saved, nowMs)) {
                return false;
            }
            if (recorder != null && recorder has :restoreDistanceMeters) {
                recorder.restoreDistanceMeters(saved["activityDistanceMeters"]);
            }
            return true;
        } catch (storageError) {
            clearMatch();
            return false;
        }
    }

    static function clearMatch() as Void {
        try {
            Application.Storage.deleteValue(RUGBY_MATCH_STORAGE_KEY);
        } catch (storageError) {
        }
    }
}
