param(
  [string]$RootPath,
  [string]$OutputPath,
  [switch]$Install,
  [switch]$Test,
  [switch]$TestMatrix,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RootPath)) {
  $RootPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

$root = (Resolve-Path -LiteralPath $RootPath).Path

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = Join-Path $root 'artifacts\templates\RevitAiPlugin'
}

$output = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
$artifactsRoot = Join-Path $root 'artifacts'
$templateConfigSource = Join-Path $root 'templates\dotnet\RevitAiPlugin\.template.config'

if (-not (Test-Path -LiteralPath $templateConfigSource)) {
  throw "Template config directory not found: $templateConfigSource"
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

function Test-ExcludedPath {
  param([string]$RelativePath)

  $normalized = $RelativePath.Replace('\', '/')

  if ($normalized -eq '.git' -or $normalized.StartsWith('.git/')) { return $true }
  if ($normalized -eq '.vs' -or $normalized.StartsWith('.vs/')) { return $true }
  if ($normalized -eq 'artifacts' -or $normalized.StartsWith('artifacts/')) { return $true }
  if ($normalized -eq '.worktrees' -or $normalized.StartsWith('.worktrees/')) { return $true }
  if ($normalized -eq 'templates/dotnet/RevitAiPlugin' -or $normalized.StartsWith('templates/dotnet/RevitAiPlugin/')) { return $true }
  if ($normalized -like '*/bin' -or $normalized -like '*/bin/*' -or $normalized -eq 'bin') { return $true }
  if ($normalized -like '*/obj' -or $normalized -like '*/obj/*' -or $normalized -eq 'obj') { return $true }
  if ($normalized.EndsWith('.user')) { return $true }
  if ($normalized.EndsWith('.suo')) { return $true }
  if ($normalized.EndsWith('.cache')) { return $true }
  if ($normalized.EndsWith('.log')) { return $true }
  if ($normalized.EndsWith('.nupkg')) { return $true }
  if ($normalized.EndsWith('.snupkg')) { return $true }
  if ($normalized -eq '.env') { return $true }
  if ($normalized -like 'secrets.*') { return $true }
  if ($normalized -eq 'appsettings.Production.json') { return $true }

  return $false
}

function Copy-TemplateContent {
  param(
    [string]$SourceRoot,
    [string]$DestinationRoot
  )

  $sourcePrefixLength = $SourceRoot.Length + 1
  New-Item -ItemType Directory -Force -Path $DestinationRoot | Out-Null

  $items = Get-ChildItem -LiteralPath $SourceRoot -Force -Recurse
  foreach ($item in $items) {
    $relative = $item.FullName.Substring($sourcePrefixLength)

    if (Test-ExcludedPath -RelativePath $relative) {
      continue
    }

    $target = Join-Path $DestinationRoot $relative

    if ($item.PSIsContainer) {
      New-Item -ItemType Directory -Force -Path $target | Out-Null
      continue
    }

    $targetDirectory = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $targetDirectory | Out-Null
    Copy-Item -LiteralPath $item.FullName -Destination $target -Force
  }
}

function Invoke-DotNetNew {
  param([string[]]$Arguments)

  $dotnetWorkingDirectory = [System.IO.Path]::GetTempPath()
  Push-Location -LiteralPath $dotnetWorkingDirectory
  try {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
      $outputLines = & dotnet @Arguments 2>&1
      $exitCode = $LASTEXITCODE
    }
    finally {
      $ErrorActionPreference = $previousErrorActionPreference
    }

    foreach ($outputLine in $outputLines) {
      Write-Host $outputLine
    }

    return $exitCode
  }
  finally {
    Pop-Location
  }
}

if (Test-Path -LiteralPath $output) {
  if (-not $Force -and -not $TestMatrix) {
    throw "Template output already exists: $output. Re-run with -Force to replace it."
  }

  Assert-PathInside -ChildPath $output -ParentPath $artifactsRoot -Message "Refusing to remove output outside artifacts: $output"
  Remove-Item -LiteralPath $output -Recurse -Force
}

Write-Host "Packing dotnet template into $output" -ForegroundColor Cyan
Copy-TemplateContent -SourceRoot $root -DestinationRoot $output

$stagedConfig = Join-Path $output '.template.config'
New-Item -ItemType Directory -Force -Path $stagedConfig | Out-Null
Copy-Item -LiteralPath (Join-Path $templateConfigSource 'template.json') -Destination (Join-Path $stagedConfig 'template.json') -Force

Write-Host 'Template staged successfully.' -ForegroundColor Green
Write-Host "Install with: dotnet new install `"$output`"" -ForegroundColor Green

if ($Install -or $Test -or $TestMatrix) {
  $uninstallExitCode = Invoke-DotNetNew -Arguments @('new', 'uninstall', $output)
  if ($uninstallExitCode -ne 0) {
    Write-Host "Template was not previously installed from $output, continuing." -ForegroundColor DarkYellow
  }

  $installExitCode = Invoke-DotNetNew -Arguments @('new', 'install', $output)
  if ($installExitCode -ne 0) {
    throw "dotnet new install failed with exit code $installExitCode."
  }
}

function Assert-GeneratedTemplateOptions {
  param(
    [string]$SampleOutput,
    [string]$ExpectedAiTools
  )

  $optionsPath = Join-Path $SampleOutput 'docs\generated\template-options.md'
  if (-not (Test-Path -LiteralPath $optionsPath)) {
    throw "Generated template options file was not found: $optionsPath"
  }

  $optionsText = Get-Content -Raw -LiteralPath $optionsPath
  $expectedLine = "| AiTools | $ExpectedAiTools |"
  if (-not $optionsText.Contains($expectedLine)) {
    throw "Generated template options file does not contain expected AiTools value '$ExpectedAiTools': $optionsPath"
  }

  if (-not $optionsText.Contains('| RevitVersions | 2024-2027 |')) {
    throw "Generated template options file does not contain expected default RevitVersions value '2024-2027': $optionsPath"
  }

  if ($optionsText -match '__[A-Za-z0-9]+__') {
    throw "Generated template options file still contains unreplaced option placeholders: $optionsPath"
  }
}

function New-TemplateSample {
  param(
    [string]$TestRoot,
    [string]$SampleName,
    [string]$AiTools
  )

  $sampleOutput = Join-Path $TestRoot $SampleName

  if (Test-Path -LiteralPath $sampleOutput) {
    Assert-PathInside -ChildPath $sampleOutput -ParentPath $TestRoot -Message "Refusing to remove test output outside template-test: $sampleOutput"
    Remove-Item -LiteralPath $sampleOutput -Recurse -Force
  }

  $testExitCode = Invoke-DotNetNew -Arguments @(
    'new',
    'revit-ai-plugin',
    '-n',
    $SampleName,
    '--AiTools',
    $AiTools,
    '--CompanyName',
    'Sample Company',
    '--ProductName',
    "Sample $SampleName",
    '--RootNamespace',
    $SampleName,
    '--VendorId',
    'SAMP',
    '-o',
    $sampleOutput
  )
  if ($testExitCode -ne 0) {
    throw "dotnet new revit-ai-plugin test failed for AiTools '$AiTools' with exit code $testExitCode."
  }

  $sampleSolution = Join-Path $sampleOutput "$SampleName.sln"
  if (-not (Test-Path -LiteralPath $sampleSolution)) {
    throw "Generated sample solution was not found: $sampleSolution"
  }

  Assert-GeneratedTemplateOptions -SampleOutput $sampleOutput -ExpectedAiTools $AiTools
  Write-Host "Template sample generated and validated: $sampleOutput" -ForegroundColor Green
}

if ($Test) {
  $testRoot = Join-Path $root 'artifacts\template-test'
  New-Item -ItemType Directory -Force -Path $testRoot | Out-Null
  New-TemplateSample -TestRoot $testRoot -SampleName 'SampleRevitPlugin' -AiTools 'multi'
}

if ($TestMatrix) {
  $testRoot = Join-Path $root 'artifacts\template-test'
  New-Item -ItemType Directory -Force -Path $testRoot | Out-Null

  $matrix = @(
    @{ Name = 'SampleAiToolsNone'; AiTools = 'none' },
    @{ Name = 'SampleAiToolsCodex'; AiTools = 'codex' },
    @{ Name = 'SampleAiToolsClaude'; AiTools = 'claude' },
    @{ Name = 'SampleAiToolsCursor'; AiTools = 'cursor' },
    @{ Name = 'SampleAiToolsCopilot'; AiTools = 'copilot' },
    @{ Name = 'SampleAiToolsMulti'; AiTools = 'multi' }
  )

  foreach ($sample in $matrix) {
    New-TemplateSample -TestRoot $testRoot -SampleName $sample.Name -AiTools $sample.AiTools
  }

  Write-Host 'Template test matrix completed.' -ForegroundColor Green
}
