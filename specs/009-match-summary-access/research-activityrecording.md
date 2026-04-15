# Research: ActivityRecording / FIT Export

Goal
- Verify Connect IQ ActivityRecording APIs and limits for exporting structured event data (raw chronological events).

Research Questions
- Does target Connect IQ SDK expose Activity.SPORT_RUGBY? Which devices support it?
- What is the maximum payload size and rate for ActivityRecording/FIT entries on representative devices?
- What FIT event constructs are supported (custom records, comment fields, lap markers)?
- What APIs are available for attaching structured event data to ActivityRecording?

Actions
- Inspect Connect IQ SDK docs for Activity and ActivityRecording APIs.
- Build and run a small sample on simulator: serialize a 90-minute match worth of events and attempt an ActivityRecording export.
- Measure resulting FIT size and note any truncation/warnings.
- Record exact API surface and sample code snippets in `research.md`.

Deliverable
- `specs/009-match-summary-access/research-activityrecording.md` (this file) plus findings appended to `specs/009-match-summary-access/research.md`.
