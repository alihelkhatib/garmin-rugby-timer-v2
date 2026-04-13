# Developer Guide

This guide helps a brand-new contributor get the project building, testing, and running in the Garmin Connect IQ simulator, and explains the project's Speckit workflow for making changes.

## Quick start

1. Install the Garmin Connect IQ SDK (recommended minimum: Connect IQ API 4.1.6).
2. Add the SDK 'bin' directory to your PATH (see Prerequisites).
3. From the project root run the build and simulator steps below.

---

## Prerequisites

- OS
  - macOS (recommended), Linux (Ubuntu 20.04+), or Windows 10/11.

- Connect IQ SDK
  - Install the Garmin Connect IQ SDK (Connect IQ API >= 4.1.6). Download from: https://developer.garmin.com/connect-iq/overview/
  - The SDK provides the command-line tools `monkeyc`, `monkeydo` (and older `connectiq`).

- Java
  - The Connect IQ toolchain requires a Java runtime. Install a supported JDK/JRE (Java 8/11+ is commonly compatible).

- Environment variables / PATH (example)
  - macOS / Linux (example):

    ```bash
    # adjust the path to match your SDK install location
    export CONNECTIQ_SDK="/path/to/connectiq/sdk"
    export PATH="$CONNECTIQ_SDK/bin:$PATH"
    ```

  - Windows (PowerShell, example):

    ```powershell
    setx CONNECTIQ_SDK "C:\path\to\connectiq\sdk"
    $env:Path += ";$env:CONNECTIQ_SDK\bin"
    ```

- Notes
  - During prior work the Connect IQ CLI commands were not on PATH in CI/dev machines; ensure your dev environment has `monkeyc` and `monkeydo` available. If you can't install the SDK, you can still read and edit code, but builds, simulator runs and tests require the SDK.

---

## Build steps

From the project root:

- Recommended (SDK on PATH):

  - Build using the CLI directly (example):

    ```bash
    # basic example - the exact flags you need may vary by SDK version
    monkeyc -f monkey.jungle -o build/rugby.prg
    ```

  - Use `monkeydo` to run higher-level tasks if available in your SDK:

    ```bash
    # example, replace <product-id> or profile as needed
    monkeydo build -f monkey.jungle
    ```

- Fallback (no CLI available locally):
  - Use the official Connect IQ IDE (Eclipse-based) to import the project and build there.
  - Or install the Connect IQ SDK on a machine or CI runner and follow the CLI examples above.

- Build outputs
  - The build produces .prg/.app files suitable for installation on a simulator or device. Check the `build/` or SDK-configured output folder.

---

## Running tests

- Tests live in `tests/` and are written using Toybox.Test (Monkey C unit tests).

- Locally (CLI)
  - If your SDK provides a test runner, invoke it from the project root. Example (SDK-dependent):

    ```bash
    # example: consult your SDK's `monkeyc --help` for the correct test flags
    monkeyc -f monkey.jungle -o build/tests -t tests
    ```

  - Expected output: a PASS/FAIL summary from the Toybox.Test runner, with failing assertions showing the test name and failed assertion.

- Locally (IDE)
  - Import the project into the Connect IQ IDE and run the test harness if the IDE supports it.

- CI
  - In CI, provision a runner with the Connect IQ SDK installed (or use a container that includes the SDK). Run the same `monkeyc` test command as in local development. Fail the job if tests output failures.

- If you cannot run the SDK in CI, include tests as a gated step or mark them as optional but require simulator/device validation in PR review.

---

## Running the simulator

- With the SDK installed you can launch installs against simulator profiles.

- Examples (SDK-dependent):

  ```bash
  # build the app
  monkeyc -f monkey.jungle -o build/rugby.prg

  # install/run in a simulator profile (replace <product-id> as needed)
  monkeydo install -p <product-id> build/rugby.prg
  monkeydo run -p <product-id>
  ```

- Alternative: Use the Connect IQ IDE's device/simulator manager to install and run the .prg on a simulated watch.

---

## Speckit workflow (specs, plan, tasks)

This project follows Spec Kit conventions. High-level flow for a new feature or change:

1. Create a new spec folder under `specs/` e.g. `specs/00X-my-feature/`.
2. Add or update `spec.md` describing the problem, goals, constraints, and acceptance criteria.
3. Create `plan.md` listing the chosen approach, key files to change, and important trade-offs.
4. Generate `tasks.md` — an actionable, dependency-ordered checklist of implementation steps. Each task should be executable by another contributor.
5. Work on a feature branch. Branch naming convention in this repo: `speckit/<short-description>` (or use the project's speckit tooling to create a branch).
6. Before coding, ensure `spec.md`, `plan.md`, and `tasks.md` are present and reviewed (this saves rework).
7. Implement changes, update the spec/plan/tasks as details change.
8. Commit logically-scoped changes with clear messages (see Code Review section). Push branch and open a PR.

Helpful tools (if available): the repository includes Spec Kit integrations that can help scaffold specs and convert tasks to issues. Use them when present.

Where to find existing specs:

- Root `specs/` directory. Example quickstart: `specs/001-rugby-referee-timer/quickstart.md` (start there for context).

---

## Code review and PR expectations

- Open a PR from your feature branch and include:
  - Link to the spec (`specs/…/spec.md`) or the quickstart that motivated the change.
  - Summary of what changed and why, screenshots or simulator logs if UI/behavior changes.
  - Test results (unit tests, simulator validation steps, or device test notes).

- Requirements before merge:
  - Passing automated checks (CI) where applicable.
  - At least one approving review from a maintainer or peer.
  - If the change affects device behavior (timing, haptics, FIT output), include simulator and device validation notes in the PR.

- Commit message style
  - Use clear, imperative messages like `speckit: add developer guide`.
  - When appropriate include a `Co-authored-by:` trailer for pair contributions.

---

## Troubleshooting & tips

- If `monkeyc`/`monkeydo` are missing, double-check your PATH and CONNECTIQ_SDK variable; relogin or restart your shell after modifying PATH.
- Use the Connect IQ IDE simulator for step-through testing and for devices that the CLI might not fully emulate.
- Preserve timing logic in the shared model (`source/`) — UI code should render state from the model, not duplicate timer logic.

---

If you need help getting your local SDK configured, note the platform and SDK install path when opening an issue or PR and a maintainer will help.
