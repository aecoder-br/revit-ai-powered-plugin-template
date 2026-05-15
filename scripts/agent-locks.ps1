param(
  [string]$Command,
  [string]$RootPath,
  [string]$FeatureId,
  [string]$TaskId,
  [string[]]$Paths = @(),
  [string]$BaseRef,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'

function Show-Usage {
  Write-Host @'
agent-locks.ps1

Commands:
  list           List locks for a feature.
  acquire        Acquire path locks for a task.
  release        Release path locks for a task.
  validate-diff  Compare git changed files with the task allowedPaths.

Examples:
  ./scripts/agent-locks.ps1 -Command list -FeatureId mcp-read-tools
  ./scripts/agent-locks.ps1 -Command acquire -FeatureId mcp-read-tools -TaskId task-001 -Paths docs/features/mcp-read-tools
  ./scripts/agent-locks.ps1 -Command release -FeatureId mcp-read-tools -TaskId task-001 -Paths docs/features/mcp-read-tools
  ./scripts/agent-locks.ps1 -Command validate-diff -FeatureId mcp-read-tools -TaskId task-001
'@
}

function Get-RepoRoot {
  if (-not [string]::IsNullOrWhiteSpace($RootPath)) {
    return (Resolve-Path -LiteralPath $RootPath).Path
  }

  return (Split-Path -Parent $PSScriptRoot)
}

function Assert-Id {
  param([string]$Value, [string]$Name)
  if ([string]::IsNullOrWhiteSpace($Value)) {
    throw "$Name is required."
  }
  if ($Value -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
    throw "$Name must be lowercase kebab-case: $Value"
  }
}

function ConvertTo-RepoPath {
  param([string]$Path)
  return ($Path -replace '\\','/').Trim().Trim('/')
}

function Test-PathConflict {
  param([string]$Left, [string]$Right)

  $a = ConvertTo-RepoPath -Path $Left
  $b = ConvertTo-RepoPath -Path $Right

  return ($a -eq $b -or $a.StartsWith("$b/") -or $b.StartsWith("$a/"))
}

function Get-StatePaths {
  param([string]$Root, [string]$Id)
  $stateRoot = Join-Path $Root (Join-Path '.agents\state' $Id)
  return [pscustomobject]@{
    StateRoot = $stateRoot
    TasksFile = Join-Path $stateRoot 'tasks.json'
    LocksFile = Join-Path $stateRoot 'locks.json'
  }
}

function Read-JsonOrDefault {
  param([string]$Path, [object]$DefaultValue)

  if (-not (Test-Path -LiteralPath $Path)) {
    return $DefaultValue
  }

  $raw = Get-Content -Raw -LiteralPath $Path
  if ([string]::IsNullOrWhiteSpace($raw)) {
    return $DefaultValue
  }

  return ($raw | ConvertFrom-Json)
}

function Write-Json {
  param([string]$Path, [object]$Value)

  $parent = Split-Path -Parent $Path
  New-Item -ItemType Directory -Force -Path $parent | Out-Null
  $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-Task {
  param([string]$TasksFile, [string]$Id)
  $tasks = @(Read-JsonOrDefault -Path $TasksFile -DefaultValue @())
  return ($tasks | Where-Object { $_.id -eq $Id } | Select-Object -First 1)
}

function Get-LocksData {
  param([string]$LocksFile)
  $data = Read-JsonOrDefault -Path $LocksFile -DefaultValue ([pscustomobject]@{ featureId = $FeatureId; locks = @() })
  if (-not ($data.PSObject.Properties.Name -contains 'locks')) {
    $data | Add-Member -NotePropertyName locks -NotePropertyValue @()
  }
  return $data
}

function Invoke-ListLocks {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  $paths = Get-StatePaths -Root $Root -Id $FeatureId
  $locks = @((Get-LocksData -LocksFile $paths.LocksFile).locks)
  if ($locks.Count -eq 0) {
    Write-Host "No locks found for $FeatureId."
    return
  }

  $locks | Format-Table taskId,path,acquiredAt -AutoSize
}

function Invoke-Acquire {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  Assert-Id -Value $TaskId -Name 'TaskId'
  if ($Paths.Count -eq 0) {
    throw 'At least one path is required.'
  }

  $state = Get-StatePaths -Root $Root -Id $FeatureId
  $task = Get-Task -TasksFile $state.TasksFile -Id $TaskId
  if ($null -eq $task) {
    throw "Task does not exist: $TaskId"
  }

  if (@('completed','cancelled') -contains $task.status) {
    throw "Cannot acquire locks for inactive task '$TaskId' with status '$($task.status)'."
  }

  $data = Get-LocksData -LocksFile $state.LocksFile
  $locks = @($data.locks)
  $now = (Get-Date).ToUniversalTime().ToString('o')

  foreach ($requestedPath in $Paths) {
    $normalized = ConvertTo-RepoPath -Path $requestedPath
    foreach ($lock in $locks) {
      if ($lock.taskId -ne $TaskId -and (Test-PathConflict -Left $normalized -Right $lock.path)) {
        throw "Path '$normalized' conflicts with lock '$($lock.path)' held by task '$($lock.taskId)'."
      }
    }
  }

  foreach ($requestedPath in $Paths) {
    $normalized = ConvertTo-RepoPath -Path $requestedPath
    if (@($locks | Where-Object { $_.taskId -eq $TaskId -and $_.path -eq $normalized }).Count -eq 0) {
      $locks += [pscustomobject]@{
        taskId = $TaskId
        path = $normalized
        acquiredAt = $now
      }
      Write-Host "Acquired lock: $normalized" -ForegroundColor Green
    }
  }

  $data.locks = @($locks)
  Write-Json -Path $state.LocksFile -Value $data
}

function Invoke-Release {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  Assert-Id -Value $TaskId -Name 'TaskId'

  $state = Get-StatePaths -Root $Root -Id $FeatureId
  $data = Get-LocksData -LocksFile $state.LocksFile
  $locks = @($data.locks)

  if ($Paths.Count -gt 0) {
    $normalizedPaths = @($Paths | ForEach-Object { ConvertTo-RepoPath -Path $_ })
    $locks = @($locks | Where-Object { -not ($_.taskId -eq $TaskId -and ($normalizedPaths -contains $_.path)) })
  } else {
    $locks = @($locks | Where-Object { $_.taskId -ne $TaskId })
  }

  $data.locks = @($locks)
  Write-Json -Path $state.LocksFile -Value $data
  Write-Host "Released locks for task: $TaskId" -ForegroundColor Green
}

function Invoke-ValidateDiff {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  Assert-Id -Value $TaskId -Name 'TaskId'

  $state = Get-StatePaths -Root $Root -Id $FeatureId
  $task = Get-Task -TasksFile $state.TasksFile -Id $TaskId
  if ($null -eq $task) {
    throw "Task does not exist: $TaskId"
  }

  $allowedPaths = @($task.allowedPaths | ForEach-Object { ConvertTo-RepoPath -Path $_ })
  if ($allowedPaths.Count -eq 0) {
    throw "Task '$TaskId' has no allowedPaths."
  }

  $diffArgs = @('-C', $Root, 'diff', '--name-only')
  if (-not [string]::IsNullOrWhiteSpace($BaseRef)) {
    $diffArgs += $BaseRef
  }

  $changed = @(& git @diffArgs)
  $staged = @(& git -C $Root diff --cached --name-only)
  $changed = @($changed + $staged | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)

  if ($changed.Count -eq 0) {
    Write-Host 'No changed files found by git diff.' -ForegroundColor Cyan
    return
  }

  $outside = New-Object System.Collections.Generic.List[string]
  foreach ($file in $changed) {
    $normalizedFile = ConvertTo-RepoPath -Path $file
    $inside = $false
    foreach ($allowed in $allowedPaths) {
      if ($normalizedFile -eq $allowed -or $normalizedFile.StartsWith("$allowed/")) {
        $inside = $true
        break
      }
    }
    if (-not $inside) {
      $outside.Add($normalizedFile) | Out-Null
    }
  }

  if ($outside.Count -gt 0) {
    Write-Host "Diff validation failed for task: $TaskId" -ForegroundColor Red
    foreach ($file in $outside) {
      Write-Host "  OUTSIDE $file" -ForegroundColor Red
    }
    exit 1
  }

  Write-Host "Diff validation passed for task: $TaskId" -ForegroundColor Green
}

if ($Help -or [string]::IsNullOrWhiteSpace($Command)) {
  Show-Usage
  exit 0
}

$root = Get-RepoRoot

switch ($Command.ToLowerInvariant()) {
  'list' { Invoke-ListLocks -Root $root }
  'acquire' { Invoke-Acquire -Root $root }
  'release' { Invoke-Release -Root $root }
  'validate-diff' { Invoke-ValidateDiff -Root $root }
  default {
    Show-Usage
    throw "Unsupported command: $Command"
  }
}
