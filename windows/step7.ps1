# PowerShell Script: diagnostics7.ps1
# Creates diagnostics7.txt and logs changes, appending each time the script is run.

$diagnosticsFile = ".\diagnostics7.txt"

# Function to write to diagnostics file in a neat format
function Write-Diagnostics {
    param (
        [string]$text
    )
    Add-Content -Path $diagnosticsFile -Value "`n$text"
}

# Start logging the script's actions
Write-Diagnostics "Script Execution Started - $(Get-Date)"

# ------------------- Check for Suspicious Processes -------------------
$suspiciousProcesses = @("nc.exe", "powershell.exe", "wmic.exe", "vncviewer.exe", "teamviewer.exe", "anydesk.exe", "xmr-stak.exe", "kismet.exe")

$runningProcesses = Get-Process | Where-Object { $suspiciousProcesses -contains $_.Name }

if ($runningProcesses) {
    Write-Diagnostics "Suspicious Processes Found:"
    $runningProcesses | ForEach-Object { Write-Diagnostics "Process: $($_.Name)" }
} else {
    Write-Diagnostics "No suspicious processes found."
}

# ------------------- Check for Open Ports -------------------
$openPorts = Get-NetTCPConnection | Where-Object { $_.State -eq 'Listen' }

if ($openPorts) {
    Write-Diagnostics "Suspicious Open Ports:"
    $openPorts | ForEach-Object { Write-Diagnostics "Port: $($_.LocalPort) on IP: $($_.LocalAddress)" }
} else {
    Write-Diagnostics "No suspicious open ports found."
}

# ------------------- Check for FTP Services -------------------
$ftpServices = Get-Service | Where-Object { $_.Name -match "ftp|ftpd|vsftpd|proftpd" }

if ($ftpServices) {
    Write-Diagnostics "FTP Services Found:"
    $ftpServices | ForEach-Object { Write-Diagnostics "Service: $($_.Name) - Status: $($_.Status)" }
} else {
    Write-Diagnostics "No FTP services found."
}

# ------------------- Log Scheduled Tasks -------------------
$scheduledTasks = Get-ScheduledTask | Where-Object { $_.State -eq "Ready" }

if ($scheduledTasks) {
    Write-Diagnostics "Scheduled Tasks Found:"
    $scheduledTasks | ForEach-Object { Write-Diagnostics "Task: $($_.TaskName) - Status: $($_.State)" }
} else {
    Write-Diagnostics "No scheduled tasks found."
}

# ------------------- Log Recent Event Logs -------------------
$eventLogs = Get-WinEvent -LogName Application, System -MaxEvents 10

if ($eventLogs) {
    Write-Diagnostics "Recent Event Logs:"
    $eventLogs | ForEach-Object { Write-Diagnostics "Event ID: $($_.Id) - Message: $($_.Message)" }
} else {
    Write-Diagnostics "No recent event logs found."
}

# ------------------- Disable SMBv1 -------------------
Write-Diagnostics "Disabling SMBv1 Protocol to prevent remote exploitation..."
$disableSMBv1 = Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart

if ($disableSMBv1) {
    Write-Diagnostics "SMBv1 has been successfully disabled."
} else {
    Write-Diagnostics "Failed to disable SMBv1."
}

# ------------------- Check for Suspicious Processes Using ProcessLibrary -------------------
Write-Diagnostics "Checking for additional suspicious processes using https://www.processlibrary.com/..."

# Get the list of running processes
$processList = Get-Process | Select-Object -ExpandProperty Name

Write-Diagnostics "List of running processes to check at https://www.processlibrary.com/ for suspicious activity:"
$processList | ForEach-Object { Write-Diagnostics $_ }

# ------------------- End of Script -------------------
Write-Diagnostics "Script Execution Ended - $(Get-Date)"
Write-Diagnostics "End of Diagnostics"

# Additional security suggestions (for you to decide if you'd like to add them to the script):
# 1. Enforce strong password policies and 2FA
# 2. Disable unnecessary services such as RDP if not required
# 3. Enable Windows Defender and update regularly
# 4. Implement a firewall rule to restrict inbound connections
# 5. Monitor for abnormal network traffic with tools like Wireshark
# 6. Install an intrusion detection system (IDS) like Snort

# Note: You can implement these additional measures based on your needs.
