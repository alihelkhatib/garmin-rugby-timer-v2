# Quickstart: Validating Match Summary on Simulator

Prerequisites
- Install Garmin Connect IQ SDK and ensure `monkeyc` and `monkeydo` are on PATH.

Steps
1. Build the app for a target device profile (e.g., fenix 6 simulator):
   ```sh
   monkeyc -f monkey.jungle -o build/app.prg
   ```
2. Install/run on simulator and exercise a sample match with scripted events (see `tests/` for example scripts).
3. Trigger match-end flow and confirm ActivityRecording export is created.
4. Pull the generated FIT file and inspect for raw chronological events; verify event count and schema.

Notes
- If Connect IQ tools are not available, document observed behavior in `research.md` and use manual inspection steps.

Deliverable
- A short checklist that verifies SC-001..SC-007 on at least two device profiles.
