# Debug du hook YOLO Protection

Write-Host "=== Debug YOLO Protection ===" -ForegroundColor Cyan

# Set variable d'environnement
$env:CLAUDE_YOLO_MODE = "true"
Write-Host "Variable CLAUDE_YOLO_MODE définie: $env:CLAUDE_YOLO_MODE" -ForegroundColor Yellow

# Vérifier si la variable est bien définie dans le script
Write-Host "`nTest de la détection de variable dans le hook:" -ForegroundColor Yellow

# Créer un script de test simple
$TestScript = @'
Write-Host "Debug: Testing env variable detection"
Write-Host "env:CLAUDE_YOLO_MODE = $env:CLAUDE_YOLO_MODE"

if ($env:CLAUDE_YOLO_MODE -eq "true") {
    Write-Host "✅ Variable détectée!" -ForegroundColor Green
} else {
    Write-Host "❌ Variable non détectée" -ForegroundColor Red
}
'@

$TestScript | Out-File -FilePath "temp-test.ps1" -Encoding UTF8
& ".\temp-test.ps1"
Remove-Item "temp-test.ps1"

Write-Host "`nMaintenant test du hook complet:" -ForegroundColor Yellow
& ".\.claude\hooks\user-prompt-submit\yolo-protection.ps1" "rm -rf /test"

# Cleanup
$env:CLAUDE_YOLO_MODE = $null