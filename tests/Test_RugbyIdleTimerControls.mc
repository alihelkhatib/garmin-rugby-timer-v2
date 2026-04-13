/*
Test: tests/Test_RugbyIdleTimerControls.mc

What this test file covers:
- Verifies idle physical-button routing for timer adjustment and active-match score/card dialog availability gates.

How to run locally:
- See docs/testing.md for SDK/CLI commands. Tests run at app startup via Toybox.Test.

Key assertions/behaviours:
- Idle Up/Menu-style adjustment increments by one minute and remains score-dialog blocked.
- Idle Down-style adjustment decrements by one minute and remains score-dialog blocked.
- Score dialogs are allowed only while running, paused, or half-ended.
- Card dialogs remain allowed for the same active match states.

Preconditions / setup:
- Tests exercise the delegate's state-gate helpers and the model-backed idle timer adjustment path.
*/

using Toybox.Test;

class IdleTimerControlsTestRecorder {
    var _started;
    var _saved;

    function initialize() {
        _started = false;
        _saved = false;
    }

    function start() {
        _started = true;
    }

    function stopAndSave() {
        _saved = true;
    }
}

function newIdleTimerControlsModel() {
    return new RugbyGameModel(RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS));
}

function newIdleTimerControlsDelegate(model) {
    return new RugbyTimerDelegate(model, new IdleTimerControlsTestRecorder());
}

(:test)
function testIdleUpMenuIncrementsTimerAndBlocksScoreDialog(logger) {
    var model = newIdleTimerControlsModel();
    model.adjustIdleMainTimer(-1);
    var delegate = newIdleTimerControlsDelegate(model);

    var before = model.snapshot(0);
    Test.assertEqual(39 * 60, before["mainCountdownSeconds"]);
    Test.assertEqual(true, delegate.isIdleTimerAdjustmentState(before["clockState"]));
    Test.assertEqual(false, delegate.canOpenScoreDialogForState(before["clockState"]));

    Test.assertEqual(true, delegate.onMenu());
    var after = model.snapshot(0);
    Test.assertEqual(40 * 60, after["mainCountdownSeconds"]);
    Test.assertEqual(false, delegate.canOpenScoreDialogForState(after["clockState"]));
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
}
