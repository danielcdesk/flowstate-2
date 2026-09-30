$ErrorActionPreference = 'Stop'

Write-Host '== dart format =='
dart format --set-exit-if-changed lib test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== flutter analyze =='
flutter analyze --fatal-infos --fatal-warnings
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== flutter test --coverage =='
flutter test --coverage
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== architecture tests =='
flutter test test/architecture
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
