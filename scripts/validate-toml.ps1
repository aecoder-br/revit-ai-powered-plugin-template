param(
  [string]$RootPath,
  [string]$Path,
  [switch]$VerboseReport
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RootPath)) {
  $RootPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

$root = (Resolve-Path -LiteralPath $RootPath).Path

if ([string]::IsNullOrWhiteSpace($Path)) {
  $Path = Join-Path $root '.codex\config.toml'
}

$tomlPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$passes = New-Object System.Collections.Generic.List[string]
$sections = @{}
$currentSection = ''
$currentKeys = @{}

function Add-Pass {
  param([string]$Message)
  $passes.Add($Message) | Out-Null
}

function Add-Warning {
  param([string]$Message)
  $warnings.Add($Message) | Out-Null
}

function Add-Error {
  param([string]$Message)
  $errors.Add($Message) | Out-Null
}

function Remove-TomlComment {
  param([string]$Line)

  $inSingleQuote = $false
  $inDoubleQuote = $false
  $escaped = $false

  for ($index = 0; $index -lt $Line.Length; $index++) {
    $char = $Line[$index]

    if ($inDoubleQuote -and $char -eq '\' -and -not $escaped) {
      $escaped = $true
      continue
    }

    if ($char -eq '"' -and -not $inSingleQuote -and -not $escaped) {
      $inDoubleQuote = -not $inDoubleQuote
    } elseif ($char -eq "'" -and -not $inDoubleQuote) {
      $inSingleQuote = -not $inSingleQuote
    } elseif ($char -eq '#' -and -not $inSingleQuote -and -not $inDoubleQuote) {
      return $Line.Substring(0, $index)
    }

    $escaped = $false
  }

  return $Line
}

function Test-BalancedQuotes {
  param([string]$Value)

  $inSingleQuote = $false
  $inDoubleQuote = $false
  $escaped = $false

  for ($index = 0; $index -lt $Value.Length; $index++) {
    $char = $Value[$index]

    if ($inDoubleQuote -and $char -eq '\' -and -not $escaped) {
      $escaped = $true
      continue
    }

    if ($char -eq '"' -and -not $inSingleQuote -and -not $escaped) {
      $inDoubleQuote = -not $inDoubleQuote
    } elseif ($char -eq "'" -and -not $inDoubleQuote) {
      $inSingleQuote = -not $inSingleQuote
    }

    $escaped = $false
  }

  return (-not $inSingleQuote -and -not $inDoubleQuote)
}

function Test-TomlScalarValue {
  param([string]$Value)

  $trimmed = $Value.Trim()

  if ([string]::IsNullOrWhiteSpace($trimmed)) {
    return $false
  }

  if (-not (Test-BalancedQuotes -Value $trimmed)) {
    return $false
  }

  if ($trimmed -match '^"(?:[^"\\]|\\.)*"$') { return $true }
  if ($trimmed -match "^'[^']*'$") { return $true }
  if ($trimmed -match '^(true|false)$') { return $true }
  if ($trimmed -match '^[+-]?\d+$') { return $true }
  if ($trimmed -match '^[+-]?\d+\.\d+$') { return $true }
  if ($trimmed -match '^\[(.*)\]$') { return $true }

  return $false
}

if (-not (Test-Path -LiteralPath $tomlPath)) {
  Add-Error "TOML file not found: $tomlPath"
} else {
  Write-Host "Validating TOML: $tomlPath" -ForegroundColor Cyan
  $lines = Get-Content -LiteralPath $tomlPath
  $lineNumber = 0

  foreach ($line in $lines) {
    $lineNumber++
    $withoutComment = Remove-TomlComment -Line $line
    $trimmed = $withoutComment.Trim()

    if ([string]::IsNullOrWhiteSpace($trimmed)) {
      continue
    }

    if ($trimmed -match '^\[([A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+)*)\]$') {
      $currentSection = $Matches[1]
      if ($sections.ContainsKey($currentSection)) {
        Add-Error "Duplicate TOML section at line ${lineNumber}: [$currentSection]"
      } else {
        $sections[$currentSection] = $true
      }
      if (-not $currentKeys.ContainsKey($currentSection)) {
        $currentKeys[$currentSection] = @{}
      }
      Add-Pass "Section parsed: [$currentSection]"
      continue
    }

    if ($trimmed -notmatch '^([A-Za-z0-9_-]+)\s*=\s*(.+)$') {
      Add-Error "Invalid TOML line at ${lineNumber}: $trimmed"
      continue
    }

    $key = $Matches[1]
    $value = $Matches[2]
    if (-not (Test-TomlScalarValue -Value $value)) {
      Add-Error "Unsupported or invalid TOML value at ${lineNumber}: $key = $value"
      continue
    }

    if (-not $currentKeys.ContainsKey($currentSection)) {
      $currentKeys[$currentSection] = @{}
    }

    if ($currentKeys[$currentSection].ContainsKey($key)) {
      $sectionLabel = if ([string]::IsNullOrWhiteSpace($currentSection)) { '<root>' } else { "[$currentSection]" }
      Add-Error "Duplicate key '$key' in $sectionLabel at line $lineNumber"
    } else {
      $currentKeys[$currentSection][$key] = $value.Trim()
    }
  }
}

$rootKeys = @{}
if ($currentKeys.ContainsKey('')) {
  $rootKeys = $currentKeys['']
}

foreach ($requiredRootKey in @('model_reasoning_effort', 'approval_policy', 'sandbox_mode')) {
  if ($rootKeys.ContainsKey($requiredRootKey)) {
    Add-Pass "Required root key exists: $requiredRootKey"
  } else {
    Add-Error "Required root key missing: $requiredRootKey"
  }
}

if ($rootKeys.ContainsKey('approval_policy')) {
  $approvalPolicy = $rootKeys['approval_policy'].Trim('"').Trim("'")
  if (@('untrusted', 'on-failure', 'on-request', 'never') -contains $approvalPolicy) {
    Add-Pass "approval_policy value is recognized: $approvalPolicy"
  } else {
    Add-Warning "approval_policy value is not in the expected conservative set: $approvalPolicy"
  }
}

if ($rootKeys.ContainsKey('sandbox_mode')) {
  $sandboxMode = $rootKeys['sandbox_mode'].Trim('"').Trim("'")
  if (@('read-only', 'workspace-write', 'danger-full-access') -contains $sandboxMode) {
    Add-Pass "sandbox_mode value is recognized: $sandboxMode"
  } else {
    Add-Warning "sandbox_mode value is not recognized by this repository smoke validator: $sandboxMode"
  }
}

if (-not $sections.ContainsKey('features')) {
  Add-Warning 'Optional [features] section is missing.'
}

$profileSections = @($sections.Keys | Where-Object { $_ -like 'profiles.*' })
if ($profileSections.Count -eq 0) {
  Add-Warning 'No [profiles.*] sections found in Codex config.'
} else {
  Add-Pass "Profile sections found: $($profileSections.Count)"
}

if (Test-Path -LiteralPath $tomlPath) {
  $rawText = ($lines | ForEach-Object { Remove-TomlComment -Line $_ }) -join [Environment]::NewLine
  foreach ($secretPattern in @('api[_-]?key', 'secret', 'token', 'password')) {
    if ($rawText -match $secretPattern) {
      Add-Error "Potential secret-related token found in TOML config: $secretPattern"
    }
  }
}

Write-Host ''
Write-Host 'TOML validation summary:' -ForegroundColor Cyan
Write-Host "  Passed:  $($passes.Count)" -ForegroundColor Green
Write-Host "  Warning: $($warnings.Count)" -ForegroundColor Yellow
Write-Host "  Failed:  $($errors.Count)" -ForegroundColor Red

if ($VerboseReport -and $passes.Count -gt 0) {
  Write-Host ''
  Write-Host 'Passed checks:' -ForegroundColor Green
  foreach ($item in $passes) {
    Write-Host "  PASS  $item" -ForegroundColor Green
  }
}

if ($warnings.Count -gt 0) {
  Write-Host ''
  Write-Host 'Warnings:' -ForegroundColor Yellow
  foreach ($item in $warnings) {
    Write-Host "  WARN  $item" -ForegroundColor Yellow
  }
}

if ($errors.Count -gt 0) {
  Write-Host ''
  Write-Host 'Failures:' -ForegroundColor Red
  foreach ($item in $errors) {
    Write-Host "  FAIL  $item" -ForegroundColor Red
  }
  exit 1
}

Write-Host ''
Write-Host 'TOML validation passed.' -ForegroundColor Green
exit 0
