# Research: UI Patterns for Match Summary

Goal
- Determine best-practice implementation for a scrollable match-summary view across small and large round devices.

Research Questions
- Can a scrollable list be expressed purely using resource XML on target devices? If not, what minimal draw operations are required?
- What is the recommended focus/scroll behavior for long lists (most-recent-first vs. scroll-to-top)?
- What font sizes and row heights are readable on small round devices (Forerunner/vivoactive) vs. large round (fenix)?

Actions
- Prototype resource XML list and a manual-draw list in the simulator for small and large device profiles.
- Record sample resource XML and fallback drawing approach in `resources/layouts/match_summary_layout.xml` and `research.md`.

Deliverable
- `specs/009-match-summary-access/research-ui.md` (this file).
