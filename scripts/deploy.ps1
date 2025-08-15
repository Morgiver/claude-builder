# Claude Code Configuration Deployment Script
# Deploys development configuration to production with automatic backup

param(
    [switch]$Force,
    [switch]$SkipBackup,
    [switch]$Verbose
)

# Default to Force mode to avoid interactive prompts
if (-not $PSBoundParameters.ContainsKey('Force')) {
    $Force = $true
}

# Configuration
$DevPath = ".\.claude"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Auto-detect production path with fallback options
$ProductionPath = $null
if ($env:CLAUDE_CONFIG_PATH) {
    $ProductionPath = $env:CLAUDE_CONFIG_PATH
    Write-Host "Using custom path from CLAUDE_CONFIG_PATH: $ProductionPath" -ForegroundColor Cyan
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

Write-Host "Claude Code Configuration Deployment" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# Validate development configuration exists
if (-not (Test-Path $DevPath)) {
    Write-Host "Development configuration not found at: $DevPath" -ForegroundColor Red
    exit 1
}

# Validate settings.json syntax
try {
    $SettingsPath = Join-Path $DevPath "settings.json"
    if (Test-Path $SettingsPath) {
        $Settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json
        Write-Host "settings.json syntax is valid" -ForegroundColor Green
    }
} catch {
    Write-Host "Invalid settings.json syntax!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create backup unless skipped
$BackupPath = $null
if (-not $SkipBackup) {
    Write-Host "`nCreating backup..." -ForegroundColor Yellow
    try {
        $BackupResult = & "$ScriptDir\backup.ps1"
        if ($LASTEXITCODE -eq 0) {
            $BackupPath = $BackupResult
            Write-Host "Backup created successfully" -ForegroundColor Green
        } else {
            Write-Host "Backup failed!" -ForegroundColor Red
            if (-not $Force) {
                Write-Host "Use -Force to deploy without backup" -ForegroundColor Yellow
                exit 1
            }
        }
    } catch {
        Write-Host "Backup error: $($_.Exception.Message)" -ForegroundColor Red
        if (-not $Force) {
            exit 1
        }
    }
}

# Confirm deployment
if (-not $Force) {
    Write-Host "`nReady to deploy configuration:" -ForegroundColor Yellow
    Write-Host "  From: $DevPath" -ForegroundColor Gray
    Write-Host "  To: $ProductionPath" -ForegroundColor Gray
    if ($BackupPath) {
        Write-Host "  Backup: $BackupPath" -ForegroundColor Gray
    }
    
    $Confirm = Read-Host "`nProceed with deployment? (y/N)"
    if ($Confirm -ne 'y' -and $Confirm -ne 'Y') {
        Write-Host "Deployment cancelled." -ForegroundColor Yellow
        exit 0
    }
}

try {
    Write-Host "`nDeploying configuration..." -ForegroundColor Cyan
    
    # Create production directory if it doesn't exist
    if (-not (Test-Path $ProductionPath)) {
        New-Item -ItemType Directory -Path $ProductionPath -Force | Out-Null
        Write-Host "Created production directory: $ProductionPath" -ForegroundColor Green
    }
    
    # Deploy CLAUDE-build.md as CLAUDE.md
    $DevClaude = "CLAUDE-build.md"
    $ProdClaude = Join-Path $ProductionPath "CLAUDE.md"
    if (Test-Path $DevClaude) {
        Copy-Item -Path $DevClaude -Destination $ProdClaude -Force
        Write-Host "Deployed CLAUDE.md" -ForegroundColor Green
    }
    
    # Deploy settings.json
    $DevSettings = Join-Path $DevPath "settings.json"
    $ProdSettings = Join-Path $ProductionPath "settings.json"
    if (Test-Path $DevSettings) {
        Copy-Item -Path $DevSettings -Destination $ProdSettings -Force
        Write-Host "Deployed settings.json" -ForegroundColor Green
    }
    
    # Deploy agents directory
    $DevAgents = Join-Path $DevPath "agents"
    $ProdAgents = Join-Path $ProductionPath "agents"
    if (Test-Path $DevAgents) {
        # Remove existing agents directory and recreate
        if (Test-Path $ProdAgents) {
            Remove-Item -Path $ProdAgents -Recurse -Force
        }
        Copy-Item -Path $DevAgents -Destination $ProdAgents -Recurse -Force
        $AgentCount = (Get-ChildItem -Path $ProdAgents -Filter "*.md" | Measure-Object).Count
        Write-Host "Deployed $AgentCount agents" -ForegroundColor Green
    }
    
    # Deploy hooks directory
    $DevHooks = Join-Path $DevPath "hooks"
    $ProdHooks = Join-Path $ProductionPath "hooks"
    if (Test-Path $DevHooks) {
        # Remove existing hooks directory and recreate
        if (Test-Path $ProdHooks) {
            Remove-Item -Path $ProdHooks -Recurse -Force
        }
        Copy-Item -Path $DevHooks -Destination $ProdHooks -Recurse -Force
        $HookCount = (Get-ChildItem -Path $ProdHooks -Recurse -File | Measure-Object).Count
        Write-Host "Deployed $HookCount hooks" -ForegroundColor Green
    }
    
    # Deploy commands directory
    $DevCommands = Join-Path $DevPath "commands"
    $ProdCommands = Join-Path $ProductionPath "commands"
    if (Test-Path $DevCommands) {
        # Remove existing commands directory and recreate
        if (Test-Path $ProdCommands) {
            Remove-Item -Path $ProdCommands -Recurse -Force
        }
        Copy-Item -Path $DevCommands -Destination $ProdCommands -Recurse -Force
        $CommandCount = (Get-ChildItem -Path $ProdCommands -Recurse -File | Measure-Object).Count
        Write-Host "Deployed $CommandCount commands" -ForegroundColor Green
    }
    
    # Deploy contexts directory
    $DevContexts = Join-Path $DevPath "contexts"
    $ProdContexts = Join-Path $ProductionPath "contexts"
    if (Test-Path $DevContexts) {
        # Remove existing contexts directory and recreate
        if (Test-Path $ProdContexts) {
            Remove-Item -Path $ProdContexts -Recurse -Force
        }
        Copy-Item -Path $DevContexts -Destination $ProdContexts -Recurse -Force
        $ContextCount = (Get-ChildItem -Path $ProdContexts -Recurse -File | Measure-Object).Count
        Write-Host "Deployed $ContextCount contexts" -ForegroundColor Green
    }
    
    # Create deployment log
    $DeploymentInfo = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        source = $DevPath
        destination = $ProductionPath
        backup_path = $BackupPath
        deployed_files = @()
    }
    
    # Log deployed files
    Get-ChildItem -Path $ProductionPath -Recurse -File | ForEach-Object {
        $RelativePath = $_.FullName.Replace($ProductionPath, "").TrimStart("\")
        $DeploymentInfo.deployed_files += $RelativePath
    }
    
    $DeploymentInfo | ConvertTo-Json -Depth 3 | Out-File -FilePath "$ProductionPath\deployment-log.json"
    
    Write-Host "`nDeployment completed successfully!" -ForegroundColor Green
    Write-Host "  Configuration is now active at: $ProductionPath" -ForegroundColor Gray
    Write-Host "  Files deployed: $($DeploymentInfo.deployed_files.Count)" -ForegroundColor Gray
    
    if ($BackupPath) {
        Write-Host "`nTo rollback if needed:" -ForegroundColor Cyan
        Write-Host "  .\scripts\restore.ps1 -BackupPath `"$BackupPath`"" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "Deployment failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($BackupPath) {
        Write-Host "`nTo restore from backup:" -ForegroundColor Yellow
        Write-Host "  .\scripts\restore.ps1 -BackupPath `"$BackupPath`"" -ForegroundColor Gray
    }
    
    exit 1
}