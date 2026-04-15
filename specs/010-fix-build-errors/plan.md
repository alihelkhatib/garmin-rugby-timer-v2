# Implementation Plan: Fix Build & Resource Errors

Goal: Resolve compiler warnings and errors reported by the fenix6 simulator build (monkeyc), focusing on low-risk changes that restore a clean build and enable deterministic tests.

Technical decision summary
- Prefer the ActivityRecording session API method addEvent for attaching event entries; remove reliance on device-specific methods (appendRecords, addComment, addMarker) that are not universally present.
- Use the in-memory RugbyEventLog API (`add`/`snapshot`) and avoid array `push` calls which are not available in Monkey C arrays.
- Avoid importing Toybox.Json explicitly; use `Json.toString(...)` as the project previously did (minimize import noise and SDK mismatches).
- Rename runtime instance variables that shadow class names to avoid redefinition errors.

Phase 0 - Research
- Verify ActivityRecording session methods across representative SDK/device targets (fenix6 family). Action: consult Connect IQ docs (local) or SDK headers.

Phase 1 - Implementation (ordered tasks)
1. Fix RugbyEventLog (replace push->add, use loop-based snapshot)
2. Simplify RugbyActivityExporter to call addEvent and rename instance variable
3. Simplify RugbyActivityRecorder to prefer addEvent and remove unsupported method branches
4. Remove problematic Toybox.Json imports where they cause validation warnings
5. Fix BackButtonSummaryPrototype imports (resolve Boolean/Dictionary types)
6. Run local build and iterate on remaining warnings

Acceptance criteria
- `monkeyc -f monkey.jungle -o build/rugby.iq` completes without syntax or resource.xsd validation errors for fenix6 target.
- No `Undefined symbol ':push'` or `Redefinition` errors remain.
- Tests emit `TEST|...` traces in simulator.

Artifacts produced
- Updated source files: RugbyEventLog.mc, RugbyActivityExporter.mc, RugbyActivityRecorder.mc, BackButtonSummaryPrototype.mc
- Plan and tasks in `specs/010-fix-build-errors`.
