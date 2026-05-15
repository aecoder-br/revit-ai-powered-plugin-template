param(
  [ValidateSet('2024','2025','2026','2027','all')]
  [string]$RevitVersion = 'all',
  [ValidateSet('Debug','Release')]
  [string]$Configuration = 'Debug'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$project = Join-Path $root 'src/RevitAiTemplate.Revit/RevitAiTemplate.Revit.csproj'
$versions = if ($RevitVersion -eq 'all') { @('2024','2025','2026','2027') } else { @($RevitVersion) }
$results = @()

foreach ($v in $versions) {
  $installDir = "C:\Program Files\Autodesk\Revit $v"
  if (-not (Test-Path $installDir)) {
    $reason = "$installDir not found."
    Write-Warning "Skipping Revit ${v}: $reason"
    $results += [pscustomobject]@{
      Version = $v
      Status = 'Skipped'
      Reason = $reason
    }
    continue
  }

  Write-Host "Building Revit $v ($Configuration)..." -ForegroundColor Cyan
  $reason = ''
  $exitCode = 0

  try {
    & dotnet build $project -c $Configuration -p:RevitVersion=$v
    $exitCode = $LASTEXITCODE
  } catch {
    $exitCode = 1
    $reason = $_.Exception.Message
  }

  if ($exitCode -eq 0) {
    $results += [pscustomobject]@{
      Version = $v
      Status = 'Passed'
      Reason = ''
    }
    continue
  }

  if ([string]::IsNullOrWhiteSpace($reason)) {
    $reason = "dotnet build failed with exit code $exitCode."
  }

  Write-Host "Revit $v build failed: $reason" -ForegroundColor Red
  $results += [pscustomobject]@{
    Version = $v
    Status = 'Failed'
    Reason = $reason
  }
}

Write-Host ''
Write-Host 'Revit build summary:' -ForegroundColor Cyan
$results | Format-Table Version,Status,Reason -AutoSize

$failed = @($results | Where-Object { $_.Status -eq 'Failed' })
if ($failed.Count -gt 0) {
  throw "$($failed.Count) Revit build(s) failed."
}
