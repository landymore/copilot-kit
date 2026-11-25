# Copy this kit into the Copilot user profile. Safe to re-run.
# Run this from a checkout. Cloning belongs to the bootstrap-machine skill.
$ErrorActionPreference = "Stop"

$kit = Split-Path -Parent $PSScriptRoot
$root = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $env:USERPROFILE ".copilot" }

New-Item -ItemType Directory -Force -Path @(
    (Join-Path $root "skills"),
    (Join-Path $root "agents"),
    (Join-Path $root "instructions")
) | Out-Null

Copy-Item -Recurse -Force (Join-Path $kit ".github\skills\*") (Join-Path $root "skills")
Copy-Item -Recurse -Force (Join-Path $kit ".github\agents\*") (Join-Path $root "agents")
Copy-Item -Force (Join-Path $kit ".github\copilot-instructions.md") (Join-Path $root "copilot-instructions.md")
Copy-Item -Force (Join-Path $kit "AGENTS.md") (Join-Path $root "instructions\agents.instructions.md")

$settingsPath = Join-Path $root "settings.json"
$raw = if (Test-Path $settingsPath) { Get-Content $settingsPath -Raw } else { "{}" }
if ($raw -notmatch '"memory"\s*:\s*true') {
    if ($raw -match '"memory"\s*:\s*false') {
        $raw = $raw -replace '"memory"\s*:\s*false', '"memory": true'
    } elseif ($raw.Trim() -eq "" -or $raw.Trim() -eq "{}") {
        $raw = "{`r`n  `"memory`": true`r`n}"
    } else {
        $raw = $raw -replace '^\s*\{', "{`r`n  `"memory`": true,"
    }
    Set-Content -Path $settingsPath -Value $raw -Encoding utf8
    Write-Output "Enabled memory in $settingsPath"
} else {
    Write-Output "Memory already enabled in $settingsPath"
}

Write-Output "Installed Copilot profile from $kit"
Write-Output "User profile: $root"

$toolsRc = 0
& (Join-Path $PSScriptRoot "setup-tools.ps1")
if ($LASTEXITCODE -ne 0) { $toolsRc = $LASTEXITCODE }

$memRc = 0
$mem = Join-Path $kit "memories.jsonl"
if (Test-Path $mem) {
    copilot memories import --dry-run --on-conflict skip $mem
    if ($LASTEXITCODE -eq 0) {
        copilot memories import --on-conflict skip $mem
        if ($LASTEXITCODE -ne 0) { $memRc = $LASTEXITCODE }
    } else {
        Write-Warning "Memory dry run failed; skipped import."
        $memRc = 1
    }
} else {
    Write-Warning "No memories.jsonl at $mem"
    $memRc = 1
}

Write-Output "Open a new Copilot session, then run: copilot skill list"
if ($toolsRc -ne 0 -or $memRc -ne 0) { exit 1 }
exit 0
