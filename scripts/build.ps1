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

foreach ($v in $versions) {
  $installDir = "C:\Program Files\Autodesk\Revit $v"
  if (-not (Test-Path $installDir)) {
    Write-Warning "Skipping Revit $v: $installDir not found."
    continue
  }

  Write-Host "Building Revit $v ($Configuration)..." -ForegroundColor Cyan
  dotnet build $project -c $Configuration -p:RevitVersion=$v
}
