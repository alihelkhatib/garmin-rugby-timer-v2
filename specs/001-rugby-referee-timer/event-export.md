# Decision: Use FIT lap/marker entries for per-event exports

Chosen option: A) Use FIT lap/marker entries (session markers) to record per-event timestamps and metadata.

Rationale
- FIT lap/marker entries are widely supported and are the most interoperable way to embed per-event timestamps into a single exported session file.
- Keeps events embedded with the session (no sidecar files by default) and simplifies downstream analysis and upload to Garmin Connect.

Event schema (marker/lap payload)
- event_type: try|conversion|penalty|drop_goal|yellow_card|red_card|substitution|stoppage_adjust
- team: home|away (when applicable)
- points_delta: integer (when applicable)
- sanction_id: optional numeric id (for card events)
- conversion_result: made|missed|n/a
- elapsed_ms: match elapsed milliseconds when event occurred
- recorded_at_ms: System.getTimer() timestamp when marker added

Implementation notes
- Use the ActivityRecording session marker/lap API where available (e.g., session.addMarker / session.addLap or equivalent Toybox API); if a target device does not support embedded markers, fall back to writing a small sidecar JSON file in app storage containing identical markers. GPS collection MUST be enabled by default for recordings (opt-out per recording): request and respect platform positioning permissions at recording start, provide a per-recording toggle and an application-level setting to disable GPS collection by default. On unsupported or denied permission states, still record event markers and metadata without GPS.
- Ensure marker creation is resilient: do not crash if ActivityRecording session is unavailable; record markers in-memory for later save if necessary.

Acceptance Criteria
- For every match event (scoring, card, substitution, stoppage adjustment) a FIT marker/lap or equivalent sidecar entry exists with the schema above.
- Tests verify marker presence and matching timestamps/metadata after session save on supported devices or via the fallback on unsupported devices.

References
- Related spec: specs/001-rugby-referee-timer/spec.md
- Implementation targets: source/RugbyActivityRecorder.mc, source/RugbyGameModel.mc, source/RugbyTimerDelegate.mc
