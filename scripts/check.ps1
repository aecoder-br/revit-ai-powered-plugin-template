param(
  [ValidateSet('Debug','Release')]
  [string]$Configuration = 'Debug'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$solution = Join-Path $root 'RevitAiTemplate.sln'

function Invoke-CheckedExternalCommand {
  param(
    [string]$Description,
    [string]$FilePath,
    [string[]]$Arguments
  )

  Write-Host $Description -ForegroundColor Cyan
  try {
    & $FilePath @Arguments
    $exitCode = $LASTEXITCODE
  } catch {
    Write-Host "$Description failed to start or terminated unexpectedly." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    throw
  }

  if ($exitCode -ne 0) {
    Write-Host "$Description failed with exit code $exitCode." -ForegroundColor Red
    throw "$Description failed with exit code $exitCode."
  }
}

function Invoke-CheckedScriptBlock {
  param(
    [string]$Description,
    [scriptblock]$Command
  )

  Write-Host $Description -ForegroundColor Cyan
  try {
    & $Command
    $exitCode = $LASTEXITCODE
  } catch {
    Write-Host "$Description failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    throw
  }

  if ($exitCode -ne 0) {
    Write-Host "$Description failed with exit code $exitCode." -ForegroundColor Red
    throw "$Description failed with exit code $exitCode."
  }
}

if (Test-Path $solution) {
  Write-Host "Visual Studio solution detected: $solution" -ForegroundColor Cyan
} else {
  Write-Warning "Visual Studio solution not found at $solution."
}

$agentSkills = Join-Path $root '.agents/skills'
$skillValidator = Join-Path $root 'scripts/validate-skills.ps1'
if (Test-Path $agentSkills) {
  Invoke-CheckedScriptBlock `
    -Description 'Validating agent skills...' `
    -Command { & $skillValidator -RootPath $root -IncludeMirrors }
}

Invoke-CheckedExternalCommand `
  -Description 'Restoring and testing shared projects...' `
  -FilePath 'dotnet' `
  -Arguments @('test', (Join-Path $root 'tests/RevitAiTemplate.Application.Tests/RevitAiTemplate.Application.Tests.csproj'), '-c', $Configuration)

Invoke-CheckedExternalCommand `
  -Description 'Building AI Gateway...' `
  -FilePath 'dotnet' `
  -Arguments @('build', (Join-Path $root 'src/RevitAiTemplate.AiGateway/RevitAiTemplate.AiGateway.csproj'), '-c', $Configuration)

Invoke-CheckedExternalCommand `
  -Description 'Building MCP Server...' `
  -FilePath 'dotnet' `
  -Arguments @('build', (Join-Path $root 'src/RevitAiTemplate.Mcp.Server/RevitAiTemplate.Mcp.Server.csproj'), '-c', $Configuration)

Invoke-CheckedScriptBlock `
  -Description 'Building installed Revit versions...' `
  -Command { & (Join-Path $root 'scripts/build.ps1') -RevitVersion all -Configuration $Configuration }
