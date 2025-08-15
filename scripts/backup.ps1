# Claude Code Configuration Backup Script
# Creates a complete timestamped backup of the production configuration

param(
    [string]$BackupPath = ".\backups",
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
        if (Test-Path $Path) {
            $ProductionPath = $Path
            break
        }
    }
    
    if (-not $ProductionPath) {
        $ProductionPath = $WindowsPaths[0]  # Default to first option
    }
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupName = "claude-config-backup-$Timestamp"
$FullBackupPath = Join-Path $BackupPath $BackupName

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    Write-Host "Created backup directory: $BackupPath" -ForegroundColor Green
}

# Check if production directory exists
if (-not (Test-Path $ProductionPath)) {
    Write-Host "Warning: Production directory not found at $ProductionPath" -ForegroundColor Yellow
    Write-Host "This might be the first deployment." -ForegroundColor Yellow
    exit 0
}

try {
    Write-Host "Starting backup of Claude Code configuration..." -ForegroundColor Cyan
    Write-Host "Source: $ProductionPath" -ForegroundColor Gray
    Write-Host "Destination: $FullBackupPath" -ForegroundColor Gray
    
    # Create timestamped backup directory
    New-Item -ItemType Directory -Path $FullBackupPath -Force | Out-Null
    
    # Copy entire .claude directory with all subdirectories and files
    Copy-Item -Path "$ProductionPath\*" -Destination $FullBackupPath -Recurse -Force
    
    # Create backup metadata
    $BackupInfo = @{
        timestamp = $Timestamp
        source = $ProductionPath
        backup_path = $FullBackupPath
        files_backed_up = (Get-ChildItem -Path $FullBackupPath -Recurse | Measure-Object).Count
        backup_size_mb = [math]::Round((Get-ChildItem -Path $FullBackupPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    }
    
    $BackupInfo | ConvertTo-Json -Depth 3 | Out-File -FilePath "$FullBackupPath\backup-info.json"
    
    Write-Host "✓ Backup completed successfully!" -ForegroundColor Green
    Write-Host "  Files backed up: $($BackupInfo.files_backed_up)" -ForegroundColor Gray
    Write-Host "  Backup size: $($BackupInfo.backup_size_mb) MB" -ForegroundColor Gray
    Write-Host "  Backup location: $FullBackupPath" -ForegroundColor Gray
    
    # Clean old backups (keep last 10)
    $AllBackups = Get-ChildItem -Path $BackupPath -Directory | 
                  Where-Object { $_.Name -like "claude-config-backup-*" } |
                  Sort-Object CreationTime -Descending
    
    if ($AllBackups.Count -gt 10) {
        $OldBackups = $AllBackups | Select-Object -Skip 10
        foreach ($OldBackup in $OldBackups) {
            Remove-Item -Path $OldBackup.FullName -Recurse -Force
            Write-Host "Cleaned old backup: $($OldBackup.Name)" -ForegroundColor Yellow
        }
    }
    
    # Return backup path for deployment script
    return $FullBackupPath
    
} catch {
    Write-Host "✗ Backup failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}