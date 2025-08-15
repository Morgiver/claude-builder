# Example logging hook for Windows PowerShell
# This hook logs Claude Code activity

param(
    [string]$Event = "unknown",
    [string]$Data = ""
)

# Configuration
$LogDir = "$env:USERPROFILE\.claude\logs"
$LogFile = "$LogDir\claude-activity.log"

# Create logs directory if it doesn't exist
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Timestamp
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Message de log
$LogMessage = "[$Timestamp] EVENT:$Event"
if ($Data) {
    $LogMessage += " DATA:$Data"
}

# Write to log
Add-Content -Path $LogFile -Value $LogMessage

# Feedback
Write-Host "📝 Hook: Event logged to $LogFile" -ForegroundColor Green

exit 0