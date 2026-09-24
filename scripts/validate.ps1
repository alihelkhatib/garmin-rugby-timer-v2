param(
    [Parameter(Mandatory = $true)]
    [string]$DeveloperKey,
    [string[]]$Devices = @("fenix6", "fenix7", "instinct2"),
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$outputDirectory = Join-Path $projectRoot "build"

if (-not (Test-Path -LiteralPath $DeveloperKey -PathType Leaf)) {
    throw "Developer key not found: $DeveloperKey"
}

New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

Push-Location $projectRoot
try {
    foreach ($device in $Devices) {
        $appOutput = Join-Path $outputDirectory "rugby-$device.prg"
        & monkeyc -f monkey.jungle -d $device -o $appOutput -y $DeveloperKey -w -l 1 --build-stats 0
        if ($LASTEXITCODE -ne 0) {
            throw "Application build failed for $device (exit $LASTEXITCODE)."
        }

        if (-not $SkipTests) {
            $testOutput = Join-Path $outputDirectory "rugby-tests-$device.prg"
            # Test assertions intentionally use dynamic dictionaries; level 0 avoids
            # non-actionable container-inference noise while production stays at level 1.
            & monkeyc -f tests/monkey.jungle -d $device -o $testOutput -y $DeveloperKey -w -l 0 -t
            if ($LASTEXITCODE -ne 0) {
                throw "Unit-test build failed for $device (exit $LASTEXITCODE)."
            }
        }
    }

    $forbiddenFiles = git ls-files | Select-String -Pattern '(\.prg$|\.iq$|developer_key\.(der|pem)$|\.bak$)'
    if ($forbiddenFiles) {
        throw "Tracked generated or secret files detected: $($forbiddenFiles -join ', ')"
    }

    $placeholders = rg -n -i 'TODO|FIXME|placeholder|prototype|test stub' source tests
    if ($LASTEXITCODE -eq 0) {
        throw "Placeholder or prototype markers remain:`n$placeholders"
    }
} finally {
    Pop-Location
}
