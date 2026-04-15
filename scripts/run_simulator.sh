#!/usr/bin/env bash
set -euo pipefail

# Helper: build this Connect IQ app and print simulator instructions.
# Requires Garmin Connect IQ SDK on PATH (monkeyc, monkeydo).

echo "Checking for monkeyc..."
if ! command -v monkeyc >/dev/null 2>&1; then
  echo "ERROR: monkeyc not found. Install the Connect IQ SDK: https://developer.garmin.com/connect-iq/"
  exit 2
fi

mkdir -p build
echo "Building with monkeyc (monkey.jungle)..."
monkeyc -f monkey.jungle -o build/rugby.iq

echo "Build complete: build/rugby.iq"

cat <<MSG

To run in the simulator:
  - Use the Connect IQ Simulator (monkeydo) or the Connect IQ IDE.
  - If you have monkeydo, try: monkeydo -a build/rugby.iq -d <device-profile>
    (run 'monkeydo --help' to learn device flags on your SDK version)
  - Or open the Connect IQ Simulator UI and load build/rugby.iq

To capture the test harness output, run the simulator and watch stdout for lines starting with 'TEST|'.
MSG
