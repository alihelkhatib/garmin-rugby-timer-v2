# Activity Type Mapping

Purpose
- Document the preferred Activity type used when exporting the rugby match via ActivityRecording and the per-device fallback mapping when Activity.SPORT_RUGBY is not available.

Recommendation
- Prefer: Activity.SPORT_RUGBY when available.
- Fallback: Activity.SPORT_OTHER (or closest available activity constant) when SPORT_RUGBY is not present on a device.

Per-device Validation
- Phase 0 research must confirm whether Activity.SPORT_RUGBY exists on each target device. If absent, record the exact fallback used (e.g., Activity.SPORT_OTHER) in `plan.md`.

Example (pseudocode)

if (Activity has :SPORT_RUGBY) {
    sport = Activity.SPORT_RUGBY;
} else {
    sport = Activity.SPORT_OTHER; // documented fallback
}

Next steps
- Run `research-activityrecording` to confirm constants on sample devices and update this doc with device-specific notes.
