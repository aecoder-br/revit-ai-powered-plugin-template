param(
  [string]$RootPath,
  [ValidateSet('All','Codex','Claude','Cursor','Copilot')]
  [string[]]$Tools = @('All'),
  [switch]$FailOnWarnings,
  [switch]$VerboseReport
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RootPath)) {
  $RootPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

$root = (Resolve-Path -LiteralPath $RootPath).Path
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$passes = New-Object System.Collections.Generic.List[string]

$primaryAgentRoles = @(
  'orchestrator-feature-lead',
  'branch-coordinator',
  'revit-api-senior',
  'revit-multiversion-architect',
  'cybersecurity-privacy-engineer',
  'qa-automation-engineer',
  'verifier'
)

$copilotPromptNames = @(
  'feature-plan',
  'product-requirements',
  'revit-api-review',
  'multiversion-impact',
  'security-review',
  'qa-validation',
  'pr-summary',
  'template-setup'
)

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

function Get-SelectedTools {
  param([string[]]$RequestedTools)

  if ($RequestedTools -contains 'All') {
    return @('Codex','Claude','Cursor','Copilot')
  }

  return @($RequestedTools | Select-Object -Unique)
}

function Test-FileContainsAny {
  param(
    [string]$Path,
    [string[]]$Needles
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    return $false
  }

  $text = Get-Content -Raw -LiteralPath $Path
  foreach ($needle in $Needles) {
    if ($text -match [regex]::Escape($needle)) {
      return $true
    }
  }

  return $false
}

function Test-CanonicalSkills {
  param([string[]]$Roles)

  foreach ($role in $Roles) {
    $skillPath = Join-Path $root (Join-Path '.agents\skills' (Join-Path $role 'SKILL.md'))
    if (Test-Path -LiteralPath $skillPath) {
      Add-Pass "Canonical skill exists: .agents/skills/$role/SKILL.md"
    } else {
      Add-Error "Missing canonical skill for roster role '$role': .agents/skills/$role/SKILL.md"
    }
  }
}

function Test-SkillMirror {
  param(
    [string]$ToolName,
    [string]$MirrorRoot,
    [string[]]$Roles
  )

  if (-not (Test-Path -LiteralPath $MirrorRoot)) {
    Add-Warning "$ToolName skill mirror not found; skipping mirror parity: $MirrorRoot"
    return
  }

  foreach ($role in $Roles) {
    $skillPath = Join-Path $MirrorRoot (Join-Path $role 'SKILL.md')
    if (Test-Path -LiteralPath $skillPath) {
      Add-Pass "$ToolName mirror skill exists: $role"
    } else {
      Add-Error "$ToolName mirror missing skill for roster role '$role': $skillPath"
    }
  }
}

function Test-AgentAdapters {
  param(
    [string]$ToolName,
    [string]$AgentRoot
  )

  foreach ($role in $primaryAgentRoles) {
    $agentPath = Join-Path $AgentRoot "$role.md"
    if (-not (Test-Path -LiteralPath $agentPath)) {
      Add-Error "$ToolName agent adapter missing for primary role '$role': $agentPath"
      continue
    }

    $canonicalReference = ".agents/skills/$role"
    if (Test-FileContainsAny -Path $agentPath -Needles @($canonicalReference, ".agents\skills\$role")) {
      Add-Pass "$ToolName agent adapter references canonical skill: $role"
    } else {
      Add-Error "$ToolName agent adapter '$agentPath' does not reference $canonicalReference"
    }
  }
}

function Test-CodexAdapter {
  $codexRoot = Join-Path $root '.codex'
  $configPath = Join-Path $codexRoot 'config.toml'
  $readmePath = Join-Path $codexRoot 'README.md'

  if (Test-Path -LiteralPath $configPath) {
    Add-Pass 'Codex config exists: .codex/config.toml'
  } else {
    Add-Error 'Codex config missing: .codex/config.toml'
  }

  if (Test-Path -LiteralPath $readmePath) {
    Add-Pass 'Codex README exists: .codex/README.md'
    if (Test-FileContainsAny -Path $readmePath -Needles @('.agents/skills', '.agents\skills')) {
      Add-Pass 'Codex README references .agents/skills as the canonical skill source.'
    } else {
      Add-Error 'Codex README does not reference .agents/skills as the canonical skill source.'
    }
  } else {
    Add-Error 'Codex README missing: .codex/README.md'
  }
}

function Test-ClaudeAdapter {
  param([string[]]$Roles)

  Test-SkillMirror -ToolName 'Claude' -MirrorRoot (Join-Path $root '.claude\skills') -Roles $Roles
  Test-AgentAdapters -ToolName 'Claude' -AgentRoot (Join-Path $root '.claude\agents')
}

function Test-CursorAdapter {
  param([string[]]$Roles)

  Test-SkillMirror -ToolName 'Cursor' -MirrorRoot (Join-Path $root '.cursor\skills') -Roles $Roles
  Test-AgentAdapters -ToolName 'Cursor' -AgentRoot (Join-Path $root '.cursor\agents')
}

function Test-CopilotAdapter {
  $instructionsPath = Join-Path $root '.github\copilot-instructions.md'
  if (-not (Test-Path -LiteralPath $instructionsPath)) {
    Add-Error 'Copilot instructions missing: .github/copilot-instructions.md'
  } elseif (Test-FileContainsAny -Path $instructionsPath -Needles @('AGENTS.md')) {
    Add-Pass 'Copilot instructions reference AGENTS.md.'
  } else {
    Add-Error 'Copilot instructions do not reference AGENTS.md.'
  }

  $promptRoot = Join-Path $root '.github\prompts'
  if (-not (Test-Path -LiteralPath $promptRoot)) {
    Add-Error 'Copilot prompt directory missing: .github/prompts'
    return
  }

  foreach ($promptName in $copilotPromptNames) {
    $promptPath = Join-Path $promptRoot "$promptName.prompt.md"
    if (-not (Test-Path -LiteralPath $promptPath)) {
      Add-Error "Copilot prompt missing: .github/prompts/$promptName.prompt.md"
      continue
    }

    if (Test-FileContainsAny -Path $promptPath -Needles @('AGENTS.md', '.agents/workflows', '.agents\workflows')) {
      Add-Pass "Copilot prompt references canonical guidance: $promptName.prompt.md"
    } else {
      Add-Error "Copilot prompt does not reference AGENTS.md or .agents/workflows: $promptName.prompt.md"
    }
  }
}

Write-Host "Validating AI adapter parity under $root" -ForegroundColor Cyan

$rosterPath = Join-Path $root '.agents\roster.json'
if (-not (Test-Path -LiteralPath $rosterPath)) {
  Add-Error 'Roster missing: .agents/roster.json'
} else {
  $roster = Get-Content -Raw -LiteralPath $rosterPath | ConvertFrom-Json
  $roles = @($roster.roles | ForEach-Object { $_.name } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  if ($roles.Count -eq 0) {
    Add-Error 'Roster contains no roles.'
  } else {
    Add-Pass "Roster roles loaded: $($roles.Count)"
    Test-CanonicalSkills -Roles $roles
  }
}

$selectedTools = Get-SelectedTools -RequestedTools $Tools

foreach ($tool in $selectedTools) {
  switch ($tool) {
    'Codex' { Test-CodexAdapter }
    'Claude' { Test-ClaudeAdapter -Roles $roles }
    'Cursor' { Test-CursorAdapter -Roles $roles }
    'Copilot' { Test-CopilotAdapter }
    default { Add-Error "Unsupported tool: $tool" }
  }
}

Write-Host ''
Write-Host "AI adapter parity summary:" -ForegroundColor Cyan
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

if ($FailOnWarnings -and $warnings.Count -gt 0) {
  Write-Host ''
  Write-Host 'Failing because -FailOnWarnings was specified.' -ForegroundColor Red
  exit 1
}

Write-Host ''
Write-Host 'AI adapter parity validation passed.' -ForegroundColor Green
exit 0
