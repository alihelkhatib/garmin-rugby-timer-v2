# Performance Validation

Purpose
- Validate performance budgets (binary size, memory, CPU/battery) and record results.

Targets (initial)
- Binary <= 200 KB
- Memory <= 128 KB
- Battery impact <= +5% for a 90-minute match

Validation steps
- Build and measure binary size for each target profile
- Run memory and CPU profiling on simulator during a scripted 90-minute match (accelerated clock)
- Record results and recommended optimizations

Results
- Use the table below to record measured values per device.

| device | build_bytes | peak_heap_bytes | avg_cpu_pct | passed |
|--------|------------:|----------------:|-----------:|:-----:|
| fenix6 | <int> | <int> | <float> | PASS/FAIL |

Measurement commands:
- Build: monkeyc -f monkey.jungle -o build/<artifact> -d <device_profile>
- Simulated perf run: ./scripts/run_simulator.sh --profile fenix6 --script tests/perf_check_fenix6.mc

Interpretation:
- Pass criteria: build_size_delta ≤ 200 KB; peak_heap_delta ≤ 128 KB; avg_cpu_overhead ≤ 5.0% (fenix family). Record actual numbers and recommended optimizations.

