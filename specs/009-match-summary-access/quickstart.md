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

Reproducing non-blocking export + retry (T023)
- Build instrumented test that injects an ActivityRecording session which throws on save or addEvent, or run tests/impl_export_retry_test.mc which stubs the session.
- Run on simulator (fenix6 profile) with:
  monkeyc -f monkey.jungle -o build/app.prg && monkeydo run -d fenix6 build/app.prg --script tests/impl_export_retry_test.mc
- Expected: stopAndSave triggers immediate non-blocking save attempt, then scheduled retries with backoffs 2000/5000/10000 ms. Verify logs contain `RUGBY_DIAG|activity_export` entries and final status 'failed' after retries. Assert attempts == 3. Document expected log snippets in this quickstart.

