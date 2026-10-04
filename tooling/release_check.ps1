$ErrorActionPreference = 'Stop'

$manifest = Get-Content (Join-Path $PSScriptRoot '..\android\app\src\main\AndroidManifest.xml') -Raw
if ($manifest -match 'android\.permission\.INTERNET') {
  throw 'Release manifest must not request INTERNET.'
}

$gradle = Get-Content (Join-Path $PSScriptRoot '..\android\app\build.gradle.kts') -Raw
if ($gradle -notmatch 'targetSdk\s*=\s*36') {
  throw 'Android targetSdk must remain explicitly set to 36 or higher.'
}

Write-Host 'Release configuration passed: no INTERNET permission and targetSdk 36.'
