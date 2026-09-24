# Release and Rollback

## Release gate

1. Confirm `git status` contains only intended changes and no signing key or generated package.
2. Run the full unit-test PRG and retain the passing summary.
3. Run `scripts/validate.ps1` for every manifest product and review build stats.
4. Complete simulator screenshots and the physical-device checks in `docs/testing.md`.
5. Verify permissions remain least-privilege, no network/telemetry was added, and the MIT license covers shipped source/assets.
6. Review Garmin Connect IQ store policy, product compatibility, listing text, icon, privacy disclosure, and release signing identity.
7. Tag the reviewed commit and build the store package with the maintainer's protected production key.

## Rollback

Retain the last accepted tag and signed store package. For a critical timing, crash, or data-integrity incident, stop rollout, document affected versions/devices, restore the last accepted release where the store permits, and prepare a narrowly scoped signed hotfix. Record reproduction, severity, root cause, test gap, and preventive action before the next release.

## Dependency inventory

The runtime dependency inventory is the Garmin Connect IQ platform/Toybox API only; there are no third-party libraries or services. SDK upgrades require release-note, license, API-compatibility, build-stat, simulator, and physical-device review.

## Incident reporting

Use the repository issue tracker. Incorrect match time/result, repeated save/reset, crash during a match, or lost recovery data is critical. UI clipping and nonessential haptic differences are normal priority unless they prevent safe match operation. The repository maintainer owns triage and release sign-off.
