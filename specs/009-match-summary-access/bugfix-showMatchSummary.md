# Bug Report & Repro: Match Summary select does not open view

Observed (from runtime logs provided by the user):

RUGBY|RugbyTimerDelegate|showMatchSummary eventCount=1
RUGBY|MatchOptionDelegate|onSelect itemId=symbol (292)
RUGBY|RugbyTimerDelegate|showMatchSummary eventCount=1
RUGBY|MatchOptionDelegate|onSelect itemId=symbol (292)
RUGBY|RugbyTimerDelegate|showMatchSummary eventCount=1

Problem

- Selecting the "Match Summary" option from the Match Options / End menu appears to call RugbyTimerDelegate.showMatchSummary (the delegate logs `showMatchSummary eventCount=...`) but the summary view does not appear on-screen.

Reproduction Steps

1. Start or load a match with some recorded events.
2. Open the Match Options menu (Back or Menu path depending on device/profile).
3. Select the Match Summary option.
4. Observe logs and UI. Expected: RugbyMatchSummaryView is pushed and visible. Actual: delegate logs appear but no view shown.

Investigation checklist

- Ensure `MatchOptionDelegate.onSelect` calls `_timerDelegate.showMatchSummary()` (it does per code). Confirm `_timerDelegate.showMatchSummary()` calls WatchUi.pushView and that code path completes.
- Add diagnostic trace immediately before and after `WatchUi.pushView(...)` in RugbyTimerDelegate.showMatchSummary() to confirm the push call was attempted and whether an exception occurred.
- Verify RugbyMatchSummaryView constructor/initialize does not throw or fail to render due to missing resources (invalid layout ids, Rez lookup failures). Add System.println traces in its initialize() and onLayout() paths.
- Check for resource validation errors (rez layout issues) that could prevent the view from being created — refer to earlier simulator Rez errors.

Acceptance Criteria / Fix Tests

- AC-1: Selecting Match Summary from Match Options logs `showMatchSummary push_attempt snapshotId=<id>` and then `showMatchSummary push_success snapshotId=<id>` (or equivalent), and RugbyMatchSummaryView.initialize prints its initialize trace.
- AC-2: Integration test `tests/integration/match_summary_open_test.mc` reproduces the menu selection and asserts System.println output contains `showMatchSummary push_success` and `RugbyMatchSummaryView|initialize` traces.

Suggested Fix Tasks (to add to spec 009 tasks.md)

- Task 1: Add pre/post push diagnostic traces in RugbyTimerDelegate.showMatchSummary and in RugbyMatchSummaryView.initialize/onLayout.
- Task 2: Run local simulator (monkeyc) and verify whether WatchUi.pushView fails due to resource validation or an exception; capture complete stack/diagnostic logs.
- Task 3: If resource/layout validation errors found, fix resource XML for rugby match summary layouts (layout ids, allowed child elements) and re-run simulator validation.
- Task 4: Add integration test asserting pushView sequence and view initialization traces.

Notes

- This addendum is intentionally prescriptive and small: it defines the immediate diagnostic + test approach to confirm whether the issue is a UI push failure or a resource/layout exception preventing view rendering.
- If the issue proves to be a missing binding in the delegate or incorrect WatchUi API usage, update specs/009-match-summary-access/tasks.md with a code fix task instead of large spec changes.
