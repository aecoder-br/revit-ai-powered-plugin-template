param(
  [Parameter(Mandatory=$true)]
  [ValidateSet('2024','2025','2026','2027')]
  [string]$RevitVersion,
  [ValidateSet('Debug','Release')]
  [string]$Configuration = 'Debug'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$project = Join-Path $root 'src/RevitAiTemplate.Revit/RevitAiTemplate.Revit.csproj'

& (Join-Path $root 'scripts/build.ps1') -RevitVersion $RevitVersion -Configuration $Configuration

$dll = Join-Path $root "artifacts/bin/RevitAiTemplate.Revit/$Configuration/net$($null)/RevitAiTemplate.Revit.dll"
# Resolve actual output path by searching. This avoids hardcoding net48/net8/net10.
$dll = Get-ChildItem -Path (Join-Path $root "artifacts/bin/RevitAiTemplate.Revit/$Configuration") -Recurse -Filter 'RevitAiTemplate.Revit.dll' |
  Where-Object { $_.FullName -like "*R$RevitVersion*" -or $_.FullName -like "*$RevitVersion*" } |
  Select-Object -First 1 -ExpandProperty FullName

if (-not $dll) {
  $dll = Get-ChildItem -Path (Join-Path $root "artifacts/bin/RevitAiTemplate.Revit") -Recurse -Filter 'RevitAiTemplate.Revit.dll' | Select-Object -First 1 -ExpandProperty FullName
}

if (-not $dll) {
  throw 'Could not locate built RevitAiTemplate.Revit.dll.'
}

$addinDir = Join-Path $env:APPDATA "Autodesk\Revit\Addins\$RevitVersion"
New-Item -ItemType Directory -Path $addinDir -Force | Out-Null
$addinPath = Join-Path $addinDir 'RevitAiTemplate.addin'

$addin = @"
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<RevitAddIns>
  <AddIn Type="Application">
    <Name>Revit AI Template</Name>
    <Assembly>$dll</Assembly>
    <AddInId>9E30E6C0-3DF3-4F2F-9A78-F1C3630F6F22</AddInId>
    <FullClassName>RevitAiTemplate.Revit.App</FullClassName>
    <VendorId>RATP</VendorId>
    <VendorDescription>Revit AI-Powered Plugin Template</VendorDescription>
  </AddIn>
</RevitAddIns>
"@

Set-Content -Path $addinPath -Value $addin -Encoding UTF8
Write-Host "Installed dev manifest: $addinPath" -ForegroundColor Green
Write-Host "Assembly: $dll" -ForegroundColor Green
