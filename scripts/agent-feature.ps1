param(
  [string]$Command,
  [string]$RootPath,
  [string]$FeatureId,
  [string]$Title,
  [string]$Owner,
  [string]$TaskId,
  [string]$AssignedRole,
  [string[]]$TargetRevitVersions = @(),
  [string[]]$AiTools = @(),
  [string[]]$AllowedPaths = @(),
  [string[]]$ReadOnlyPaths = @(),
  [string[]]$ValidationCommands = @(),
  [string]$Notes,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'

function Show-Usage {
  Write-Host @'
agent-feature.ps1

Commands:
  new            Create feature state and docs folders.
  status         Show feature status, task count, and lock count.
  add-task       Add a task to .agents/state/<feature-id>/tasks.json.
  list-tasks     List tasks for a feature.
  complete-task  Mark a task as completed.
  validate       Validate feature.json, tasks.json, locks.json, and docs folder.

Examples:
  ./scripts/agent-feature.ps1 -Command new -FeatureId mcp-read-tools -Title "MCP read tools" -Owner maycon
  ./scripts/agent-feature.ps1 -Command add-task -FeatureId mcp-read-tools -TaskId task-001 -Title "Define requirements" -AssignedRole requirements-analyst -AllowedPaths docs/features/mcp-read-tools
  ./scripts/agent-feature.ps1 -Command list-tasks -FeatureId mcp-read-tools
  ./scripts/agent-feature.ps1 -Command complete-task -FeatureId mcp-read-tools -TaskId task-001
  ./scripts/agent-feature.ps1 -Command validate -FeatureId mcp-read-tools
'@
}

function Get-RepoRoot {
  if (-not [string]::IsNullOrWhiteSpace($RootPath)) {
    return (Resolve-Path -LiteralPath $RootPath).Path
  }

  return (Split-Path -Parent $PSScriptRoot)
}

function Assert-Id {
  param(
    [string]$Value,
    [string]$Name
  )

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
  $docsRoot = Join-Path $Root (Join-Path 'docs\features' $Id)
  return [pscustomobject]@{
    StateRoot = $stateRoot
    DocsRoot = $docsRoot
    HandoffsRoot = Join-Path $docsRoot 'handoffs'
    FeatureFile = Join-Path $stateRoot 'feature.json'
    TasksFile = Join-Path $stateRoot 'tasks.json'
    LocksFile = Join-Path $stateRoot 'locks.json'
  }
}

function Read-JsonOrDefault {
  param(
    [string]$Path,
    [object]$DefaultValue
  )

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
  param(
    [string]$Path,
    [object]$Value
  )

  $parent = Split-Path -Parent $Path
  New-Item -ItemType Directory -Force -Path $parent | Out-Null
  $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-TaskArray {
  param([string]$Path)

  $tasks = Read-JsonOrDefault -Path $Path -DefaultValue @()
  if ($null -eq $tasks) {
    return @()
  }

  return @($tasks)
}

function Get-BranchName {
  param(
    [string]$Id,
    [string]$Task,
    [string]$Role
  )

  return "ai/$Id/$Task-$Role"
}

function Get-WorktreePath {
  param(
    [string]$Id,
    [string]$Task
  )

  return ".worktrees/$Id/$Task"
}

function Invoke-NewFeature {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  if ([string]::IsNullOrWhiteSpace($Title)) {
    throw 'Title is required.'
  }

  $paths = Get-StatePaths -Root $Root -Id $FeatureId
  $now = (Get-Date).ToUniversalTime().ToString('o')

  if (Test-Path -LiteralPath $paths.FeatureFile) {
    throw "Feature already exists: $FeatureId"
  }

  New-Item -ItemType Directory -Force -Path $paths.StateRoot | Out-Null
  New-Item -ItemType Directory -Force -Path $paths.HandoffsRoot | Out-Null

  $feature = [pscustomobject]@{
    id = $FeatureId
    title = $Title
    status = 'active'
    createdAt = $now
    updatedAt = $now
    owner = $Owner
    targetRevitVersions = @($TargetRevitVersions)
    aiTools = @($AiTools)
    notes = $Notes
  }

  Write-Json -Path $paths.FeatureFile -Value $feature
  Write-Json -Path $paths.TasksFile -Value @()
  Write-Json -Path $paths.LocksFile -Value ([pscustomobject]@{ featureId = $FeatureId; locks = @() })

  $briefPath = Join-Path $paths.DocsRoot 'brief.md'
  $requirementsPath = Join-Path $paths.DocsRoot 'requirements.md'
  if (-not (Test-Path -LiteralPath $briefPath)) {
    "# $Title`r`n`r`n## Summary`r`n" | Set-Content -LiteralPath $briefPath -Encoding UTF8
  }
  if (-not (Test-Path -LiteralPath $requirementsPath)) {
    "# Requirements`r`n`r`n## Acceptance Criteria`r`n" | Set-Content -LiteralPath $requirementsPath -Encoding UTF8
  }

  Write-Host "Created feature: $FeatureId" -ForegroundColor Green
}

function Invoke-AddTask {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  Assert-Id -Value $TaskId -Name 'TaskId'
  Assert-Id -Value $AssignedRole -Name 'AssignedRole'
  if ([string]::IsNullOrWhiteSpace($Title)) {
    throw 'Title is required.'
  }

  $paths = Get-StatePaths -Root $Root -Id $FeatureId
  if (-not (Test-Path -LiteralPath $paths.FeatureFile)) {
    throw "Feature does not exist: $FeatureId"
  }

  $tasks = @(Get-TaskArray -Path $paths.TasksFile)
  if (@($tasks | Where-Object { $_.id -eq $TaskId }).Count -gt 0) {
    throw "Task already exists: $TaskId"
  }

  $handoffPath = "docs/features/$FeatureId/handoffs/$TaskId.md"
  $task = [pscustomobject]@{
    id = $TaskId
    title = $Title
    assignedRole = $AssignedRole
    branch = (Get-BranchName -Id $FeatureId -Task $TaskId -Role $AssignedRole)
    worktreePath = (Get-WorktreePath -Id $FeatureId -Task $TaskId)
    status = 'planned'
    allowedPaths = @($AllowedPaths)
    readOnlyPaths = @($ReadOnlyPaths)
    validationCommands = @($ValidationCommands)
    handoffPath = $handoffPath
  }

  $tasks = @($tasks + $task)
  Write-Json -Path $paths.TasksFile -Value $tasks

  $handoffFullPath = Join-Path $Root ($handoffPath -replace '/', '\')
  if (-not (Test-Path -LiteralPath $handoffFullPath)) {
    "# Handoff: $TaskId`r`n`r`nStatus: planned`r`n" | Set-Content -LiteralPath $handoffFullPath -Encoding UTF8
  }

  $feature = Read-JsonOrDefault -Path $paths.FeatureFile -DefaultValue $null
  $feature.updatedAt = (Get-Date).ToUniversalTime().ToString('o')
  Write-Json -Path $paths.FeatureFile -Value $feature

  Write-Host "Added task: $TaskId" -ForegroundColor Green
}

function Invoke-Status {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  $paths = Get-StatePaths -Root $Root -Id $FeatureId
  if (-not (Test-Path -LiteralPath $paths.FeatureFile)) {
    throw "Feature does not exist: $FeatureId"
  }

  $feature = Read-JsonOrDefault -Path $paths.FeatureFile -DefaultValue $null
  $tasks = @(Get-TaskArray -Path $paths.TasksFile)
  $locksData = Read-JsonOrDefault -Path $paths.LocksFile -DefaultValue ([pscustomobject]@{ locks = @() })

  Write-Host "Feature: $($feature.id)" -ForegroundColor Cyan
  Write-Host "Title: $($feature.title)"
  Write-Host "Status: $($feature.status)"
  Write-Host "Owner: $($feature.owner)"
  Write-Host "Tasks: $($tasks.Count)"
  Write-Host "Locks: $(@($locksData.locks).Count)"
}

function Invoke-ListTasks {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  $paths = Get-StatePaths -Root $Root -Id $FeatureId
  $tasks = @(Get-TaskArray -Path $paths.TasksFile)

  if ($tasks.Count -eq 0) {
    Write-Host "No tasks found for $FeatureId."
    return
  }

  $tasks | Select-Object id,title,assignedRole,status,branch,worktreePath | Format-Table -AutoSize
}

function Invoke-CompleteTask {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  Assert-Id -Value $TaskId -Name 'TaskId'
  $paths = Get-StatePaths -Root $Root -Id $FeatureId
  $tasks = @(Get-TaskArray -Path $paths.TasksFile)
  $task = $tasks | Where-Object { $_.id -eq $TaskId } | Select-Object -First 1
  if ($null -eq $task) {
    throw "Task does not exist: $TaskId"
  }

  $task.status = 'completed'
  Write-Json -Path $paths.TasksFile -Value $tasks

  $feature = Read-JsonOrDefault -Path $paths.FeatureFile -DefaultValue $null
  $feature.updatedAt = (Get-Date).ToUniversalTime().ToString('o')
  Write-Json -Path $paths.FeatureFile -Value $feature

  Write-Host "Completed task: $TaskId" -ForegroundColor Green
}

function Invoke-ValidateFeature {
  param([string]$Root)

  Assert-Id -Value $FeatureId -Name 'FeatureId'
  $paths = Get-StatePaths -Root $Root -Id $FeatureId
  $problems = New-Object System.Collections.Generic.List[string]

  foreach ($requiredPath in @($paths.FeatureFile, $paths.TasksFile, $paths.LocksFile, $paths.DocsRoot, $paths.HandoffsRoot)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
      $problems.Add("Missing: $requiredPath") | Out-Null
    }
  }

  if (Test-Path -LiteralPath $paths.FeatureFile) {
    $feature = Read-JsonOrDefault -Path $paths.FeatureFile -DefaultValue $null
    foreach ($field in @('id','title','status','createdAt','updatedAt','owner','targetRevitVersions','aiTools','notes')) {
      if (-not ($feature.PSObject.Properties.Name -contains $field)) {
        $problems.Add("feature.json is missing '$field'.") | Out-Null
      }
    }
  }

  if (Test-Path -LiteralPath $paths.TasksFile) {
    $tasks = @(Get-TaskArray -Path $paths.TasksFile)
    foreach ($task in $tasks) {
      foreach ($field in @('id','title','assignedRole','branch','worktreePath','status','allowedPaths','readOnlyPaths','validationCommands','handoffPath')) {
        if (-not ($task.PSObject.Properties.Name -contains $field)) {
          $problems.Add("Task '$($task.id)' is missing '$field'.") | Out-Null
        }
      }
    }
  }

  if ($problems.Count -gt 0) {
    Write-Host "Feature validation failed." -ForegroundColor Red
    foreach ($problem in $problems) {
      Write-Host "  ERROR $problem" -ForegroundColor Red
    }
    exit 1
  }

  Write-Host "Feature validation passed: $FeatureId" -ForegroundColor Green
}

if ($Help -or [string]::IsNullOrWhiteSpace($Command)) {
  Show-Usage
  exit 0
}

$root = Get-RepoRoot

switch ($Command.ToLowerInvariant()) {
  'new' { Invoke-NewFeature -Root $root }
  'status' { Invoke-Status -Root $root }
  'add-task' { Invoke-AddTask -Root $root }
  'list-tasks' { Invoke-ListTasks -Root $root }
  'complete-task' { Invoke-CompleteTask -Root $root }
  'validate' { Invoke-ValidateFeature -Root $root }
  default {
    Show-Usage
    throw "Unsupported command: $Command"
  }
}
