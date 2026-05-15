param(
  [Parameter(Mandatory=$true)]
  [ValidateSet('2024','2025','2026','2027')]
  [string]$RevitVersion
)

$addinPath = Join-Path $env:APPDATA "Autodesk\Revit\Addins\$RevitVersion\RevitAiTemplate.addin"
if (Test-Path $addinPath) {
  Remove-Item $addinPath -Force
  Write-Host "Removed $addinPath" -ForegroundColor Green
} else {
  Write-Host "No dev manifest found at $addinPath"
}
