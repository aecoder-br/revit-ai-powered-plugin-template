param(
  [string]$Command,
  [string]$RootPath,
  [string]$FeatureId,
  [string]$TaskId,
  [string]$AssignedRole,
  [switch]$Force,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'

function Show-Usage {
  Write-Host @'
agent-worktree.ps1

Commands:
  create    Create branch ai/<feature-id>/<task-id>-<role> and worktree .worktrees/<feature-id>/<task-id>.
  list      List git worktrees.
  remove    Remove a task worktree. Requires -Force.
  validate  Validate worktree state for a feature or task.

Examples:
  ./scripts/agent-worktree.ps1 -Command create -FeatureId mcp-read-tools -TaskId task-001 -AssignedRole requirements-analyst
  ./scripts/agent-worktree.ps1 -Command list
  ./scripts/agent-worktree.ps1 -Command validate -FeatureId mcp-read-tools
  ./scripts/agent-worktree.ps1 -Command remove -FeatureId mcp-read-tools -TaskId task-001 -Force
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

function Get-StatePaths {
  param([string]$Root, [string]$Id)
  $stateRoot = Join-Path $Root (Join-Path '.agents\state' $Id)
  return [pscustomobject]@{
    StateRoot = $stateRoot
    TasksFile = Join-Path $stateRoot 'tasks.json'
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
  $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-TaskArray {
  param([string]$Path)
  return @(Read-JsonOrDefault -Path $Path -DefaultValue @())
}

function Get-BranchName {
  param([string]$Id, [string]$Task, [string]$Role)
  return "ai/$Id/$Task-$Role"
}

function Get-RelativeWorktreePath {
  param([string]$Id, [string]$Task)
  return ".worktrees/$Id/$Task"
}

function Ensure-WorktreesIgnored {
  param([string]$Root)

  $gitignore = Join-Path $Root '.gitignore'
  if (-not (Test-Path -LiteralPath $gitignore)) {
    ".worktrees/`r`n" | Set-Content -LiteralPath $gitignore -Encoding UTF8
    return
  }

  $lines = @(Get-Content -LiteralPath $gitignore)
  if ($lines -notcontains '.worktrees/') {
    Add-Content -LiteralPath $gitignore -Value '.worktrees/'
    Write-Host 'Added .worktrees/ to .gitignore.' -ForegroundColor Green
  }
}

function Get-Task {
  param([object[]]$Tasks, [string]$Id)
  return ($Tasks | Where-Object { $_.id -eq $Id } | Select-Object -First 1)
}

function Invoke-CreateWorktree {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  Assert-Id -Value $TaskId -Name 'TaskId'
  Assert-Id -Value $AssignedRole -Name 'AssignedRole'
  Ensure-WorktreesIgnored -Root $Root

  $state = Get-StatePaths -Root $Root -Id $FeatureId
  if (-not (Test-Path -LiteralPath $state.TasksFile)) {
    throw "Feature tasks file does not exist: $($state.TasksFile)"
  }

  $tasks = @(Get-TaskArray -Path $state.TasksFile)
  $task = Get-Task -Tasks $tasks -Id $TaskId
  if ($null -eq $task) {
    throw "Task does not exist: $TaskId"
  }

  $branch = Get-BranchName -Id $FeatureId -Task $TaskId -Role $AssignedRole
  $relativeWorktree = Get-RelativeWorktreePath -Id $FeatureId -Task $TaskId
  $worktreePath = Join-Path $Root ($relativeWorktree -replace '/', '\')

  if (Test-Path -LiteralPath $worktreePath) {
    throw "Worktree path already exists: $worktreePath"
  }

  $branchExists = $false
  & git -C $Root show-ref --verify --quiet "refs/heads/$branch"
  if ($LASTEXITCODE -eq 0) {
    $branchExists = $true
  }

  if ($branchExists) {
    & git -C $Root worktree add $worktreePath $branch
  } else {
    & git -C $Root worktree add -b $branch $worktreePath
  }

  if ($LASTEXITCODE -ne 0) {
    throw "git worktree add failed with exit code $LASTEXITCODE."
  }

  $task.branch = $branch
  $task.worktreePath = $relativeWorktree
  $task.status = 'in-progress'
  Write-Json -Path $state.TasksFile -Value $tasks

  Write-Host "Created worktree: $relativeWorktree" -ForegroundColor Green
  Write-Host "Branch: $branch" -ForegroundColor Green
}

function Invoke-ListWorktrees {
  param([string]$Root)

  & git -C $Root worktree list
  if ($LASTEXITCODE -ne 0) {
    throw "git worktree list failed with exit code $LASTEXITCODE."
  }
}

function Invoke-RemoveWorktree {
  param([string]$Root)

  if (-not $Force) {
    throw 'Refusing to remove a worktree without -Force.'
  }

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  Assert-Id -Value $TaskId -Name 'TaskId'

  $relativeWorktree = Get-RelativeWorktreePath -Id $FeatureId -Task $TaskId
  $worktreeRoot = Join-Path $Root '.worktrees'
  $worktreePath = Join-Path $Root ($relativeWorktree -replace '/', '\')
  $resolvedWorktreeRoot = [System.IO.Path]::GetFullPath($worktreeRoot)
  $resolvedWorktreePath = [System.IO.Path]::GetFullPath($worktreePath)

  if (-not $resolvedWorktreePath.StartsWith($resolvedWorktreeRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove path outside .worktrees: $resolvedWorktreePath"
  }

  & git -C $Root worktree remove $worktreePath --force
  if ($LASTEXITCODE -ne 0) {
    throw "git worktree remove failed with exit code $LASTEXITCODE."
  }

  Write-Host "Removed worktree: $relativeWorktree" -ForegroundColor Green
}

function Invoke-ValidateWorktree {
  param([string]$Root)

  if (-not [string]::IsNullOrWhiteSpace($FeatureId)) {
    Assert-Id -Value $FeatureId -Name 'FeatureId'
  }

  $gitignore = Join-Path $Root '.gitignore'
  $gitignoreLines = if (Test-Path -LiteralPath $gitignore) { @(Get-Content -LiteralPath $gitignore) } else { @() }
  if ($gitignoreLines -notcontains '.worktrees/') {
    throw '.worktrees/ is not listed in .gitignore.'
  }

  if ([string]::IsNullOrWhiteSpace($FeatureId)) {
    Write-Host 'Worktree validation passed: .worktrees/ is ignored.' -ForegroundColor Green
    return
  }

  $state = Get-StatePaths -Root $Root -Id $FeatureId
  $tasks = @(Get-TaskArray -Path $state.TasksFile)
  if (-not [string]::IsNullOrWhiteSpace($TaskId)) {
    Assert-Id -Value $TaskId -Name 'TaskId'
    $tasks = @($tasks | Where-Object { $_.id -eq $TaskId })
  }

  foreach ($task in $tasks) {
    if ([string]::IsNullOrWhiteSpace($task.worktreePath)) {
      throw "Task '$($task.id)' does not have a worktreePath."
    }
    if ([string]::IsNullOrWhiteSpace($task.branch)) {
      throw "Task '$($task.id)' does not have a branch."
    }
  }

  Write-Host "Worktree validation passed for $FeatureId." -ForegroundColor Green
}

if ($Help -or [string]::IsNullOrWhiteSpace($Command)) {
  Show-Usage
  exit 0
}

$root = Get-RepoRoot

switch ($Command.ToLowerInvariant()) {
  'create' { Invoke-CreateWorktree -Root $root }
  'list' { Invoke-ListWorktrees -Root $root }
  'remove' { Invoke-RemoveWorktree -Root $root }
  'validate' { Invoke-ValidateWorktree -Root $root }
  default {
    Show-Usage
    throw "Unsupported command: $Command"
  }
}
