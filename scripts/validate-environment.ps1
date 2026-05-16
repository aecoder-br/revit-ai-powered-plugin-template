param(
  [switch]$RequireFull,
  [string[]]$RequireRevitVersions = @(),
  [switch]$RequireDotNet10,
  [string]$JsonOutput
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$checks = New-Object System.Collections.Generic.List[object]
$baselineFailed = $false
$fullFailed = $false

function Add-Check {
  param(
    [string]$Check,
    [ValidateSet('Passed','Warning','Failed','Optional')]
    [string]$Status,
    [string]$DetectedValue,
    [string]$Remediation,
    [switch]$BaselineRequired,
    [switch]$FullRequired
  )

  $script:checks.Add([pscustomobject]@{
    Check = $Check
    Status = $Status
    'Detected value' = $DetectedValue
    Remediation = $Remediation
  }) | Out-Null

  if ($Status -eq 'Failed' -and $BaselineRequired) {
    $script:baselineFailed = $true
  }

  if ($Status -eq 'Failed' -and $FullRequired) {
    $script:fullFailed = $true
  }
}

function Get-CommandVersion {
  param([string]$CommandName)

  $command = Get-Command $CommandName -ErrorAction SilentlyContinue
  if ($null -eq $command) {
    return $null
  }

  return $command
}

function Test-RegistryValue {
  param(
    [string]$Path,
    [string]$Name
  )

  try {
    $item = Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction Stop
    return $item.$Name
  } catch {
    return $null
  }
}

function Test-DirectoryExists {
  param([string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path)) {
    return $false
  }

  return Test-Path -LiteralPath $Path -PathType Container
}

function Find-RevitInstallPath {
  param([string]$Version)

  $candidates = @()
  if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
    $candidates += Join-Path $env:ProgramFiles "Autodesk\Revit $Version"
  }
  if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
    $candidates += Join-Path ${env:ProgramFiles(x86)} "Autodesk\Revit $Version"
  }

  foreach ($candidate in $candidates) {
    if (Test-DirectoryExists -Path $candidate) {
      return $candidate
    }
  }

  return $null
}

function Test-DotNetSdkMajor {
  param(
    [string[]]$Sdks,
    [string]$Major
  )

  foreach ($sdk in $Sdks) {
    if ($sdk -match "^$([regex]::Escape($Major))\.") {
      return $true
    }
  }

  return $false
}

function Get-VisualStudioDetection {
  $vswhere = $null
  if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
  }

  if (-not [string]::IsNullOrWhiteSpace($vswhere) -and (Test-Path -LiteralPath $vswhere -PathType Leaf)) {
    try {
      $result = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath 2>$null
      if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($result)) {
        return "vswhere: $result"
      }
    } catch {
      return "vswhere found, query failed: $($_.Exception.Message)"
    }
  }

  $commonPaths = @()
  if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles})) {
    $commonPaths += Join-Path ${env:ProgramFiles} 'Microsoft Visual Studio\2022\Professional'
    $commonPaths += Join-Path ${env:ProgramFiles} 'Microsoft Visual Studio\2022\Enterprise'
    $commonPaths += Join-Path ${env:ProgramFiles} 'Microsoft Visual Studio\2022\Community'
  }

  foreach ($path in $commonPaths) {
    if (Test-DirectoryExists -Path $path) {
      return "directory: $path"
    }
  }

  return $null
}

function Get-WebView2Detection {
  $registryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
  )

  foreach ($path in $registryPaths) {
    try {
      $item = Get-ItemProperty -LiteralPath $path -ErrorAction Stop
      if (-not [string]::IsNullOrWhiteSpace($item.pv)) {
        return "runtime version $($item.pv)"
      }
    } catch {
    }
  }

  if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
    $runtimePath = Join-Path ${env:ProgramFiles(x86)} 'Microsoft\EdgeWebView\Application'
    if (Test-DirectoryExists -Path $runtimePath) {
      return "directory: $runtimePath"
    }
  }

  return $null
}

function Get-SymlinkDetection {
  $developerMode = Test-RegistryValue `
    -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' `
    -Name 'AllowDevelopmentWithoutDevLicense'

  if ($developerMode -eq 1) {
    return 'Developer Mode is enabled.'
  }

  try {
    $privileges = & whoami /priv 2>$null
    if ($LASTEXITCODE -eq 0) {
      $symlinkPrivilege = $privileges | Where-Object { $_ -match 'SeCreateSymbolicLinkPrivilege' }
      if ($symlinkPrivilege) {
        return ($symlinkPrivilege -join '; ').Trim()
      }
    }
  } catch {
  }

  return $null
}

function Get-AddinPathSummary {
  param([string]$Version)

  $paths = @()
  if (-not [string]::IsNullOrWhiteSpace($env:APPDATA)) {
    $paths += Join-Path $env:APPDATA "Autodesk\Revit\Addins\$Version"
  }
  if (-not [string]::IsNullOrWhiteSpace($env:ProgramData)) {
    $paths += Join-Path $env:ProgramData "Autodesk\Revit\Addins\$Version"
  }

  $results = @()
  foreach ($path in $paths) {
    if (Test-DirectoryExists -Path $path) {
      $results += "exists: $path"
    } else {
      $results += "missing: $path"
    }
  }

  return ($results -join '; ')
}

$isWindows = $false
try {
  $isWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
} catch {
  $isWindows = ($env:OS -eq 'Windows_NT')
}

if ($isWindows) {
  Add-Check -Check 'Operating system is Windows' -Status 'Passed' -DetectedValue ([System.Environment]::OSVersion.VersionString) -Remediation 'None.'
} else {
  Add-Check -Check 'Operating system is Windows' -Status 'Failed' -DetectedValue ([System.Environment]::OSVersion.VersionString) -Remediation 'Run validation on Windows.' -BaselineRequired -FullRequired
}

$powerShellVersion = $PSVersionTable.PSVersion.ToString()
Add-Check -Check 'PowerShell version' -Status 'Passed' -DetectedValue $powerShellVersion -Remediation 'Use Windows PowerShell 5.1 or PowerShell 7 if script behavior differs.'

$gitCommand = Get-CommandVersion -CommandName 'git'
if ($null -eq $gitCommand) {
  Add-Check -Check 'Git installed' -Status 'Failed' -DetectedValue 'not found' -Remediation 'Install Git for Windows and ensure git is on PATH.' -BaselineRequired -FullRequired
} else {
  $gitVersion = (& git --version 2>$null) -join ' '
  Add-Check -Check 'Git installed' -Status 'Passed' -DetectedValue $gitVersion -Remediation 'None.'
}

$dotnetCommand = Get-CommandVersion -CommandName 'dotnet'
$dotnetSdks = @()
if ($null -eq $dotnetCommand) {
  Add-Check -Check 'dotnet installed' -Status 'Failed' -DetectedValue 'not found' -Remediation 'Install the required .NET SDKs.' -BaselineRequired -FullRequired
} else {
  $dotnetInfo = (& dotnet --version 2>$null) -join ' '
  Add-Check -Check 'dotnet installed' -Status 'Passed' -DetectedValue $dotnetInfo -Remediation 'None.'
  try {
    $dotnetSdks = @(& dotnet --list-sdks 2>$null)
  } catch {
    $dotnetSdks = @()
  }
}

if (Test-DotNetSdkMajor -Sdks $dotnetSdks -Major '8') {
  Add-Check -Check '.NET SDK 8 installed' -Status 'Passed' -DetectedValue (($dotnetSdks | Where-Object { $_ -match '^8\.' }) -join '; ') -Remediation 'None.'
} else {
  Add-Check -Check '.NET SDK 8 installed' -Status 'Failed' -DetectedValue 'not found' -Remediation 'Install .NET SDK 8 for Revit 2025 and 2026 builds.' -BaselineRequired -FullRequired
}

$dotNet10Required = ($RequireFull -or $RequireDotNet10)
if (Test-DotNetSdkMajor -Sdks $dotnetSdks -Major '10') {
  Add-Check -Check '.NET SDK 10 installed' -Status 'Passed' -DetectedValue (($dotnetSdks | Where-Object { $_ -match '^10\.' }) -join '; ') -Remediation 'None.'
} elseif ($dotNet10Required) {
  Add-Check -Check '.NET SDK 10 installed' -Status 'Failed' -DetectedValue 'not found' -Remediation 'Install .NET SDK 10 for Revit 2027 validation.' -FullRequired
} else {
  Add-Check -Check '.NET SDK 10 installed' -Status 'Warning' -DetectedValue 'not found' -Remediation 'Install .NET SDK 10 before validating Revit 2027 or Public Beta readiness.'
}

$net48Release = Test-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name 'Release'
$net48ReferenceAssemblies = $null
if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
  $net48ReferenceAssemblies = Join-Path ${env:ProgramFiles(x86)} 'Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8'
}
$net48Sdk = $null
if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
  $net48Sdk = Test-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SDKs\NETFXSDK\4.8' -Name 'InstallationFolder'
}

if ($net48Release -ge 528040 -and (Test-DirectoryExists -Path $net48ReferenceAssemblies)) {
  Add-Check -Check '.NET Framework 4.8 Developer Pack' -Status 'Passed' -DetectedValue "Release=$net48Release; references=$net48ReferenceAssemblies" -Remediation 'None.'
} elseif ($RequireFull) {
  Add-Check -Check '.NET Framework 4.8 Developer Pack' -Status 'Failed' -DetectedValue "Release=$net48Release; SDK=$net48Sdk" -Remediation 'Install .NET Framework 4.8 Developer Pack for Revit 2024 builds.' -FullRequired
} else {
  Add-Check -Check '.NET Framework 4.8 Developer Pack' -Status 'Warning' -DetectedValue "Release=$net48Release; SDK=$net48Sdk" -Remediation 'Install .NET Framework 4.8 Developer Pack before validating Revit 2024.'
}

$visualStudio = Get-VisualStudioDetection
if (-not [string]::IsNullOrWhiteSpace($visualStudio)) {
  Add-Check -Check 'Visual Studio installed' -Status 'Passed' -DetectedValue $visualStudio -Remediation 'None.'
} elseif ($RequireFull) {
  Add-Check -Check 'Visual Studio installed' -Status 'Failed' -DetectedValue 'not found' -Remediation 'Install Visual Studio 2022 or newer with .NET desktop workload.' -FullRequired
} else {
  Add-Check -Check 'Visual Studio installed' -Status 'Warning' -DetectedValue 'not found' -Remediation 'Install Visual Studio before validating the native solution/template experience.'
}

$allRevitVersions = @('2024','2025','2026','2027')
if ($RequireFull -and $RequireRevitVersions.Count -eq 0) {
  $RequireRevitVersions = $allRevitVersions
}

foreach ($version in $allRevitVersions) {
  $versionRequired = ($RequireRevitVersions -contains $version)
  $installPath = Find-RevitInstallPath -Version $version
  if (-not [string]::IsNullOrWhiteSpace($installPath)) {
    Add-Check -Check "Revit $version installed" -Status 'Passed' -DetectedValue $installPath -Remediation 'None.'

    $revitApi = Join-Path $installPath 'RevitAPI.dll'
    $revitApiUi = Join-Path $installPath 'RevitAPIUI.dll'
    $missingDlls = @()
    if (-not (Test-Path -LiteralPath $revitApi -PathType Leaf)) {
      $missingDlls += 'RevitAPI.dll'
    }
    if (-not (Test-Path -LiteralPath $revitApiUi -PathType Leaf)) {
      $missingDlls += 'RevitAPIUI.dll'
    }

    if ($missingDlls.Count -eq 0) {
      Add-Check -Check "Revit $version API DLLs" -Status 'Passed' -DetectedValue "$revitApi; $revitApiUi" -Remediation 'None.'
    } else {
      Add-Check -Check "Revit $version API DLLs" -Status 'Failed' -DetectedValue ("missing: $($missingDlls -join ', ') in $installPath") -Remediation "Repair or reinstall Revit $version." -FullRequired:$versionRequired
    }
  } elseif ($versionRequired) {
    Add-Check -Check "Revit $version installed" -Status 'Failed' -DetectedValue 'not found' -Remediation "Install Revit $version or remove it from -RequireRevitVersions for partial validation." -FullRequired
    Add-Check -Check "Revit $version API DLLs" -Status 'Failed' -DetectedValue 'not found' -Remediation "Install Revit $version to provide RevitAPI.dll and RevitAPIUI.dll." -FullRequired
  } else {
    Add-Check -Check "Revit $version installed" -Status 'Warning' -DetectedValue 'not found' -Remediation "Install Revit $version before validating that version."
    Add-Check -Check "Revit $version API DLLs" -Status 'Optional' -DetectedValue 'not checked because Revit is not installed' -Remediation "Install Revit $version to check API DLLs."
  }

  $addinSummary = Get-AddinPathSummary -Version $version
  Add-Check -Check "Revit $version add-in paths" -Status 'Optional' -DetectedValue $addinSummary -Remediation 'Create paths only when installing or smoke-testing add-ins.'
}

$webView2 = Get-WebView2Detection
if (-not [string]::IsNullOrWhiteSpace($webView2)) {
  Add-Check -Check 'WebView2 runtime' -Status 'Passed' -DetectedValue $webView2 -Remediation 'None.'
} else {
  Add-Check -Check 'WebView2 runtime' -Status 'Optional' -DetectedValue 'not found' -Remediation 'Install Microsoft Edge WebView2 Runtime before validating WebView2 UI flows.'
}

$actionlintCommand = Get-CommandVersion -CommandName 'actionlint'
if ($null -eq $actionlintCommand) {
  Add-Check -Check 'actionlint' -Status 'Optional' -DetectedValue 'not found' -Remediation 'Install actionlint for local GitHub Actions linting, or rely on the non-blocking CI job.'
} else {
  $actionlintVersion = (& actionlint -version 2>$null) -join ' '
  Add-Check -Check 'actionlint' -Status 'Passed' -DetectedValue $actionlintVersion -Remediation 'None.'
}

$symlink = Get-SymlinkDetection
if (-not [string]::IsNullOrWhiteSpace($symlink)) {
  Add-Check -Check 'Windows symlink permission' -Status 'Passed' -DetectedValue $symlink -Remediation 'None.'
} else {
  Add-Check -Check 'Windows symlink permission' -Status 'Warning' -DetectedValue 'not detected' -Remediation 'Use copy mode, enable Developer Mode, or run as a user with SeCreateSymbolicLinkPrivilege before testing -Mode Symlink.'
}

Write-Host ''
Write-Host 'Environment validation summary' -ForegroundColor Cyan
Write-Host "Repository: $root" -ForegroundColor DarkGray
Write-Host "Mode: $(if ($RequireFull) { 'Full validation' } else { 'Partial validation' })" -ForegroundColor DarkGray
Write-Host ''

$checks | Format-Table -AutoSize

if (-not [string]::IsNullOrWhiteSpace($JsonOutput)) {
  $jsonPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($JsonOutput)
  $jsonDirectory = Split-Path -Parent $jsonPath
  if (-not [string]::IsNullOrWhiteSpace($jsonDirectory) -and -not (Test-Path -LiteralPath $jsonDirectory)) {
    New-Item -ItemType Directory -Path $jsonDirectory -Force | Out-Null
  }

  $payload = [pscustomobject]@{
    root = $root
    requireFull = [bool]$RequireFull
    requireRevitVersions = $RequireRevitVersions
    requireDotNet10 = [bool]$RequireDotNet10
    baselineFailed = [bool]$baselineFailed
    fullFailed = [bool]$fullFailed
    checks = $checks
  }

  $payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
  Write-Host ''
  Write-Host "JSON output written to $jsonPath" -ForegroundColor Cyan
}

if ($baselineFailed) {
  Write-Host ''
  Write-Host 'Environment validation failed for partial validation.' -ForegroundColor Red
  exit 1
}

if (($RequireFull -or $RequireDotNet10 -or $RequireRevitVersions.Count -gt 0) -and $fullFailed) {
  Write-Host ''
  Write-Host 'Environment validation failed for the requested full requirements.' -ForegroundColor Red
  exit 1
}

Write-Host ''
if ($RequireFull) {
  Write-Host 'Environment validation passed for full validation.' -ForegroundColor Green
} else {
  Write-Host 'Environment validation passed for partial validation. Review warnings before Public Beta sign-off.' -ForegroundColor Green
}

exit 0
