param(
  [string]$RootPath,
  [switch]$FailOnWarnings,
  [switch]$IncludeMirrors
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RootPath)) {
  $RootPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

$resolvedRoot = (Resolve-Path -LiteralPath $RootPath).Path
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$validatedSkills = New-Object System.Collections.Generic.List[string]

function Get-RelativePath {
  param(
    [string]$BasePath,
    [string]$TargetPath
  )

  $base = [System.IO.Path]::GetFullPath($BasePath).TrimEnd('\')
  $target = [System.IO.Path]::GetFullPath($TargetPath)

  if ($target.StartsWith($base, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $target.Substring($base.Length).TrimStart('\')
  }

  return $target
}

function Add-Error {
  param([string]$Message)
  $errors.Add($Message) | Out-Null
}

function Add-Warning {
  param([string]$Message)
  $warnings.Add($Message) | Out-Null
}

function ConvertFrom-SimpleYamlFrontMatter {
  param([string]$SkillPath)

  $lines = @(Get-Content -LiteralPath $SkillPath)
  $result = @{
    IsValid = $false
    Values = @{}
  }

  if ($lines.Count -eq 0 -or $lines[0].Trim() -ne '---') {
    return $result
  }

  $endIndex = -1
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -eq '---') {
      $endIndex = $i
      break
    }
  }

  if ($endIndex -lt 0) {
    return $result
  }

  $values = @{}
  for ($i = 1; $i -lt $endIndex; $i++) {
    $line = $lines[$i]
    if ($line -match '^([A-Za-z0-9_-]+):\s*(.*)$') {
      $key = $Matches[1]
      $value = $Matches[2].Trim()

      if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
        $value = $value.Substring(1, $value.Length - 2)
      }

      $values[$key] = $value
    }
  }

  $result.IsValid = $true
  $result.Values = $values
  return $result
}

function Test-SkillContent {
  param(
    [string]$SkillPath,
    [string]$RelativeSkillPath
  )

  $lines = @(Get-Content -LiteralPath $SkillPath)

  $criticalPatterns = @(
    @{ Pattern = '(?i)\b(api[_-]?key|secret[_-]?key|access[_-]?token|refresh[_-]?token|client[_-]?secret|password|senha)\b\s*[:=]'; Reason = 'possible secret assignment' },
    @{ Pattern = '(?i)\b(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{20,}|AKIA[0-9A-Z]{16})\b'; Reason = 'possible API key or token value' },
    @{ Pattern = '(?i)\b(exfiltrate|exfiltration|exfiltrar|steal data|upload secrets|send confidential|leak credentials)\b'; Reason = 'possible data exfiltration instruction' }
  )

  for ($i = 0; $i -lt $lines.Count; $i++) {
    $lineNumber = $i + 1
    $line = $lines[$i]

    foreach ($entry in $criticalPatterns) {
      if ($line -match $entry.Pattern) {
        Add-Error "${RelativeSkillPath}:$lineNumber contains $($entry.Reason)."
      }
    }

    if ($line -match '(?i)\b(rm\s+-rf|git\s+reset\s+--hard|Remove-Item\b.*-Recurse|rmdir\b.*\s/s|del\b.*\s/s|format\s+[A-Z]:)') {
      if ($line -notmatch '(?i)\b(confirm|confirmation|confirmed|approval|explicit consent|user approval|with approval)\b') {
        Add-Error "${RelativeSkillPath}:$lineNumber contains a destructive command without confirmation language."
      }
    }

    if ($RelativeSkillPath -match '\.md$' -and $line.Length -gt 160) {
      Add-Warning "${RelativeSkillPath}:$lineNumber has a long Markdown line ($($line.Length) characters)."
    }
  }
}

function Test-SkillScripts {
  param(
    [string]$SkillDirectory,
    [string]$RelativeSkillDirectory
  )

  $scriptExtensions = @('.ps1', '.psm1', '.psd1', '.sh', '.bash', '.cmd', '.bat', '.py', '.js', '.mjs', '.cjs', '.ts', '.rb', '.pl')
  $allowedDomains = @(
    'github.com',
    'raw.githubusercontent.com',
    'learn.microsoft.com',
    'docs.microsoft.com',
    'dotnet.microsoft.com',
    'nuget.org',
    'api.nuget.org',
    'autodesk.com',
    'aps.autodesk.com',
    'developer.api.autodesk.com'
  )

  $files = @(Get-ChildItem -LiteralPath $SkillDirectory -Recurse -File -Force)
  foreach ($file in $files) {
    $relativeFile = Get-RelativePath -BasePath $SkillDirectory -TargetPath $file.FullName
    $relativeRepoFile = Get-RelativePath -BasePath $resolvedRoot -TargetPath $file.FullName
    $extension = $file.Extension.ToLowerInvariant()

    if ($scriptExtensions -contains $extension) {
      if (-not ($relativeFile -like 'scripts\*')) {
        Add-Error "$relativeRepoFile is a script file outside the skill scripts/ directory."
      }

      $content = Get-Content -Raw -LiteralPath $file.FullName

      $downloadMatches = [regex]::Matches($content, '(?i)\b(Invoke-WebRequest|curl)\b[^\r\n]*(https?://[^\s''"`>)]+)')
      foreach ($match in $downloadMatches) {
        $url = $match.Groups[2].Value
        try {
          $uri = [System.Uri]$url
          $hostName = $uri.Host.ToLowerInvariant()
          if ($allowedDomains -notcontains $hostName) {
            Add-Warning "$relativeRepoFile calls $($match.Groups[1].Value) for unknown domain '$hostName'."
          }
        } catch {
          Add-Warning "$relativeRepoFile contains $($match.Groups[1].Value) with an unparseable URL."
        }
      }

      if ($content -match '(?i)\b(rm\s+-rf|Remove-Item\b[\s\S]{0,120}-Recurse|rmdir\b[^\r\n]*\s/s|del\b[^\r\n]*\s/s)\b') {
        Add-Warning "$relativeRepoFile contains recursive removal; review confirmation and path guards."
      }

      if ($content -match '(?i)\b(AppData|ProgramData|USERPROFILE|HOME|C:\\Users\\|Documents\\|Desktop\\|Downloads\\)\b') {
        Add-Warning "$relativeRepoFile accesses user or machine data paths; verify it stays within the intended repo/task scope."
      }
    }

    if ($extension -eq '.md') {
      $lines = @(Get-Content -LiteralPath $file.FullName)
      for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Length -gt 160) {
          Add-Warning "${relativeRepoFile}:$($i + 1) has a long Markdown line ($($lines[$i].Length) characters)."
        }
      }
    }
  }
}

function Test-SkillDirectory {
  param(
    [string]$SkillDirectory,
    [string]$SkillsRoot
  )

  $folderName = Split-Path -Leaf $SkillDirectory
  $relativeSkillDirectory = Get-RelativePath -BasePath $resolvedRoot -TargetPath $SkillDirectory
  $skillPath = Join-Path $SkillDirectory 'SKILL.md'

  if (-not (Test-Path -LiteralPath $skillPath)) {
    Add-Error "$relativeSkillDirectory is missing SKILL.md."
    return
  }

  $relativeSkillPath = Get-RelativePath -BasePath $resolvedRoot -TargetPath $skillPath
  $frontMatter = ConvertFrom-SimpleYamlFrontMatter -SkillPath $skillPath

  if (-not $frontMatter.IsValid) {
    Add-Error "$relativeSkillPath is missing valid YAML frontmatter delimited by ---."
    return
  }

  $name = $frontMatter.Values['name']
  $description = $frontMatter.Values['description']

  if ([string]::IsNullOrWhiteSpace($name)) {
    Add-Error "$relativeSkillPath frontmatter is missing name."
  }

  if ([string]::IsNullOrWhiteSpace($description)) {
    Add-Error "$relativeSkillPath frontmatter is missing description."
  }

  if (-not [string]::IsNullOrWhiteSpace($name)) {
    if ($folderName -eq '_template') {
      if ($name -ne 'skill-name') {
        Add-Error "$relativeSkillPath template name must remain the placeholder 'skill-name'."
      }
    } else {
      if ($name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
        Add-Error "$relativeSkillPath name '$name' is not lowercase-kebab-case."
      }

      if ($name.Length -gt 64) {
        Add-Error "$relativeSkillPath name '$name' is longer than 64 characters."
      }

      if ($name -ne $folderName) {
        Add-Error "$relativeSkillPath name '$name' must match folder '$folderName'."
      }
    }
  }

  if (-not [string]::IsNullOrWhiteSpace($description)) {
    if ($description.Length -gt 1024) {
      Add-Error "$relativeSkillPath description is longer than 1024 characters."
    }

    if ($description -notmatch '(?i)\b(use|when|used for|use for|trigger|invoke|invoked|should be used)\b') {
      Add-Error "$relativeSkillPath description must mention when to use the skill."
    }
  }

  Test-SkillContent -SkillPath $skillPath -RelativeSkillPath $relativeSkillPath
  Test-SkillScripts -SkillDirectory $SkillDirectory -RelativeSkillDirectory $relativeSkillDirectory
  $validatedSkills.Add($relativeSkillDirectory) | Out-Null
}

Write-Host "Validating agent skills under $resolvedRoot" -ForegroundColor Cyan

$skillRoots = New-Object System.Collections.Generic.List[string]
$skillRoots.Add((Join-Path $resolvedRoot '.agents\skills')) | Out-Null

$mirrorRoots = @(
  (Join-Path $resolvedRoot '.claude\skills'),
  (Join-Path $resolvedRoot '.cursor\skills')
)

foreach ($mirrorRoot in $mirrorRoots) {
  if ((Test-Path -LiteralPath $mirrorRoot) -or $IncludeMirrors) {
    $skillRoots.Add($mirrorRoot) | Out-Null
  }
}

foreach ($skillRoot in $skillRoots) {
  $relativeSkillRoot = Get-RelativePath -BasePath $resolvedRoot -TargetPath $skillRoot

  if (-not (Test-Path -LiteralPath $skillRoot)) {
    Write-Host "Skipping missing skills root: $relativeSkillRoot" -ForegroundColor DarkGray
    continue
  }

  Write-Host "Scanning $relativeSkillRoot" -ForegroundColor Cyan
  $skillDirectories = @(Get-ChildItem -LiteralPath $skillRoot -Directory -Force)

  foreach ($skillDirectory in $skillDirectories) {
    Test-SkillDirectory -SkillDirectory $skillDirectory.FullName -SkillsRoot $skillRoot
  }
}

Write-Host ''
Write-Host "Validated skills: $($validatedSkills.Count)" -ForegroundColor Cyan
foreach ($skill in $validatedSkills) {
  Write-Host "  OK  $skill" -ForegroundColor Green
}

if ($warnings.Count -gt 0) {
  Write-Host ''
  Write-Host "Warnings: $($warnings.Count)" -ForegroundColor Yellow
  foreach ($warning in $warnings) {
    Write-Host "  WARN  $warning" -ForegroundColor Yellow
  }
}

if ($errors.Count -gt 0) {
  Write-Host ''
  Write-Host "Errors: $($errors.Count)" -ForegroundColor Red
  foreach ($errorItem in $errors) {
    Write-Host "  ERROR $errorItem" -ForegroundColor Red
  }
  exit 1
}

if ($FailOnWarnings -and $warnings.Count -gt 0) {
  Write-Host ''
  Write-Host 'Failing because -FailOnWarnings was specified.' -ForegroundColor Red
  exit 1
}

Write-Host ''
Write-Host 'Agent skill validation passed.' -ForegroundColor Green
exit 0
