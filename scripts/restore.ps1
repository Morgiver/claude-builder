# Claude Code Configuration Restoration Script
# Restores a previous backup to production in case of deployment issues

param(
    [Parameter(Mandatory=$false)]
    [string]$BackupPath,
    [switch]$ListBackups,
    [switch]$Force,
    [switch]$Verbose
)

# Auto-detect production path with fallback options
$ProductionPath = $null
if ($env:CLAUDE_CONFIG_PATH) {
    $ProductionPath = $env:CLAUDE_CONFIG_PATH
} else {
    # Try default Windows paths in order
    $WindowsPaths = @(
        "$env:USERPROFILE\.claude",
        "$env:APPDATA\claude"
    )
    
    foreach ($Path in $WindowsPaths) {
        if (Test-Path (Split-Path $Path -Parent)) {
            $ProductionPath = $Path
            break
        }
    }
    
    if (-not $ProductionPath) {
        $ProductionPath = $WindowsPaths[0]  # Default to first option
    }
}

$DefaultBackupDir = ".\backups"

# Function to list available backups
function Show-AvailableBackups {
    if (-not (Test-Path $DefaultBackupDir)) {
        Write-Host "No backup directory found at: $DefaultBackupDir" -ForegroundColor Yellow
        return @()
    }
    
    $Backups = Get-ChildItem -Path $DefaultBackupDir -Directory | 
               Where-Object { $_.Name -like "claude-config-backup-*" } |
               Sort-Object CreationTime -Descending
    
    if ($Backups.Count -eq 0) {
        Write-Host "No backups found in: $DefaultBackupDir" -ForegroundColor Yellow
        return @()
    }
    
    Write-Host "Available backups:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Backups.Count; $i++) {
        $Backup = $Backups[$i]
        $InfoPath = Join-Path $Backup.FullName "backup-info.json"
        
        $Size = "Unknown"
        $FileCount = "Unknown"
        if (Test-Path $InfoPath) {
            try {
                $Info = Get-Content $InfoPath -Raw | ConvertFrom-Json
                $Size = "$($Info.backup_size_mb) MB"
                $FileCount = $Info.files_backed_up
            } catch { }
        }
        
        Write-Host "  [$($i+1)] $($Backup.Name)" -ForegroundColor White
        Write-Host "      Created: $($Backup.CreationTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
        Write-Host "      Size: $Size, Files: $FileCount" -ForegroundColor Gray
        Write-Host "      Path: $($Backup.FullName)" -ForegroundColor DarkGray
    }
    
    return $Backups
}

Write-Host "Claude Code Configuration Restoration" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# If ListBackups flag is set, just show backups and exit
if ($ListBackups) {
    Show-AvailableBackups | Out-Null
    exit 0
}

# If no backup path specified, let user choose
if (-not $BackupPath) {
    $AvailableBackups = Show-AvailableBackups
    
    if ($AvailableBackups.Count -eq 0) {
        exit 1
    }
    
    Write-Host "`nSelect backup to restore:" -ForegroundColor Yellow
    $Selection = Read-Host "Enter backup number (1-$($AvailableBackups.Count)) or 'q' to quit"
    
    if ($Selection -eq 'q' -or $Selection -eq 'Q') {
        Write-Host "Restoration cancelled." -ForegroundColor Yellow
        exit 0
    }
    
    try {
        $Index = [int]$Selection - 1
        if ($Index -lt 0 -or $Index -ge $AvailableBackups.Count) {
            throw "Invalid selection"
        }
        $BackupPath = $AvailableBackups[$Index].FullName
    } catch {
        Write-Host "Invalid selection. Please run the script again." -ForegroundColor Red
        exit 1
    }
}

# Validate backup path
if (-not (Test-Path $BackupPath)) {
    Write-Host "✗ Backup not found at: $BackupPath" -ForegroundColor Red
    exit 1
}

# Load backup info if available
$BackupInfo = $null
$InfoPath = Join-Path $BackupPath "backup-info.json"
if (Test-Path $InfoPath) {
    try {
        $BackupInfo = Get-Content $InfoPath -Raw | ConvertFrom-Json
    } catch {
        Write-Host "Warning: Could not read backup info" -ForegroundColor Yellow
    }
}

# Confirm restoration
if (-not $Force) {
    Write-Host "`nRestore configuration:" -ForegroundColor Yellow
    Write-Host "  From: $BackupPath" -ForegroundColor Gray
    Write-Host "  To: $ProductionPath" -ForegroundColor Gray
    
    if ($BackupInfo) {
        Write-Host "  Backup date: $($BackupInfo.timestamp)" -ForegroundColor Gray
        Write-Host "  Files: $($BackupInfo.files_backed_up)" -ForegroundColor Gray
        Write-Host "  Size: $($BackupInfo.backup_size_mb) MB" -ForegroundColor Gray
    }
    
    Write-Host "`n⚠️  This will OVERWRITE the current production configuration!" -ForegroundColor Red
    $Confirm = Read-Host "`nProceed with restoration? (y/N)"
    
    if ($Confirm -ne 'y' -and $Confirm -ne 'Y') {
        Write-Host "Restoration cancelled." -ForegroundColor Yellow
        exit 0
    }
}

try {
    Write-Host "`nRestoring configuration..." -ForegroundColor Cyan
    
    # Create a backup of current state before restoration
    if (Test-Path $ProductionPath) {
        $PreRestoreBackup = ".\backups\pre-restore-backup-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -ItemType Directory -Path $PreRestoreBackup -Force | Out-Null
        Copy-Item -Path "$ProductionPath\*" -Destination $PreRestoreBackup -Recurse -Force
        Write-Host "✓ Current config backed up to: $PreRestoreBackup" -ForegroundColor Green
    }
    
    # Remove current production directory
    if (Test-Path $ProductionPath) {
        Remove-Item -Path $ProductionPath -Recurse -Force
    }
    
    # Create production directory
    New-Item -ItemType Directory -Path $ProductionPath -Force | Out-Null
    
    # Restore from backup (exclude backup-info.json)
    Get-ChildItem -Path $BackupPath | Where-Object { $_.Name -ne "backup-info.json" } | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $ProductionPath -Recurse -Force
    }
    
    # Create restoration log
    $RestorationInfo = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        restored_from = $BackupPath
        destination = $ProductionPath
        pre_restore_backup = $PreRestoreBackup
        restored_files = (Get-ChildItem -Path $ProductionPath -Recurse -File | Measure-Object).Count
    }
    
    $RestorationInfo | ConvertTo-Json -Depth 3 | Out-File -FilePath "$ProductionPath\restoration-log.json"
    
    Write-Host "`n✓ Configuration restored successfully!" -ForegroundColor Green
    Write-Host "  Restored from: $BackupPath" -ForegroundColor Gray
    Write-Host "  Files restored: $($RestorationInfo.restored_files)" -ForegroundColor Gray
    if ($PreRestoreBackup) {
        Write-Host "  Previous config saved to: $PreRestoreBackup" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "✗ Restoration failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}