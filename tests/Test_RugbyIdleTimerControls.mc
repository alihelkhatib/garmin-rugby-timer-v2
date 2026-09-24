/*
Test: tests/Test_RugbyIdleTimerControls.mc

What this test file covers:
- Verifies idle physical-button routing for timer adjustment, variant selection gates, and active-match score/card dialog availability gates.

How to run locally:
- See docs/testing.md for SDK/CLI commands. Tests run at app startup via Toybox.Test.

Key assertions/behaviours:
- Idle Up-style adjustment increments by one minute and remains score-dialog blocked.
- Idle Down-style adjustment decrements by one minute and remains score-dialog blocked.
- Dedicated Menu is available for pre-match variant selection.
- Score dialogs are allowed only while running, paused, or half-ended.
- Card dialogs remain allowed for the same active match states.

Preconditions / setup:
- Tests exercise the delegate's state-gate helpers and the model-backed idle timer adjustment path.
*/

using Toybox.Test;
using Toybox.WatchUi;
using Toybox.System;

class IdleTimerControlsTestRecorder {
    var _started;
    var _saved;
    var _discarded;
    var _eventCount;

    function initialize() {
        _started = false;
        _saved = false;
        _discarded = false;
        _eventCount = 0;
    }

    function start() {
        _started = true;
    }

    function stopAndSave() {
        _saved = true;
    }

    function stopAndSaveWithEvents(events) {
        _saved = true;
        _eventCount = events == null ? 0 : events.size();
    }

    function discard() {
        _discarded = true;
    }
}

class IdleTimerControlsTestHaptics extends RugbyHaptics {
    var resumeCount;

    function initialize() {
        RugbyHaptics.initialize();
        resumeCount = 0;
    }

    function fireResume() {
        resumeCount += 1;
        return true;
    }
}

function newIdleTimerControlsModel() {
    return new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS));
}

function newIdleTimerControlsDelegate(model) {
    return new RugbyTimerDelegate(model, new IdleTimerControlsTestRecorder());
}

(:test)
function testIdleUpIncrementsTimerAndBlocksScoreDialog(logger) {
    var model = newIdleTimerControlsModel();
    model.adjustIdleMainTimer(-1);
    var delegate = newIdleTimerControlsDelegate(model);

    var before = model.snapshot(0);
    Test.assertEqual(39 * 60, before["mainCountdownSeconds"]);
    Test.assertEqual(true, delegate.isIdleTimerAdjustmentState(before["clockState"]));
    Test.assertEqual(false, delegate.canOpenScoreDialogForState(before["clockState"]));

    Test.assertEqual(true, delegate.onPreviousPage());
    var after = model.snapshot(0);
    Test.assertEqual(40 * 60, after["mainCountdownSeconds"]);
    Test.assertEqual(false, delegate.canOpenScoreDialogForState(after["clockState"]));
    return true;
}

(:test)
function testIdleDownDecrementsTimerAndBlocksMenus(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);

    Test.assertEqual(true, delegate.onNextPage());
    var snap = model.snapshot(0);
    Test.assertEqual(39 * 60, snap["mainCountdownSeconds"]);
    Test.assertEqual(true, delegate.isIdleTimerAdjustmentState(snap["clockState"]));
    Test.assertEqual(false, delegate.canOpenScoreDialogForState(snap["clockState"]));
    Test.assertEqual(false, delegate.canOpenCardDialogForState(snap["clockState"]));
    return true;
}

(:test)
function testIdlePhysicalUpKeyIncrementsTimer(logger) {
    var model = newIdleTimerControlsModel();
    model.adjustIdleMainTimer(-2);
    var delegate = newIdleTimerControlsDelegate(model);

    Test.assertEqual(true, delegate.handleKey(WatchUi.KEY_UP));
    var snap = model.snapshot(0);
    Test.assertEqual(39 * 60, snap["mainCountdownSeconds"]);
    return true;
}

(:test)
function testIdlePhysicalDownKeyDecrementsTimer(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);

    Test.assertEqual(true, delegate.handleKey(WatchUi.KEY_DOWN));
    var snap = model.snapshot(0);
    Test.assertEqual(39 * 60, snap["mainCountdownSeconds"]);
    return true;
}

(:test)
function testIdlePhysicalStartKeyBeginsMatch(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);

    model.adjustIdleMainTimer(-5);
    Test.assertEqual(true, delegate.handleKey(WatchUi.KEY_ENTER));
    var snap = model.snapshot(System.getTimer() + 60000);

    Test.assertEqual(RUGBY_STATE_RUNNING, snap["clockState"]);
    Test.assertEqual((35 * 60) - 60, snap["mainCountdownSeconds"]);
    return true;
}

(:test)
function testPausedTimerResumeFiresOneConfirmationHaptic(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);
    var haptics = new IdleTimerControlsTestHaptics();
    delegate.setHaptics(haptics);

    model.startMatch(0);
    model.pause(1000);
    Test.assertEqual(true, delegate.selectAction());
    Test.assertEqual(RUGBY_STATE_RUNNING, model.snapshot(System.getTimer())["clockState"]);
    Test.assertEqual(1, haptics.resumeCount);

    Test.assertEqual(true, delegate.selectAction());
    Test.assertEqual(1, haptics.resumeCount);
    return true;
}

(:test)
function testRuntimeClockStateStringsUseValueComparison(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);
    var notStartedPrefix = "not";
    var runningPrefix = "run";
    var pausedPrefix = "pa";
    var halfPrefix = "half";

    Test.assertEqual(true, model.isClockState(notStartedPrefix + "Started"));
    Test.assertEqual(true, delegate.isIdleTimerAdjustmentState(notStartedPrefix + "Started"));
    Test.assertEqual(true, delegate.canOpenScoreDialogForState(runningPrefix + "ning"));
    Test.assertEqual(true, delegate.canOpenCardDialogForState(pausedPrefix + "used"));
    Test.assertEqual(true, delegate.canOpenScoreDialogForState(halfPrefix + "Ended"));
    return true;
}

(:test)
function testMatchEndedBlocksScoreDialog(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);

    model.startMatch(0);
    model.endMatch(1000);
    var snap = model.snapshot(1000);

    Test.assertEqual(RUGBY_STATE_MATCH_ENDED, snap["clockState"]);
    Test.assertEqual(false, delegate.isIdleTimerAdjustmentState(snap["clockState"]));
    Test.assertEqual(false, delegate.canOpenScoreDialogForState(snap["clockState"]));
    Test.assertEqual(true, delegate.canOpenMatchOptionsForState(snap["clockState"]));
    return true;
}

(:test)
function testActiveMatchScoreDialogStates(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);

    Test.assertEqual(true, delegate.canOpenScoreDialogForState(RUGBY_STATE_RUNNING));
    Test.assertEqual(true, delegate.canOpenScoreDialogForState(RUGBY_STATE_PAUSED));
    Test.assertEqual(true, delegate.canOpenScoreDialogForState(RUGBY_STATE_HALF_ENDED));
    Test.assertEqual(false, delegate.canOpenScoreDialogForState(RUGBY_STATE_NOT_STARTED));
    Test.assertEqual(false, delegate.canOpenScoreDialogForState(RUGBY_STATE_MATCH_ENDED));
    return true;
}

(:test)
function testActiveMatchCardDialogStates(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);

    Test.assertEqual(true, delegate.canOpenCardDialogForState(RUGBY_STATE_RUNNING));
    Test.assertEqual(true, delegate.canOpenCardDialogForState(RUGBY_STATE_PAUSED));
    Test.assertEqual(true, delegate.canOpenCardDialogForState(RUGBY_STATE_HALF_ENDED));
    Test.assertEqual(false, delegate.canOpenCardDialogForState(RUGBY_STATE_NOT_STARTED));
    Test.assertEqual(false, delegate.canOpenCardDialogForState(RUGBY_STATE_MATCH_ENDED));
    return true;
}

(:test)
function testVariantSelectionOnlyAvailableBeforeMatch(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);
    var snap = model.snapshot(0);

    Test.assertEqual(true, delegate.canOpenVariantMenuForState(snap["clockState"]));

    model.startMatch(0);
    snap = model.snapshot(1000);
    Test.assertEqual(false, delegate.canOpenVariantMenuForState(snap["clockState"]));

    model.pause(1000);
    snap = model.snapshot(2000);
    Test.assertEqual(false, delegate.canOpenVariantMenuForState(snap["clockState"]));

    model.endMatch(3000);
    snap = model.snapshot(3000);
    Test.assertEqual(false, delegate.canOpenVariantMenuForState(snap["clockState"]));
    return true;
}

(:test)
function testSetVariantAppliesBuiltInDefaultsBeforeMatch(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);

    model.adjustIdleMainTimer(-5);
    delegate.setVariant(RUGBY_VARIANT_SEVENS);
    var snap = model.snapshot(0);

    Test.assertEqual(RUGBY_VARIANT_SEVENS, snap["variantId"]);
    Test.assertEqual("7's", snap["variantName"]);
    Test.assertEqual(7 * 60, snap["mainCountdownSeconds"]);
    return true;
}

(:test)
function testSetVariantIgnoredAfterMatchStart(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);

    delegate.setVariant(RUGBY_VARIANT_SEVENS);
    model.startMatch(0);
    delegate.setVariant(RUGBY_VARIANT_TENS);
    var snap = model.snapshot(1000);

    Test.assertEqual(RUGBY_VARIANT_SEVENS, snap["variantId"]);
    Test.assertEqual("7's", snap["variantName"]);
    return true;
}

(:test)
function testBackOptionsAvailableForActiveAndEndedMatch(logger) {
    var model = newIdleTimerControlsModel();
    var delegate = newIdleTimerControlsDelegate(model);

    Test.assertEqual(false, delegate.canOpenMatchOptionsForState(RUGBY_STATE_NOT_STARTED));
    Test.assertEqual(true, delegate.canOpenMatchOptionsForState(RUGBY_STATE_RUNNING));
    Test.assertEqual(true, delegate.canOpenMatchOptionsForState(RUGBY_STATE_PAUSED));
    Test.assertEqual(true, delegate.canOpenMatchOptionsForState(RUGBY_STATE_HALF_ENDED));
    Test.assertEqual(true, delegate.canOpenMatchOptionsForState(RUGBY_STATE_MATCH_ENDED));
    return true;
}

(:test)
function testNormalBackExitOnlyBeforeAndAfterMatch(logger) {
    var delegate = newIdleTimerControlsDelegate(newIdleTimerControlsModel());
    Test.assertEqual(true, delegate.allowsSystemExitForState(RUGBY_STATE_NOT_STARTED));
    Test.assertEqual(false, delegate.allowsSystemExitForState(RUGBY_STATE_RUNNING));
    Test.assertEqual(false, delegate.allowsSystemExitForState(RUGBY_STATE_PAUSED));
    Test.assertEqual(false, delegate.allowsSystemExitForState(RUGBY_STATE_HALF_ENDED));
    Test.assertEqual(true, delegate.allowsSystemExitForState(RUGBY_STATE_MATCH_ENDED));
    return true;
}

(:test)
function testConfirmResetMatchClearsStateAndDiscardsRecorder(logger) {
    var model = newIdleTimerControlsModel();
    var recorder = new IdleTimerControlsTestRecorder();
    var delegate = new RugbyTimerDelegate(model, recorder);

    model.startMatch(0);
    model.recordTry(RUGBY_TEAM_HOME, 10000);
    model.requestResetMatch();

    Test.assertEqual(true, delegate.selectAction());
    var snap = model.snapshot(10000);
    Test.assertEqual(RUGBY_STATE_NOT_STARTED, snap["clockState"]);
    Test.assertEqual(0, snap["home"]["score"]);
    Test.assertEqual(0, model.eventLog().size());
    Test.assertEqual(true, recorder._discarded);
    return true;
}
