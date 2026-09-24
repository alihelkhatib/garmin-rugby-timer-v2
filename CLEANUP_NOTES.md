# Cleanup Notes

## 2026-09-19 — Baseline audit

### Baseline state

- Worktree started clean on `main` at `bf5302e`.
- Connect IQ SDK 8.3.0 is available locally; repository documentation incorrectly says the CLI is unavailable.
- A temporary RSA signing key outside the repository was generated solely for local validation.
- Untouched builds for `fenix6` and `venu3` both fail in `resources/layouts/match_summary_layout.xml` because it is not valid Connect IQ resource XML.
- `venu3` additionally warns that the 40x40 launcher icon must be scaled to 70x70.

### Significant problems found so far

- `manifest.xml` declares two separate permission blocks with duplicate permissions.
- `main` appears to contain a partial feature merge. Unmerged branches contain later build-fix attempts and additional features; these are being treated as historical evidence rather than merged wholesale.
- Production source contains extensive unconditional debug logging and broad exception swallowing.
- The main view performs an authoritative automatic match-end side effect during rendering, coupling state transitions, activity save, and navigation to redraw timing.
- View-owned refresh and reminder timers have no complete visible lifecycle cleanup in the inspected implementation.
- Match snapshots mutate authoritative state, so a nominal read can trigger period transitions, timer expiry, and haptic bookkeeping.
- Variant preference persistence is documented and invoked but implemented as a no-op. Active-match restoration is absent.
- Event correction updates score counters but does not reconcile the event log.
- Multiple obvious experiments or duplicate implementations exist, including `BackButtonSummaryPrototype.mc`, `RugbyEventLog.mc`, `RugbySummaryView.mc`, and placeholder test files.
- `monkey.jungle` does not declare a test source path, while test documentation claims the tests run during startup.
- Several tests are comments, placeholders, or smoke stubs rather than executable assertions.
- The summary resource that blocks all builds is not used by the hand-drawn production summary view.

### Decisions

- Preserve established match variants, scoring, card behavior, wall-clock conversion countdown, active-match yellow-card timing, in-app event review, and best-effort activity recording unless deeper evidence contradicts them.
- Do not merge historical feature branches wholesale. Recover only changes that are validated against the current rehabilitation spec.
- Keep authoritative elapsed-time calculation timestamp-based; callbacks only trigger evaluation and redraw.
- Determine active-match persistence after validating lifecycle/storage cost and existing product intent. If omitted, document the limitation explicitly.

### Validation performed

- Repository inventory, Git history/branch comparison, toolchain discovery, manifest/resource inspection, and initial state/view/delegate review.
- Baseline build commands:
  - `monkeyc -f monkey.jungle -d fenix6 -o <temp>/rugby-fenix6.prg -y <temp-key> -w -l 1` — failed on invalid summary layout.
  - `monkeyc -f monkey.jungle -d venu3 -o <temp>/rugby-venu3.prg -y <temp-key> -w -l 1` — failed on the same layout and warned about icon scaling.

### Remaining work

- Complete source, resource, test, documentation, and historical-intent audit.
- Produce the prioritized implementation plan and tasks.
- Repair build foundations, state/timing architecture, lifecycle, input, UI/resources, recording, tests, and documentation.
- Run representative builds/tests, inspect the final diff, and perform a second audit.

## 2026-09-19 — Rehabilitation result

### Architecture and correctness

- Separated explicit time-driven mutation (`advance`) from snapshot rendering and moved automatic save/navigation side effects into `RugbyMatchController`.
- Added guarded timestamp math, cumulative match-relative event time, explicit invalid-state rejection, conversion-team validation, corrected-event status, and one authoritative recovery payload.
- Added preference and active-match storage. A running checkpoint restores paused; terminal reset clears recovery.
- Replaced unsupported ActivityRecording calls with the supported idempotent start/stop/save/discard lifecycle and an explicit in-app-summary fallback.
- Completed view timer cleanup and removed overlapping raw-key routing that could execute one input twice.

### Repository and UI

- Removed the invalid summary layout, duplicate/prototype models and views, superseded scoring/card menu implementations, non-executable test stubs, temporary files, and verified-unused graphics.
- Consolidated static UI text into resources, retained confirmation for destructive actions, and changed the bounded summary to display the latest events.
- Reduced the manifest to the build-validated `fenix6`, `fenix7`, and `instinct2` profiles, removed duplicate/excess permissions, and added an Instinct-specific launcher asset.
- Retained API 3.4.0 as the Fēnix 6-compatible floor after an API 4.1.6 manifest check correctly failed for that device.

### Tests and validation

- Wired a separate Toybox.Test application and replaced comment-only checks with executable assertions.
- Added timer-helper, controller, persistence/recovery, invalid-transition, delayed-callback, period-boundary, scoring, sanction, input-gate, recorder, and cumulative-event-time coverage.
- Final warning/type-check/build-stat validation passed for `fenix6`, `fenix7`, and `instinct2`; production builds emitted no warnings. Final PRG sizes were 173,852, 169,772, and 173,244 bytes respectively.
- The final Fēnix 6 simulator run passed all 64 executable tests with zero failures or errors.
- Visual simulator review passed on Fēnix 6 and exposed an Instinct 2 inset collision. A dedicated Instinct layout, monochrome-safe labels, and row-aligned card markers were added; the rebuilt Instinct main screen then passed visual review.

### Remaining limitations

- At that stage, detailed event export had not been implemented through ActivityRecording; this limitation is superseded by the 2026-09-24 FIT contributor implementation below.
- A restored conversion preserves its last checkpointed remaining time instead of guessing downtime.
- Physical-watch haptics, sleep/wake behavior, FIT inspection, battery impact, and full-length drift remain release-gate checks.

## 2026-09-22 — UI, exit, GPS, and mileage follow-up

### Problems found and corrected

- Back was consumed before kickoff and routed completed matches back into options, so Garmin's normal app exit was not reliably available. Back now exits normally in pre-match/completed states; active matches expose a labelled `Exit & save` action.
- Manual period completion and correction APIs existed without usable UI routes. Match options now expose `End period` and `Undo last event`; undo reverses the latest active score or sanction and marks its event corrected.
- Reset left the recorder in a terminal discarded state, preventing a second match in the same app process from creating a FIT session. Reset now re-arms the recorder after discard.
- Activity recording did not explicitly enable GPS. The recorder now enables continuous positioning and relies on Garmin ActivityRecording for the FIT route and elapsed distance delivered to Garmin Connect; these metrics are intentionally absent from the match UI.
- Active exit now saves the current FIT segment before shutdown and restores the match safely. Resume starts a new segment because a recording session cannot span process termination.
- The summary now adapts its visible row count to screen height and uses monochrome-safe event colors on Instinct. A briefly added on-watch mileage footer was removed after the user clarified that mileage belongs only in the Garmin Connect activity.

### Validation evidence

- Warning/type-check/build-stat application builds and test builds pass for `fenix6`, `fenix7`, and `instinct2` with no compiler warnings. Final PRG sizes are 180,396, 175,820, and 179,788 bytes respectively.
- The Fēnix 6 simulator passed all 68 executable tests: 68 passed, 0 failed, 0 errors.
- Fēnix 6 runtime smoke testing verified kickoff, live timestamp advancement, active-match Back navigation, End period, the full Match options menu, labelled `Exit & save`, actual process exit, and paused recovery after relaunch. Follow-up screenshot review verifies the normal match UI remains free of GPS/mileage text.
- GPS-unavailable simulator behavior is non-fatal. A physical supported watch is still required to validate satellite lock, route geometry, actual accumulated distance, FIT inspection, battery impact, and multi-segment recovery under outdoor movement.

## 2026-09-24 — Terminal stop-and-exit follow-up

- Added a separate confirmed `Stop & exit` action. Unlike recoverable `Exit & save`, it ends the match, stops and saves the FIT activity, clears active recovery, and closes the app.
- Added deterministic model coverage for the terminal confirmation state; the executable suite now contains 69 passing tests.
- Shortened the confirmation prompt to `SELECT: STOP` after simulator review found the longer wording clipped on a round display. The menu item retains the full `Stop & exit` wording.
- Fēnix 6 simulator validation confirmed the terminal process exit and a clean pre-match relaunch with no completed-match recovery.

## 2026-09-24 — Heart-rate and rugby FIT event export

- Added Garmin heart-rate sensor enable/disable around each ActivityRecording session. Available HR samples are recorded by Garmin into the saved FIT activity and remain absent from the live match UI.
- Added lap-scoped FIT developer fields for a readable rugby event label, match time, period, home score, and away score. Each score/card creates one event lap; correcting an exported event creates one additional `Undo ...` lap. Restored historical events are primed so a resumed FIT segment does not repeat them.
- Garmin Connect does not have native rugby score/card event semantics. Event visibility therefore depends on Connect IQ developer-field support in the chosen Garmin Connect client or FIT viewer; the in-app summary remains authoritative.
- Warning/type-check/build-stat application and test builds pass for `fenix6`, `fenix7`, and `instinct2`. The executable simulator suite passes 75 tests, including a real ActivityRecording session that creates developer fields, writes an event lap, and saves successfully; physical-watch verification of optical HR samples and Garmin Connect event-field rendering remains required.

## 2026-09-24 — Physical FIT metadata and GPS diagnosis

- Decoded `2026-09-24-15-24-55.fit` from the connected Fēnix 6. It contained `sport=generic`, `sub_sport=match`, five record messages over 20.683 seconds, zero native latitude/longitude samples, zero heart-rate samples, and `0.0 m` distance. Garmin Connect therefore had neither rugby metadata nor route data from which to render a map/heatmap.
- Confirmed that `Activity.SPORT_RUGBY` was introduced at API 4.1.6 while the Fēnix 6 compatibility runtime predates that symbol. A raw FIT rugby ID produced a CRC-valid local file but is not a safe legacy synchronization contract. The final compatibility path uses the supported soccer/match metadata with the `Rugby Match` name on Fēnix 6, and native rugby where the runtime exposes it.
- Added a compact pre-match GPS readiness label while preserving non-blocking indoor use and keeping mileage off the match UI. An outdoor recording started after `GPS READY` is still required to verify native position records and Garmin Connect rendering on the physical watch.
- Decoded the later physical file `2026-09-24-15-43-28.fit`: CRC valid, 151.091 seconds, native rugby/match metadata, 28 record messages, six heart-rate samples (average 79, maximum 84), and readable try/conversion/yellow-card developer fields. It had zero position records and `0.0 m`, so there was no route Garmin Connect could render. This proves the app saved; synchronization and GPS acquisition were the remaining failures to isolate.
- Decoded FC Timer reference activities from the same watch. They use supported soccer/generic metadata and contain thousands of native position and heart-rate records. This evidence drove the Fēnix 6 soccer/match compatibility fallback rather than an unsupported raw rugby enum.
- Yellow cards now produce a one-shot double-pulse warning at 60 seconds and a stronger triple-pulse expiration alert. They intentionally use active match time; adding a card pauses the match, so the referee must resume before its countdown advances.
- All 78 executable tests pass on Fēnix 6, Fēnix 7, and Instinct 2; warning/type-check/build-stat application and test builds pass across all three targets. The Fēnix 6 compatibility PRG was deployed over `G4IF1404.PRG` and SHA-256 verified as `A0B72CC97297140947D345BB49B8AA097A1D2E80012259F98217A6D57E5E5A4E`. Outdoor GPS acquisition plus post-USB Garmin Connect Mobile synchronization still require a physical rerun.

## 2026-09-24 — Compatibility rerun and timer feedback

- Decoded the post-deployment physical file `2026-09-24-16-27-54.fit`. Its CRC is valid and it correctly reports `sport=soccer`, `sub_sport=match`, and `sport_profile_name=Rugby Match`; try, conversion, and yellow-card developer fields are present. This proves the Fēnix 6 compatibility metadata and local save path.
- The compatibility rerun lasted 28.479 seconds and contained seven record messages but zero GPS positions, zero heart-rate samples, and `0.0 m`. It cannot validate route, distance, heart-rate capture, or Garmin Connect map rendering; the next physical run must be outdoors after `GPS READY` and long enough for native samples.
- Garmin Connect subsequently displayed both a Rugby and a Soccer/Football activity. FIT inspection proves these were two queued sessions rather than one completion saving twice: the earlier native-rugby test ran from 15:43:28 to 15:45:59, while the later soccer-compatibility test ran from 16:27:54 to 16:28:23. Their joint appearance confirms successful Garmin Connect synchronization of the compatibility activity; neither contains position samples, so map validation remains open.
- Added one short haptic confirmation for each accepted paused-to-running transition. Match completion now restores the selected period countdown and clears conversion/card timer projections while retaining the final score and event log for summary/FIT output.
- All 80 tests pass on Fēnix 6, Fēnix 7, and Instinct 2, and warning/type-check/build-stat production builds pass for all three. The updated Fēnix 6 PRG was deployed over the installed app and SHA-256 verified as `EEBB91E1371703DE7F4C97C7F39DE1EE90E58F195435C90189D6D4D91A822BB9`.
