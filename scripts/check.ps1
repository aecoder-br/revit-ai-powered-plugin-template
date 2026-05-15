param(
  [ValidateSet('Debug','Release')]
  [string]$Configuration = 'Debug'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host 'Restoring and testing shared projects...' -ForegroundColor Cyan
dotnet test (Join-Path $root 'tests/RevitAiTemplate.Application.Tests/RevitAiTemplate.Application.Tests.csproj') -c $Configuration

Write-Host 'Building AI Gateway...' -ForegroundColor Cyan
dotnet build (Join-Path $root 'src/RevitAiTemplate.AiGateway/RevitAiTemplate.AiGateway.csproj') -c $Configuration

Write-Host 'Building MCP Server...' -ForegroundColor Cyan
dotnet build (Join-Path $root 'src/RevitAiTemplate.Mcp.Server/RevitAiTemplate.Mcp.Server.csproj') -c $Configuration

Write-Host 'Building installed Revit versions...' -ForegroundColor Cyan
& (Join-Path $root 'scripts/build.ps1') -RevitVersion all -Configuration $Configuration
