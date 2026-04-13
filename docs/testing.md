# Testing

Prerequisites:
- Garmin Connect IQ SDK 4.1.6+ installed
- Ensure monkeyc and monkeydo (or connectiq CLI) are on your PATH

How to run tests locally (example):

1) Compile the app (produces a .prg package):
   monkeyc -f monkey.jungle -o build/garmin-rugby-timer.prg

2) Run the package in a simulator (example using monkeydo; replace device name as needed):
   monkeydo -s fenix6 build/garmin-rugby-timer.prg

Notes:
- The tests in tests/ use Toybox.Test and will run during app startup; test output appears in the simulator console/logs.
- If your SDK install exposes different CLI names (connectiq, monkeyc, monkeydo), adapt the commands accordingly.

Existing tests included in this repo:
- tests/Test_RugbyGameModel.mc — exercise RugbyGameModel: start/pause/resume, scoring, sanctions, conversion timers, snapshots
- tests/Test_RugbyVariantConfig.mc — verify built-in variant defaults and override helpers
- tests/Test_RugbyActivityRecorder.mc — basic recorder state and snapshot

Observed here (automation run):
- monkeyc was not found on PATH in this execution environment, so tests could not be executed.

Next steps:
- Install/configure the Connect IQ SDK so monkeyc/monkeydo are available, then run the compile + simulator commands above.
