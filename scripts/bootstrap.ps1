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

$org = Join-Path $kit "library\cloud-engineering-org"
if (Test-Path (Join-Path $org "agents")) {
    Copy-Item -Recurse -Force (Join-Path $org "agents\*") (Join-Path $root "agents")
    $mem = Join-Path $root "agent-memory"
    if (Test-Path $mem) { Remove-Item -Recurse -Force $mem }
    Copy-Item -Recurse -Force (Join-Path $org "agent-memory") $mem
    Get-ChildItem (Join-Path $org "skills") -Directory -Filter "*.skill" | ForEach-Object {
        $name = $_.Name -replace '\.skill$', ''
        $dest = Join-Path $root "skills\$name"
        if (Test-Path $dest) {
            Write-Output "Kept kit skill $name"
        } else {
            Copy-Item -Recurse -Force $_.FullName $dest
        }
    }
    $needle = "./agent-memory/"
    $replacement = ($mem -replace '\\', '/') + "/"
    Get-ChildItem (Join-Path $root "agents") -Filter *.agent.md | ForEach-Object {
        $text = Get-Content $_.FullName -Raw
        if ($text -like "*$needle*") {
            Set-Content -Path $_.FullName -Value ($text.Replace($needle, $replacement)) -Encoding utf8 -NoNewline
        }
    }
    @(
        "# Cloud engineering org"
        ""
        "The cloud engineering agents in the user profile call each other by display name. Keep the whole set installed."
        "Their knowledge files are in ``$mem``."
        "If an agent says ``./agent-memory/``, read that path under the user profile, not the current repo."
        "Use the kit skill ``iac-review``. Do not look for a second skill with that name."
        "Archie is the default lead. Archie routes Microsoft cloud work and does work that has no specialist."
        "Some listed tools are VS Code or MCP only. Skip a tool that is not available."
        ""
    ) | Set-Content -Path (Join-Path $root "instructions\cloud-engineering-org.instructions.md") -Encoding utf8
    Write-Output "Installed cloud engineering org into $root"
}

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
