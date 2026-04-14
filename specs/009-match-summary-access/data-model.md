# Data Model: Match Event

Event schema (canonical):

- type: String  -- e.g., "try", "penalty", "yellow_card", "substitution", "start", "end"
- timestamp: Integer -- monotonic match time in seconds or milliseconds (choose consistent unit per plan)
- actor: String? -- optional player/official identifier
- value: Number? -- optional numeric payload (e.g., points)
- details: String? -- optional human-readable details

Example JSON event:

{
  "type": "try",
  "timestamp": 3372,
  "actor": "#15",
  "value": 5,
  "details": "Converted from short-pass"
}

FIT Mapping Guidance
- Serialize each event as a custom event record or appropriate FIT message supported by ActivityRecording. If custom fields are not available, encode as a compact text blob with a simple schema (type|ts|actor|value|details) and document parsing in `data-model.md`.

Validation
- Include a small parser in tests to round-trip event -> FIT payload -> event and assert equality for representative event sets.
