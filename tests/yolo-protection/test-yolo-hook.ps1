# Script de test pour le hook YOLO Protection

Write-Host "=== Test YOLO Protection Hook ===" -ForegroundColor Cyan

# Test 1: Sans mode YOLO
Write-Host "`n--- Test 1: Sans mode YOLO ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = $null
& ".\.claude\hooks\user-prompt-submit\yolo-protection.ps1" "rm -rf /important/data"

# Test 2: Avec mode YOLO activé - commande dangereuse
Write-Host "`n--- Test 2: Mode YOLO + commande dangereuse ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
& ".\.claude\hooks\user-prompt-submit\yolo-protection.ps1" "rm -rf /important/data"

# Test 3: Avec mode YOLO activé - commande sûre
Write-Host "`n--- Test 3: Mode YOLO + commande sûre ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
& ".\.claude\hooks\user-prompt-submit\yolo-protection.ps1" "list files in directory"

# Nettoyage
$env:CLAUDE_YOLO_MODE = $null
Write-Host "`n=== Tests terminés ===" -ForegroundColor Cyan