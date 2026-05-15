param(
  [ValidateSet('All','Claude','Cursor')]
  [string[]]$Tools = @('All'),
  [ValidateSet('Copy')]
  [string]$Mode = 'Copy',
  [switch]$Force,
  [switch]$Validate,
  [string]$RootPath
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RootPath)) {
  $RootPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

$root = (Resolve-Path -LiteralPath $RootPath).Path
$sourceSkills = Join-Path $root '.agents\skills'

if (-not (Test-Path -LiteralPath $sourceSkills)) {
  throw "Canonical skills directory not found: $sourceSkills"
}

function Get-SelectedTools {
  param([string[]]$RequestedTools)

  if ($RequestedTools -contains 'All') {
    return @('Claude','Cursor')
  }

  return $RequestedTools
}

function Copy-SkillMirror {
  param(
    [string]$ToolName,
    [string]$DestinationRoot
  )

  Write-Host "Updating $ToolName skill mirror: $DestinationRoot" -ForegroundColor Cyan
  New-Item -ItemType Directory -Force -Path $DestinationRoot | Out-Null

  $sourceDirectories = @(Get-ChildItem -LiteralPath $sourceSkills -Directory -Force)
  foreach ($sourceDirectory in $sourceDirectories) {
    $targetDirectory = Join-Path $DestinationRoot $sourceDirectory.Name

    if (Test-Path -LiteralPath $targetDirectory) {
      if (-not $Force) {
        Write-Warning "Skipping existing skill mirror '$targetDirectory'. Use -Force to replace it."
        continue
      }

      $resolvedTarget = (Resolve-Path -LiteralPath $targetDirectory).Path
      $resolvedDestinationRoot = (Resolve-Path -LiteralPath $DestinationRoot).Path
      if (-not $resolvedTarget.StartsWith($resolvedDestinationRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove path outside mirror root: $resolvedTarget"
      }

      Remove-Item -LiteralPath $targetDirectory -Recurse -Force
    }

    Copy-Item -LiteralPath $sourceDirectory.FullName -Destination $targetDirectory -Recurse -Force
    Write-Host "  Copied $($sourceDirectory.Name)" -ForegroundColor Green
  }
}

$selectedTools = Get-SelectedTools -RequestedTools $Tools

foreach ($tool in $selectedTools) {
  switch ($tool) {
    'Claude' {
      Copy-SkillMirror -ToolName 'Claude' -DestinationRoot (Join-Path $root '.claude\skills')
    }
    'Cursor' {
      Copy-SkillMirror -ToolName 'Cursor' -DestinationRoot (Join-Path $root '.cursor\skills')
    }
    default {
      throw "Unsupported tool: $tool"
    }
  }
}

if ($Validate) {
  $validator = Join-Path $root 'scripts\validate-skills.ps1'
  if (-not (Test-Path -LiteralPath $validator)) {
    throw "Skill validator not found: $validator"
  }

  & $validator -RootPath $root -IncludeMirrors
  if ($LASTEXITCODE -ne 0) {
    throw "Skill validation failed with exit code $LASTEXITCODE."
  }
}

Write-Host 'AI tool setup completed.' -ForegroundColor Green
