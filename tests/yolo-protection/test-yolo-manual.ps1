# Test manuel du hook YOLO Protection

Write-Host "=== Test Manuel YOLO Protection Hook ===" -ForegroundColor Cyan

# Test 1: Sans mode YOLO
Write-Host "`n--- Test 1: Sans mode YOLO ---" -ForegroundColor Yellow
Remove-Variable -Name "CLAUDE_YOLO_MODE" -Scope "Env" -ErrorAction SilentlyContinue
& ".\.claude\hooks\user-prompt-submit\yolo-protection.ps1" "rm -rf /important/data"

# Test 2: Avec mode YOLO activé - commande dangereuse
Write-Host "`n--- Test 2: Mode YOLO + commande dangereuse ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
& ".\.claude\hooks\user-prompt-submit\yolo-protection.ps1" "rm -rf /important/data"

# Test 3: Avec mode YOLO activé - commande sûre
Write-Host "`n--- Test 3: Mode YOLO + commande sûre ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
& ".\.claude\hooks\user-prompt-submit\yolo-protection.ps1" "list files in directory"

# Test 4: Avec bypass activé
Write-Host "`n--- Test 4: Mode YOLO + bypass activé ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
$env:CLAUDE_YOLO_BYPASS = "true"
& ".\.claude\hooks\user-prompt-submit\yolo-protection.ps1" "rm -rf /important/data"

# Test 5: Multiples patterns dangereux
Write-Host "`n--- Test 5: Multiples patterns dangereux ---" -ForegroundColor Yellow
$env:CLAUDE_YOLO_MODE = "true"
Remove-Variable -Name "CLAUDE_YOLO_BYPASS" -Scope "Env" -ErrorAction SilentlyContinue
& ".\.claude\hooks\user-prompt-submit\yolo-protection.ps1" "Remove-Item -Path C:\temp -Recurse -Force"

# Nettoyage
Remove-Variable -Name "CLAUDE_YOLO_MODE" -Scope "Env" -ErrorAction SilentlyContinue
Remove-Variable -Name "CLAUDE_YOLO_BYPASS" -Scope "Env" -ErrorAction SilentlyContinue
Write-Host "`n=== Tests terminés ===" -ForegroundColor Cyan