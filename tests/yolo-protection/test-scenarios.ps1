# Tests complets du hook YOLO Protection

Write-Host "=== Tests Complets YOLO Protection ===" -ForegroundColor Cyan

# Test 1: Sans mode YOLO
Write-Host "`n--- Test 1: Sans mode YOLO ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = $null
$result1 = & ".\yolo-protection-test.ps1" "rm -rf /important/data"
Write-Host "Résultat: Exit code = $LASTEXITCODE" -ForegroundColor Gray

# Test 2: Avec mode YOLO - commande dangereuse
Write-Host "`n--- Test 2: Mode YOLO + commande dangereuse ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
$result2 = & ".\yolo-protection-test.ps1" "rm -rf /important/data"
Write-Host "Résultat: Exit code = $LASTEXITCODE" -ForegroundColor Gray

# Test 3: Avec mode YOLO - commande sûre
Write-Host "`n--- Test 3: Mode YOLO + commande sûre ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
$result3 = & ".\yolo-protection-test.ps1" "list files in directory"
Write-Host "Résultat: Exit code = $LASTEXITCODE" -ForegroundColor Gray

# Test 4: Avec bypass activé
Write-Host "`n--- Test 4: Mode YOLO + bypass activé ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
$env:CLAUDE_YOLO_BYPASS = "true"
$result4 = & ".\yolo-protection-test.ps1" "rm -rf /important/data"
Write-Host "Résultat: Exit code = $LASTEXITCODE" -ForegroundColor Gray

# Test 5: Patterns PowerShell dangereux
Write-Host "`n--- Test 5: Commande PowerShell dangereuse ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
$env:CLAUDE_YOLO_BYPASS = $null
$result5 = & ".\yolo-protection-test.ps1" "Remove-Item -Path C:\temp -Recurse -Force"
Write-Host "Résultat: Exit code = $LASTEXITCODE" -ForegroundColor Gray

# Test 6: Commandes SQL dangereuses
Write-Host "`n--- Test 6: Commande SQL dangereuse ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
$result6 = & ".\yolo-protection-test.ps1" "DROP DATABASE production"
Write-Host "Résultat: Exit code = $LASTEXITCODE" -ForegroundColor Gray

# Nettoyage
$env:CLAUDE_YOLO_MODE = $null
$env:CLAUDE_YOLO_BYPASS = $null
Write-Host "`n=== Tests terminés ===" -ForegroundColor Cyan