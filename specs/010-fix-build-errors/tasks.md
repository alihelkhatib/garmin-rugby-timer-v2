# Tasks: Fix Build & Resource Errors

T001: Fix RugbyEventLog API
- Change array `push` to `add`.
- Implement snapshot using a while-loop and `add`.
- Update serialize to use `Json.toString`.

T002: Simplify RugbyActivityExporter
- Prefer `_session.addEvent(...)` for attaching events.
- Remove fallback branches that reference unsupported session methods.
- Rename runtime instance to `gRugbyActivityExporter`.

T003: Simplify RugbyActivityRecorder
- Remove `appendRecords`, `addComment`, `addMarker` branches; prefer `addEvent`.
- Ensure `_startExportRetries`/_onExportRetryTimer uses addEvent on retries.
- Remove `import Toybox.Json;` if causing validation warnings.

T004: Fix BackButtonSummaryPrototype imports
- Add required imports: `Toybox.System`, `Toybox.WatchUi`, `Toybox.Lang`.
- Ensure function return types/Dictionary usages resolve.

T005: Validation & local build
- Run `./scripts/run_simulator.sh` locally (requires SDK) or `monkeyc -f monkey.jungle -o build/rugby.iq`.
- Iterate on any remaining warnings/errors.

T006: CI / PR
- Open a PR with changes; add CI step to run `monkeyc` when SDK available in CI.

Notes: Keep changes minimal and low-risk; escalate to constitution check if UX/behavioral changes are required.
