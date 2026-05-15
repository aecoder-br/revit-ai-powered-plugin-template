param(
  [string]$Command,
  [string]$RootPath,
  [string]$FeatureId,
  [string]$TaskId,
  [string[]]$Paths = @(),
  [string]$BaseRef,
  [switch]$WorkingTreeOnly,
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
  ./scripts/agent-locks.ps1 -Command validate-diff -FeatureId mcp-read-tools -TaskId task-001 -BaseRef main
  ./scripts/agent-locks.ps1 -Command validate-diff -FeatureId mcp-read-tools -TaskId task-001 -WorkingTreeOnly
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

function Test-PathInside {
  param([string]$Path, [string]$OwnerPath)

  $normalizedPath = ConvertTo-RepoPath -Path $Path
  $normalizedOwnerPath = ConvertTo-RepoPath -Path $OwnerPath

  return ($normalizedPath -eq $normalizedOwnerPath -or $normalizedPath.StartsWith("$normalizedOwnerPath/"))
}

function Test-PathInsideAny {
  param([string]$Path, [string[]]$OwnerPaths)

  foreach ($ownerPath in $OwnerPaths) {
    if (Test-PathInside -Path $Path -OwnerPath $ownerPath) {
      return $true
    }
  }

  return $false
}

function Test-PathOverlapsAny {
  param([string]$Path, [string[]]$OwnerPaths)

  foreach ($ownerPath in $OwnerPaths) {
    if (Test-PathConflict -Left $Path -Right $ownerPath) {
      return $true
    }
  }

  return $false
}

function Format-PathList {
  param([string[]]$Values)

  if ($Values.Count -eq 0) {
    return '<none>'
  }

  return ($Values -join ', ')
}

function Get-TaskPathSet {
  param([object]$Task, [string]$PropertyName)

  if (-not ($Task.PSObject.Properties.Name -contains $PropertyName)) {
    return @()
  }

  return @($Task.$PropertyName | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { ConvertTo-RepoPath -Path $_ })
}

function Get-TaskBaseRef {
  param([object]$Task)

  foreach ($propertyName in @('baseRef','branchBaseRef')) {
    if (($Task.PSObject.Properties.Name -contains $propertyName) -and -not [string]::IsNullOrWhiteSpace($Task.$propertyName)) {
      return $Task.$propertyName
    }
  }

  return $null
}

function Invoke-GitNameList {
  param(
    [string]$Root,
    [string[]]$Arguments,
    [string]$Description
  )

  $safeRoot = (ConvertTo-RepoPath -Path $Root)
  $output = @(& git -c "safe.directory=$safeRoot" -C $Root @Arguments)
  if ($LASTEXITCODE -ne 0) {
    throw "$Description failed with exit code $LASTEXITCODE."
  }

  return @($output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { ConvertTo-RepoPath -Path $_ })
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

  $allowedPaths = Get-TaskPathSet -Task $task -PropertyName 'allowedPaths'
  $readOnlyPaths = Get-TaskPathSet -Task $task -PropertyName 'readOnlyPaths'
  if ($allowedPaths.Count -eq 0) {
    throw "Task '$TaskId' has no allowedPaths. Requested paths: $(Format-PathList -Values @($Paths | ForEach-Object { ConvertTo-RepoPath -Path $_ }))."
  }

  $data = Get-LocksData -LocksFile $state.LocksFile
  $locks = @($data.locks)
  $now = (Get-Date).ToUniversalTime().ToString('o')

  foreach ($requestedPath in $Paths) {
    $normalized = ConvertTo-RepoPath -Path $requestedPath
    if (-not (Test-PathInsideAny -Path $normalized -OwnerPaths $allowedPaths)) {
      throw "Requested lock path '$normalized' is outside allowedPaths for task '$TaskId'. allowedPaths: $(Format-PathList -Values $allowedPaths). readOnlyPaths: $(Format-PathList -Values $readOnlyPaths)."
    }

    if (Test-PathOverlapsAny -Path $normalized -OwnerPaths $readOnlyPaths) {
      throw "Requested lock path '$normalized' overlaps readOnlyPaths for task '$TaskId'. allowedPaths: $(Format-PathList -Values $allowedPaths). readOnlyPaths: $(Format-PathList -Values $readOnlyPaths)."
    }

    foreach ($lock in $locks) {
      if ($lock.taskId -ne $TaskId -and (Test-PathConflict -Left $normalized -Right $lock.path)) {
        throw "Requested lock path '$normalized' conflicts with lock '$($lock.path)' held by task '$($lock.taskId)'. allowedPaths: $(Format-PathList -Values $allowedPaths). readOnlyPaths: $(Format-PathList -Values $readOnlyPaths)."
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

  $allowedPaths = Get-TaskPathSet -Task $task -PropertyName 'allowedPaths'
  $readOnlyPaths = Get-TaskPathSet -Task $task -PropertyName 'readOnlyPaths'
  if ($allowedPaths.Count -eq 0) {
    throw "Task '$TaskId' has no allowedPaths."
  }

  $effectiveBaseRef = $BaseRef
  if ([string]::IsNullOrWhiteSpace($effectiveBaseRef)) {
    $effectiveBaseRef = Get-TaskBaseRef -Task $task
  }

  if (-not $WorkingTreeOnly -and [string]::IsNullOrWhiteSpace($effectiveBaseRef)) {
    throw "validate-diff requires -BaseRef or task baseRef unless -WorkingTreeOnly is specified. Task: $TaskId."
  }

  $changed = @()
  if (-not $WorkingTreeOnly) {
    $changed += Invoke-GitNameList -Root $Root -Arguments @('diff', '--name-only', "$effectiveBaseRef...HEAD") -Description "Committed branch diff from '$effectiveBaseRef' to HEAD"
  }

  $changed += Invoke-GitNameList -Root $Root -Arguments @('diff', '--cached', '--name-only') -Description 'Staged diff'
  $changed += Invoke-GitNameList -Root $Root -Arguments @('diff', '--name-only') -Description 'Unstaged diff'
  $changed += Invoke-GitNameList -Root $Root -Arguments @('ls-files', '--others', '--exclude-standard') -Description 'Untracked file scan'
  $changed = @($changed | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)

  if ($changed.Count -eq 0) {
    Write-Host 'No changed files found by git diff or untracked file scan.' -ForegroundColor Cyan
    return
  }

  $outside = New-Object System.Collections.Generic.List[string]
  $readOnlyViolations = New-Object System.Collections.Generic.List[string]
  foreach ($file in $changed) {
    $normalizedFile = ConvertTo-RepoPath -Path $file
    if (-not (Test-PathInsideAny -Path $normalizedFile -OwnerPaths $allowedPaths)) {
      $outside.Add($normalizedFile) | Out-Null
    }

    if (Test-PathInsideAny -Path $normalizedFile -OwnerPaths $readOnlyPaths) {
      $readOnlyViolations.Add($normalizedFile) | Out-Null
    }
  }

  if ($outside.Count -gt 0 -or $readOnlyViolations.Count -gt 0) {
    Write-Host "Diff validation failed for task: $TaskId" -ForegroundColor Red
    Write-Host "  allowedPaths: $(Format-PathList -Values $allowedPaths)" -ForegroundColor Red
    Write-Host "  readOnlyPaths: $(Format-PathList -Values $readOnlyPaths)" -ForegroundColor Red
    foreach ($file in $outside) {
      Write-Host "  OUTSIDE $file" -ForegroundColor Red
    }
    foreach ($file in $readOnlyViolations) {
      Write-Host "  READONLY $file" -ForegroundColor Red
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
