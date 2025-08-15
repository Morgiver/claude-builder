# CLAUDE_COMMAND_NAME: sysinfo
# CLAUDE_COMMAND_DESC: Display detailed Windows system information
# CLAUDE_COMMAND_ARGS: [format] (table|json|text)

param(
    [string]$Format = "table"
)

# Collect system information
$SystemInfo = @{
    "Computer Name" = $env:COMPUTERNAME
    "User" = $env:USERNAME
    "Domain" = $env:USERDOMAIN
    "OS" = (Get-WmiObject Win32_OperatingSystem).Caption
    "Version" = (Get-WmiObject Win32_OperatingSystem).Version
    "Architecture" = $env:PROCESSOR_ARCHITECTURE
    "Processor" = (Get-WmiObject Win32_Processor).Name
    "Total RAM (GB)" = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    "Free RAM (GB)" = [math]::Round((Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory / 1MB / 1024, 2)
    "C: Free Space (GB)" = [math]::Round((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace / 1GB, 2)
    "Boot Time" = (Get-WmiObject Win32_OperatingSystem).ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).LastBootUpTime)
    "PowerShell Version" = $PSVersionTable.PSVersion.ToString()
}

# Display according to requested format
switch ($Format.ToLower()) {
    "json" {
        Write-Host "📋 System Information (JSON):" -ForegroundColor Cyan
        $SystemInfo | ConvertTo-Json -Depth 2
    }
    "text" {
        Write-Host "📋 System Information:" -ForegroundColor Cyan
        foreach ($key in $SystemInfo.Keys) {
            Write-Host "$key : $($SystemInfo[$key])"
        }
    }
    default {
        Write-Host "📋 System Information:" -ForegroundColor Cyan
        $SystemInfo.GetEnumerator() | Sort-Object Name | Format-Table -AutoSize
    }
}

# Top consuming processes
Write-Host "`n🔥 Top 5 processes (CPU):" -ForegroundColor Yellow
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 ProcessName, CPU, WorkingSet | Format-Table -AutoSize

exit 0