# YOLO Mode Protection Hook (PowerShell)
# Protège contre les commandes de suppression dangereuses en mode YOLO

Write-Host "🛡️  YOLO Protection: Scanning for dangerous commands..." -ForegroundColor Yellow

# Lire le prompt depuis les arguments ou pipeline
$Prompt = $args -join " "
if (-not $Prompt -and -not [Console]::IsInputRedirected) {
    $Prompt = $input | Out-String
}

# Vérifier si Claude est lancé avec --dangerously-skip-permissions
$YoloMode = $false
try {
    $ClaudeProcesses = Get-Process -Name "claude*" -ErrorAction SilentlyContinue
    foreach ($Process in $ClaudeProcesses) {
        $CommandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($Process.Id)").CommandLine
        if ($CommandLine -match "--dangerously-skip-permissions") {
            $YoloMode = $true
            break
        }
    }
} catch {
    # Fallback: vérifier la variable d'environnement pour les tests
    if ($env:CLAUDE_YOLO_MODE -eq "true") {
        $YoloMode = $true
    }
}

if (-not $YoloMode) {
    Write-Host "✅ Hook: Not in YOLO mode (--dangerously-skip-permissions), protection inactive" -ForegroundColor Green
    exit 0
}

Write-Host "🚨 YOLO MODE DETECTED - Protection active" -ForegroundColor Red

# Patterns de commandes dangereuses
$DangerousPatterns = @(
    "rm -rf",
    "rm -r",
    "rmdir",
    "del /s",
    "rd /s",
    "Remove-Item.*-Recurse",
    "Get-ChildItem.*Remove-Item",
    "Remove-Item.*-Force",
    "Clear-Host",
    "Clear-Content",
    "format",
    "diskpart",
    "cipher /w",
    "sdelete",
    "git reset --hard HEAD",
    "git clean -fd",
    "docker system prune -a",
    "kubectl delete",
    "terraform destroy",
    "DROP DATABASE",
    "DROP TABLE",
    "TRUNCATE TABLE",
    "DELETE FROM.*WHERE",
    "Stop-Computer",
    "Restart-Computer",
    "Remove-Computer",
    "Disable-Computer"
)

# Vérifier les patterns dangereux
$FoundDangerous = $false
foreach ($Pattern in $DangerousPatterns) {
    if ($Prompt -match $Pattern) {
        Write-Host "🚨 DANGEROUS COMMAND DETECTED: $Pattern" -ForegroundColor Red
        $FoundDangerous = $true
    }
}

# Si commande dangereuse détectée
if ($FoundDangerous) {
    Write-Host ""
    Write-Host "❌ YOLO PROTECTION: Dangerous deletion command detected!" -ForegroundColor Red
    Write-Host "🛡️  This command could cause irreversible data loss." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  1. Disable YOLO mode: `$env:CLAUDE_YOLO_MODE = `$null" -ForegroundColor White
    Write-Host "  2. Bypass protection: `$env:CLAUDE_YOLO_BYPASS = 'true'" -ForegroundColor White
    Write-Host "  3. Review and modify your request" -ForegroundColor White
    Write-Host ""
    
    # Vérifier si bypass est activé
    if ($env:CLAUDE_YOLO_BYPASS -eq "true") {
        Write-Host "⚠️  BYPASS ACTIVE - Allowing dangerous command" -ForegroundColor Yellow
        Write-Host "🔄 Resetting bypass flag..." -ForegroundColor Cyan
        $env:CLAUDE_YOLO_BYPASS = $null
        exit 0
    }
    
    $Response = Read-Host "Do you want to proceed anyway? (type 'DANGEROUS' to confirm)"
    if ($Response -ne "DANGEROUS") {
        Write-Host "❌ Hook: Execution blocked for safety" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "⚠️  User confirmed dangerous operation" -ForegroundColor Yellow
    }
}

# Success
Write-Host "✅ Hook: YOLO protection check passed" -ForegroundColor Green
exit 0