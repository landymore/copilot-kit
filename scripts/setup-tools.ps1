# Install or upgrade the dev tools for this kit. Safe to re-run.
# winget only. Does not sign in to GitHub or Azure.
$ErrorActionPreference = "Continue"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is not installed. Install App Installer from the Microsoft Store and re-run."
    exit 1
}

# Current stable IDs. Microsoft.DotNet.SDK.11 is the latest stable SDK major.
# No applicable upgrade from winget is exit code -1978335189.
$ids = @(
    "Git.Git",
    "GitHub.cli",
    "Microsoft.AzureCLI",
    "Microsoft.DotNet.SDK.11",
    "Microsoft.PowerShell",
    "Microsoft.Bicep",
    "OpenJS.NodeJS",
    "Hashicorp.Terraform",
    "Amazon.AWSCLI"
)

$failed = @()
$noUpgrade = -1978335189

foreach ($id in $ids) {
    winget list --id $id --exact --disable-interactivity | Out-Null
    if ($LASTEXITCODE -eq 0) {
        winget upgrade --id $id --exact --disable-interactivity --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $noUpgrade) {
            Write-Output "OK $id"
        } else {
            Write-Warning "FAILED upgrade $id ($LASTEXITCODE)"
            $failed += $id
        }
    } else {
        winget install --id $id --exact --disable-interactivity --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Output "OK $id"
        } else {
            Write-Warning "FAILED install $id ($LASTEXITCODE)"
            $failed += $id
        }
    }
}

Write-Output "Versions:"
foreach ($cmd in @("git", "gh", "az", "dotnet", "pwsh", "bicep", "node", "terraform", "aws")) {
    $found = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($found) {
        & $cmd --version 2>&1 | Select-Object -First 1
    } else {
        Write-Output "MISSING $cmd"
    }
}

if ($failed.Count -gt 0) {
    Write-Warning ("Tool setup failed for: " + ($failed -join ", "))
    exit 1
}
exit 0
