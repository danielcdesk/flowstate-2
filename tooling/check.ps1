$ErrorActionPreference = 'Stop'

Write-Host '== dart format =='
dart format --set-exit-if-changed lib test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== flutter analyze =='
flutter analyze --fatal-infos --fatal-warnings
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== flutter test --coverage =='
flutter test --coverage --reporter expanded
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== domain coverage (90% minimum) =='
$coverageFile = Join-Path $PSScriptRoot '..\coverage\lcov.info'
if (-not (Test-Path $coverageFile)) {
  throw "Coverage report not found: $coverageFile"
}
$insideDomain = $false
$domainLines = 0
$coveredDomainLines = 0
foreach ($line in Get-Content $coverageFile) {
  if ($line.StartsWith('SF:')) {
    $insideDomain = $line -match '^SF:lib[\\/]+domain[\\/]'
    continue
  }
  if ($insideDomain -and $line.StartsWith('DA:')) {
    $counts = $line.Substring(3).Split(',')
    $domainLines++
    if ([int]$counts[1] -gt 0) { $coveredDomainLines++ }
  }
}
if ($domainLines -eq 0) { throw 'No domain source lines were found in coverage report.' }
$domainCoverage = 100.0 * $coveredDomainLines / $domainLines
Write-Host ('Domain coverage: {0:N1}% ({1}/{2} lines)' -f $domainCoverage, $coveredDomainLines, $domainLines)
if ($domainCoverage -lt 90) { throw 'Domain coverage is below the required 90%.' }

Write-Host '== architecture tests =='
flutter test test/architecture
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
