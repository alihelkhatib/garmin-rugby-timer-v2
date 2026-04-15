---
# Cross-cutting Feature: Diagnostics and Trace Format

## Purpose
Canonical, cross-cutting diagnostic requirement and trace schema used by multiple features. This document centralizes the normative diagnostic format, allowed/forbidden fields, example traces, and acceptance tests.

## Functional Requirement
- **FR-DIAG-001**: The system MUST provide a cross-cutting diagnostics API and trace format that feature implementations use for instrumentation. Diagnostics MUST:
  - Emit structured trace events via a shared Diagnostics helper (e.g., source/Diagnostics.mc) using a consistent schema.
  - Use non-PII keys only. Allowed top-level keys: action (String), priorState (String), result (String), timestamp (ISO8601 or monotonic), component (String), payload (Map). Any feature-specific payload must avoid PII and must be documented in the feature spec.
  - For transient device-only diagnostics, traces SHALL remain local to the device runtime and SHALL NOT be transmitted externally by default.
  - Provide a small inspector script or guidance to extract and summarize traces for debugging (patterns and example scripts described below).

## Trace schema (example)
{
  "action": "activity_export",
  "component": "RugbyActivityRecorder",
  "priorState": "match_ending",
  "result": "failed",
  "timestamp": "2026-04-14T12:34:56Z",
  "payload": {"status": "failed", "attempts": 3, "reason": "timeout"}
}

## Acceptance tests (cross-cutting)
- Diagnostics helper exists and is used by at least one feature.
- Cross-cutting tests validate the diagnostics schema keys are present and that no PII keys are included (a `tests/diagnostics_pii_test.mc` example).
- Each feature that needs traces documents feature-specific trace names and payload schema in its spec and references FR-DIAG-001.

## Usage guidance
- Feature specs reference FR-DIAG-001 for general diagnostics obligations and include feature-specific examples (e.g., activity_export payload) in the feature spec.
---
