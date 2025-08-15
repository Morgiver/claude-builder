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
    
    foreach ($path in $WindowsPaths) {
        if (Test-Path $path) {
            $ProductionPath = $path
            break
        }
    }
    
    # Default to first option if none found
    if (-not $ProductionPath) {
        $ProductionPath = $WindowsPaths[0]
    }
}

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    Write-Host "Created backup directory: $BackupPath" -ForegroundColor Green
}

# Generate timestamp and backup name
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupName = "claude-config-backup-$Timestamp"
$FullBackupPath = Join-Path $BackupPath $BackupName

# Check if production directory exists
if (-not (Test-Path $ProductionPath)) {
    Write-Host "Warning: Production directory not found at $ProductionPath" -ForegroundColor Yellow
    Write-Host "Creating empty backup for deployment..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $FullBackupPath -Force | Out-Null
} else {
    Write-Host "Starting backup of Claude Code configuration..." -ForegroundColor Cyan
    Write-Host "Source: $ProductionPath" -ForegroundColor Gray
    Write-Host "Destination: $FullBackupPath" -ForegroundColor Gray
    
    # Create timestamped backup directory
    New-Item -ItemType Directory -Path $FullBackupPath -Force | Out-Null
    
    # Copy entire .claude directory with all subdirectories and files
    Copy-Item -Path "$ProductionPath\*" -Destination $FullBackupPath -Recurse -Force
}

# Calculate backup statistics
$FilesCount = (Get-ChildItem -Path $FullBackupPath -Recurse -File | Measure-Object).Count
$BackupSize = [math]::Round((Get-ChildItem -Path $FullBackupPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)

# Create integrity manifest with MD5 hashes
Write-Host "Creating integrity manifest..." -ForegroundColor Gray
$ManifestPath = "$FullBackupPath\backup-manifest.txt"
$HasManifest = $false

$ManifestContent = @()
Get-ChildItem -Path $FullBackupPath -Recurse -File | 
    Where-Object { $_.Name -notlike "backup-*" } |
    Sort-Object FullName | ForEach-Object {
    $Hash = Get-FileHash -Path $_.FullName -Algorithm MD5 -ErrorAction SilentlyContinue
    if ($Hash) {
        $RelativePath = $_.FullName.Replace("$FullBackupPath\", "").Replace("\", "/")
        $ManifestContent += "$($Hash.Hash.ToLower())  ./$RelativePath"
    }
}

if ($ManifestContent.Count -gt 0) {
    $ManifestContent | Out-File -FilePath $ManifestPath -Encoding UTF8
    $HasManifest = $true
    Write-Host "Created integrity manifest with $($ManifestContent.Count) file hashes" -ForegroundColor Green
} else {
    Write-Host "Could not create integrity manifest" -ForegroundColor Yellow
}

# Create backup metadata
$BackupInfo = @{
    timestamp = $Timestamp
    source = $ProductionPath
    backup_path = $FullBackupPath
    files_backed_up = $FilesCount
    backup_size_mb = "$($BackupSize)M"
    platform = $env:OS
    hostname = $env:COMPUTERNAME
    has_manifest = $HasManifest
} | ConvertTo-Json -Depth 2

$BackupInfo | Out-File -FilePath "$FullBackupPath\backup-info.json" -Encoding UTF8

Write-Host "Backup completed successfully!" -ForegroundColor Green
Write-Host "  Files backed up: $FilesCount" -ForegroundColor Gray
Write-Host "  Backup size: $($BackupSize)M" -ForegroundColor Gray
Write-Host "  Backup location: $FullBackupPath" -ForegroundColor Gray

# Clean old backups (keep last 10)
try {
    $OldBackups = Get-ChildItem -Path $BackupPath -Directory |
                  Where-Object { $_.Name -like "claude-config-backup-*" } |
                  Sort-Object CreationTime -Descending |
                  Select-Object -Skip 10

    foreach ($OldBackup in $OldBackups) {
        Remove-Item -Path $OldBackup.FullName -Recurse -Force
        Write-Host "Cleaned old backup: $($OldBackup.Name)" -ForegroundColor Yellow
    }
} catch {
    Write-Warning "Could not clean old backups: $($_.Exception.Message)"
}

# Return backup path for deployment script
Write-Output $FullBackupPath