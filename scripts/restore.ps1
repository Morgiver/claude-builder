# Claude Code Configuration Restoration Script
# Restores a previous backup to production in case of deployment issues

param(
    [Parameter(Mandatory=$false)]
    [string]$BackupPath,
    [switch]$ListBackups,
    [switch]$Force
)

# Default to Force mode to avoid interactive prompts
if (-not $PSBoundParameters.ContainsKey('Force')) {
    $Force = $true
}

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
    Write-Host "ERROR: Backup not found at: $BackupPath" -ForegroundColor Red
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
    
    Write-Host "`nWARNING: This will OVERWRITE the current production configuration!" -ForegroundColor Red
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
        Write-Host "Current config backed up to: $PreRestoreBackup" -ForegroundColor Green
    }
    
    # Remove current production directory
    if (Test-Path $ProductionPath) {
        Remove-Item -Path $ProductionPath -Recurse -Force
    }
    
    # Create production directory
    New-Item -ItemType Directory -Path $ProductionPath -Force | Out-Null
    
    # Restore from backup (exclude backup metadata files)
    Get-ChildItem -Path $BackupPath | Where-Object { $_.Name -notlike "backup-*" } | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $ProductionPath -Recurse -Force
    }
    
    # Verify integrity if manifest exists
    $ManifestPath = Join-Path $BackupPath "backup-manifest.txt"
    if (Test-Path $ManifestPath) {
        Write-Host "Verifying file integrity using MD5 manifest..." -ForegroundColor Cyan
        $VerificationFailed = $false
        $VerifiedCount = 0
        $FailedCount = 0
        $MissingCount = 0
        
        try {
            $ManifestLines = Get-Content $ManifestPath | Where-Object { $_ -and -not $_.StartsWith("#") }
            
            foreach ($Line in $ManifestLines) {
                if ($Line -match "^([a-f0-9]+)\s+(.+)$") {
                    $ExpectedHash = $Matches[1]
                    $RelativeFilePath = $Matches[2] -replace "^\./", ""
                    $FullFilePath = Join-Path $ProductionPath $RelativeFilePath.Replace("/", "\")
                    
                    if (Test-Path $FullFilePath) {
                        try {
                            $CurrentHash = (Get-FileHash -Path $FullFilePath -Algorithm MD5).Hash.ToLower()
                            
                            if ($ExpectedHash -eq $CurrentHash) {
                                $VerifiedCount++
                            } else {
                                Write-Host "  ERROR: Integrity check failed for: $RelativeFilePath" -ForegroundColor Red
                                Write-Host "    Expected: $ExpectedHash" -ForegroundColor Red
                                Write-Host "    Found:    $CurrentHash" -ForegroundColor Red
                                $VerificationFailed = $true
                                $FailedCount++
                            }
                        } catch {
                            Write-Host "  WARNING: Could not verify: $RelativeFilePath" -ForegroundColor Yellow
                            $FailedCount++
                        }
                    } else {
                        Write-Host "  WARNING: Missing file: $RelativeFilePath" -ForegroundColor Yellow
                        $MissingCount++
                    }
                }
            }
            
            # Summary of verification
            Write-Host "Integrity verification summary:" -ForegroundColor Cyan
            Write-Host "  Verified: $VerifiedCount files" -ForegroundColor Green
            if ($FailedCount -gt 0) { Write-Host "  Failed: $FailedCount files" -ForegroundColor Red }
            if ($MissingCount -gt 0) { Write-Host "  Missing: $MissingCount files" -ForegroundColor Yellow }
            
            if ($VerificationFailed -or $MissingCount -gt 0) {
                Write-Host "WARNING: Integrity verification found issues!" -ForegroundColor Red
                Write-Host "Restore completed but some files may be corrupted or missing." -ForegroundColor Yellow
            } else {
                Write-Host "All files passed integrity verification" -ForegroundColor Green
            }
        } catch {
            Write-Host "ERROR: Error during integrity verification: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "WARNING: No integrity manifest found - skipping verification" -ForegroundColor Yellow
        Write-Host "  (Manifest would be available if backup was created with MD5 support)" -ForegroundColor Gray
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
    
    Write-Host "`nConfiguration restored successfully!" -ForegroundColor Green
    Write-Host "  Restored from: $BackupPath" -ForegroundColor Gray
    Write-Host "  Files restored: $($RestorationInfo.restored_files)" -ForegroundColor Gray
    
    # Clean up pre-restore backup since restoration was successful
    if ($PreRestoreBackup -and (Test-Path $PreRestoreBackup)) {
        Remove-Item -Path $PreRestoreBackup -Recurse -Force
        Write-Host "  Cleaned up temporary pre-restore backup" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "ERROR: Restoration failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}