param(
  [string]$RootPath,
  [string]$OutputPath,
  [switch]$Force,
  [switch]$NoZip
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RootPath)) {
  $RootPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

$root = (Resolve-Path -LiteralPath $RootPath).Path
$source = Join-Path $root 'templates\visualstudio'

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = Join-Path $root 'artifacts\templates\visualstudio'
}

$output = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
$artifactsRoot = Join-Path $root 'artifacts'

if (-not (Test-Path -LiteralPath $source)) {
  throw "Visual Studio template source not found: $source"
}

function Assert-PathInside {
  param(
    [string]$ChildPath,
    [string]$ParentPath,
    [string]$Message
  )

  $resolvedParent = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ParentPath)
  $resolvedChild = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ChildPath)

  if (-not $resolvedChild.StartsWith($resolvedParent, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw $Message
  }
}

$rootTemplate = Join-Path $source 'RevitAiPlugin.ProjectGroup.vstemplate'
if (-not (Test-Path -LiteralPath $rootTemplate)) {
  throw "Root Visual Studio template not found: $rootTemplate"
}

[xml]$templateXml = Get-Content -Raw -LiteralPath $rootTemplate
$namespaceManager = New-Object System.Xml.XmlNamespaceManager($templateXml.NameTable)
$namespaceManager.AddNamespace('vs', 'http://schemas.microsoft.com/developer/vstemplate/2005')

$templateNode = $templateXml.SelectSingleNode('/vs:VSTemplate', $namespaceManager)
if ($null -eq $templateNode -or $templateNode.Type -ne 'ProjectGroup') {
  throw 'Root .vstemplate must be a VSTemplate with Type="ProjectGroup".'
}

$projectLinks = $templateXml.SelectNodes('//vs:ProjectTemplateLink', $namespaceManager)
if ($projectLinks.Count -eq 0) {
  throw 'Root .vstemplate must contain at least one ProjectTemplateLink.'
}

if (Test-Path -LiteralPath $output) {
  if (-not $Force) {
    throw "Visual Studio template output already exists: $output. Re-run with -Force to replace it."
  }

  Assert-PathInside -ChildPath $output -ParentPath $artifactsRoot -Message "Refusing to remove output outside artifacts: $output"
  Remove-Item -LiteralPath $output -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $output | Out-Null
$sourceItems = Get-ChildItem -LiteralPath $source -Force
foreach ($sourceItem in $sourceItems) {
  Copy-Item -LiteralPath $sourceItem.FullName -Destination $output -Recurse -Force
}

Write-Host "Visual Studio template staged: $output" -ForegroundColor Green
Write-Host "ProjectTemplateLink entries: $($projectLinks.Count)" -ForegroundColor Green

if (-not $NoZip) {
  $zipPath = Join-Path $output 'RevitAiPlugin.VisualStudioTemplate.zip'
  if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
  }

  $itemsToZip = Get-ChildItem -LiteralPath $output -Force | Where-Object { $_.FullName -ne $zipPath }
  if ($itemsToZip.Count -eq 0) {
    throw "No Visual Studio template files were staged into $output."
  }

  Compress-Archive -LiteralPath $itemsToZip.FullName -DestinationPath $zipPath -Force
  Write-Host "Visual Studio template zip created: $zipPath" -ForegroundColor Green
}
